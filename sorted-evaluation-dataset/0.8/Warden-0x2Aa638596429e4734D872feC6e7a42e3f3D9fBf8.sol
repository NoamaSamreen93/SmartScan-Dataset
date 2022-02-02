// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./open-zeppelin/interfaces/IERC20.sol";
import "./open-zeppelin/libraries/SafeERC20.sol";
import "./open-zeppelin/utils/Ownable.sol";
import "./open-zeppelin/utils/Pausable.sol";
import "./open-zeppelin/utils/ReentrancyGuard.sol";
import "./interfaces/IVotingEscrow.sol";
import "./interfaces/IVotingEscrowDelegation.sol";

/** @title Warden contract  */
/// @author Paladin
/*
    Delegation market based on Curve VotingEscrowDelegation contract
*/
contract Warden is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Constants :
    uint256 public constant UNIT = 1e18;
    uint256 public constant MAX_PCT = 10000;
    uint256 public constant WEEK = 7 * 86400;

    // Storage :

    /** @notice Offer made by an user to buy a given amount of his votes 
    user : Address of the user making the offer
    pricePerVote : Price per vote per second, set by the user
    minPerc : Minimum percent of users voting token balance to buy for a Boost (in BPS)
    maxPerc : Maximum percent of users total voting token balance available to delegate (in BPS)
    */
    struct BoostOffer {
        // Address of the user making the offer
        address user;
        // Price per vote per second, set by the user
        uint256 pricePerVote;
        // Minimum percent of users voting token balance to buy for a Boost
        uint16 minPerc; //bps
        // Maximum percent of users total voting token balance available to delegate
        uint16 maxPerc; //bps
    }

    /** @notice ERC20 used to pay for DelegationBoost */
    IERC20 public feeToken;
    /** @notice Address of the votingToken to delegate */
    IVotingEscrow public votingEscrow;
    /** @notice Address of the Delegation Boost contract */
    IVotingEscrowDelegation public delegationBoost;

    /** @notice ratio of fees to be set as Reserve (in BPS) */
    uint256 public feeReserveRatio; //bps
    /** @notice Total Amount in the Reserve */
    uint256 public reserveAmount;
    /** @notice Address allowed to withdraw from the Reserve */
    address public reserveManager;

    /** @notice Min Percent of delegator votes to buy required to purchase a Delegation Boost (in BPS) */
    uint256 public minPercRequired; //bps

    /** @notice Minimum delegation time, taken from veBoost contract */
    uint256 public minDelegationTime = 1 weeks;

    /** @notice List of all current registered users and their delegation offer */
    BoostOffer[] public offers;

    /** @notice Index of the user in the offers array */
    mapping(address => uint256) public userIndex;

    /** @notice Amount of fees earned by users through Boost selling */
    mapping(address => uint256) public earnedFees;

    bool private _claimBlocked;

    // Events :

    event Registred(address indexed user, uint256 price);

    event UpdateOffer(address indexed user, uint256 newPrice);

    event Quit(address indexed user);

    event BoostPurchase(
        address indexed delegator,
        address indexed receiver,
        uint256 tokenId,
        uint256 percent, //bps
        uint256 price,
        uint256 paidFeeAmount,
        uint256 expiryTime
    );

    event Claim(address indexed user, uint256 amount);

    modifier onlyAllowed(){
        require(msg.sender == reserveManager || msg.sender == owner(), "Warden: Not allowed");
        _;
    }

    // Constructor :
    /**
     * @dev Creates the contract, set the given base parameters
     * @param _feeToken address of the token used to pay fees
     * @param _votingEscrow address of the voting token to delegate
     * @param _delegationBoost address of the contract handling delegation
     * @param _feeReserveRatio Percent of fees to be set as Reserve (bps)
     * @param _minPercRequired Minimum percent of user
     */
    constructor(
        address _feeToken,
        address _votingEscrow,
        address _delegationBoost,
        uint256 _feeReserveRatio, //bps
        uint256 _minPercRequired //bps
    ) {
        feeToken = IERC20(_feeToken);
        votingEscrow = IVotingEscrow(_votingEscrow);
        delegationBoost = IVotingEscrowDelegation(_delegationBoost);

        require(_feeReserveRatio <= 5000);
        require(_minPercRequired > 0 && _minPercRequired <= 10000);
        feeReserveRatio = _feeReserveRatio;
        minPercRequired = _minPercRequired;

        // fill index 0 in the offers array
        // since we want to use index 0 for unregistered users
        offers.push(BoostOffer(address(0), 0, 0, 0));
    }

    // Functions :

    function offersIndex() external view returns(uint256){
        return offers.length;
    }

    /**
     * @notice Registers a new user wanting to sell its delegation
     * @dev Regsiters a new user, creates a BoostOffer with the given parameters
     * @param pricePerVote Price of 1 vote per second (in wei)
     * @param minPerc Minimum percent of users voting token balance to buy for a Boost (in BPS)
     * @param maxPerc Maximum percent of users total voting token balance available to delegate (in BPS)
     */
    function register(
        uint256 pricePerVote,
        uint16 minPerc,
        uint16 maxPerc
    ) external whenNotPaused returns(bool) {
        address user = msg.sender;
        require(userIndex[user] == 0, "Warden: Already registered");
        require(
            delegationBoost.isApprovedForAll(user, address(this)),
            "Warden: Not operator for caller"
        );

        require(pricePerVote > 0, "Warden: Price cannot be 0");
        require(maxPerc <= 10000, "Warden: maxPerc too high");
        require(minPerc <= maxPerc, "Warden: minPerc is over maxPerc");
        require(minPerc >= minPercRequired, "Warden: minPerc too low");

        // Create the BoostOffer for the new user, and add it to the storage
        userIndex[user] = offers.length;
        offers.push(BoostOffer(user, pricePerVote, minPerc, maxPerc));

        emit Registred(user, pricePerVote);

        return true;
    }

    /**
     * @notice Updates an user BoostOffer parameters
     * @dev Updates parameters for the user's BoostOffer
     * @param pricePerVote Price of 1 vote per second (in wei)
     * @param minPerc Minimum percent of users voting token balance to buy for a Boost (in BPS)
     * @param maxPerc Maximum percent of users total voting token balance available to delegate (in BPS)
     */
    function updateOffer(
        uint256 pricePerVote,
        uint16 minPerc,
        uint16 maxPerc
    ) external whenNotPaused returns(bool) {
        // Fet the user index, and check for registration
        address user = msg.sender;
        uint256 index = userIndex[user];
        require(index != 0, "Warden: Not registered");

        // Fetch the BoostOffer to update
        BoostOffer storage offer = offers[index];

        require(offer.user == msg.sender, "Warden: Not offer owner");

        require(pricePerVote > 0, "Warden: Price cannot be 0");
        require(maxPerc <= 10000, "Warden: maxPerc too high");
        require(minPerc <= maxPerc, "Warden: minPerc is over maxPerc");
        require(minPerc >= minPercRequired, "Warden: minPerc too low");

        // Update the parameters
        offer.pricePerVote = pricePerVote;
        offer.minPerc = minPerc;
        offer.maxPerc = maxPerc;

        emit UpdateOffer(user, pricePerVote);

        return true;
    }

    /**
     * @notice Remove the BoostOffer of the user, and claim any remaining fees earned
     * @dev User's BoostOffer is removed from the listing, and any unclaimed fees is sent
     */
    function quit() external whenNotPaused nonReentrant returns(bool) {
        address user = msg.sender;
        require(userIndex[user] != 0, "Warden: Not registered");

        // Check for unclaimed fees, claim it if needed
        if (earnedFees[user] > 0) {
            _claim(user, earnedFees[user]);
        }

        // Find the BoostOffer to remove
        uint256 currentIndex = userIndex[user];
        // If BoostOffer is not the last of the list
        // Replace last of the list with the one to remove
        if (currentIndex < offers.length) {
            uint256 lastIndex = offers.length - 1;
            address lastUser = offers[lastIndex].user;
            offers[currentIndex] = offers[lastIndex];
            userIndex[lastUser] = currentIndex;
        }
        //Remove the last item of the list
        offers.pop();
        userIndex[user] = 0;

        emit Quit(user);

        return true;
    }

    /**
     * @notice Gives an estimate of fees to pay for a given Boost Delegation
     * @dev Calculates the amount of fees for a Boost Delegation with the given amount (through the percent) and the duration
     * @param delegator Address of the delegator for the Boost
     * @param percent Percent of the delegator balance to delegate (in BPS)
     * @param duration Duration (in weeks) of the Boost to purchase
     */
    function estimateFees(
        address delegator,
        uint256 percent,
        uint256 duration //in weeks
    ) external view returns (uint256) {
        require(delegator != address(0), "Warden: Zero address");
        require(userIndex[delegator] != 0, "Warden: Not registered");
        require(
            percent >= minPercRequired,
            "Warden: Percent under min required"
        );
        require(percent <= MAX_PCT, "Warden: Percent over 100");

        // Get the duration in seconds, and check it's more than the minimum required
        uint256 durationSeconds = duration * 1 weeks;
        require(
            durationSeconds >= minDelegationTime,
            "Warden: Duration too short"
        );

        // Fetch the BoostOffer for the delegator
        BoostOffer storage offer = offers[userIndex[delegator]];

        require(
            percent >= offer.minPerc && percent <= offer.maxPerc,
            "Warden: Percent out of Offer bounds"
        );
        uint256 expiryTime = ((block.timestamp + durationSeconds) / WEEK) * WEEK;
        expiryTime = (expiryTime < block.timestamp + durationSeconds) ?
            ((block.timestamp + durationSeconds + WEEK) / WEEK) * WEEK :
            expiryTime;
        require(
            expiryTime <= votingEscrow.locked__end(delegator),
            "Warden: Lock expires before Boost"
        );

        // Find how much of the delegator's tokens the given percent represents
        uint256 delegatorBalance = votingEscrow.balanceOf(delegator);
        uint256 toDelegateAmount = (delegatorBalance * percent) / MAX_PCT;

        // Get the price for the whole Amount (price fer second)
        uint256 priceForAmount = (toDelegateAmount * offer.pricePerVote) / UNIT;

        // Then multiply it by the duration (in seconds) to get the cost of the Boost
        return priceForAmount * durationSeconds;
    }

    /** 
        All local variables used in the buyDelegationBoost function
     */
    struct BuyVars {
        uint256 boostDuration;
        uint256 delegatorBalance;
        uint256 toDelegateAmount;
        uint256 realFeeAmount;
        uint256 expiryTime;
        uint256 cancelTime;
        uint256 boostPercent;
        uint256 newId;
        uint256 newTokenId;
    }

    /**
     * @notice Buy a Delegation Boost for a Delegator Offer
     * @dev If all parameters match the offer from the delegator, creates a Boost for the caller
     * @param delegator Address of the delegator for the Boost
     * @param receiver Address of the receiver of the Boost
     * @param percent Percent of the delegator balance to delegate (in BPS)
     * @param duration Duration (in weeks) of the Boost to purchase
     * @param maxFeeAmount Maximum amount of feeToken available to pay to cover the Boost Duration (in wei)
     * returns the id of the new veBoost
     */
    function buyDelegationBoost(
        address delegator,
        address receiver,
        uint256 percent,
        uint256 duration, //in weeks
        uint256 maxFeeAmount
    ) external nonReentrant whenNotPaused returns(uint256) {
        require(
            delegator != address(0) && receiver != address(0),
            "Warden: Zero address"
        );
        require(userIndex[delegator] != 0, "Warden: Not registered");
        require(maxFeeAmount > 0, "Warden: No fees");
        require(
            percent >= minPercRequired,
            "Warden: Percent under min required"
        );
        require(percent <= MAX_PCT, "Warden: Percent over 100");

        BuyVars memory vars;

        // Get the duration of the wanted Boost in seconds
        vars.boostDuration = duration * 1 weeks;
        require(
            vars.boostDuration >= minDelegationTime,
            "Warden: Duration too short"
        );

        // Fetch the BoostOffer for the delegator
        BoostOffer storage offer = offers[userIndex[delegator]];

        require(
            percent >= offer.minPerc && percent <= offer.maxPerc,
            "Warden: Percent out of Offer bounds"
        );

        // Find how much of the delegator's tokens the given percent represents
        vars.delegatorBalance = votingEscrow.balanceOf(delegator);
        vars.toDelegateAmount = (vars.delegatorBalance * percent) / MAX_PCT;

        // Check if delegator can delegate the amount, without exceeding the maximum percent allowed by the delegator
        // _canDelegate will also try to cancel expired Boosts of the deelgator to free more tokens for delegation
        require(
            _canDelegate(delegator, vars.toDelegateAmount, offer.maxPerc),
            "Warden: Cannot delegate"
        );

        // Calculate the price for the given duration, get the real amount of fees to pay,
        // and check the maxFeeAmount provided (and approved beforehand) is enough.
        // Calculated using the pricePerVote set by the delegator
        vars.realFeeAmount = (vars.toDelegateAmount * offer.pricePerVote * vars.boostDuration) / UNIT;
        require(
            vars.realFeeAmount <= maxFeeAmount,
            "Warden: Fees do not cover Boost duration"
        );

        // Pull the tokens from the buyer, setting it as earned fees for the delegator (and part of it for the Reserve)
        _pullFees(msg.sender, vars.realFeeAmount, delegator);

        // Calcualte the expiry time for the Boost = now + duration
        vars.expiryTime = ((block.timestamp + vars.boostDuration) / WEEK) * WEEK;

        // Hack needed because veBoost contract rounds down expire_time
        // We don't want buyers to receive less than they pay for
        // So an "extra" week is added if needed to get an expire_time covering the required duration
        // But cancel_time will be set for the exact paid duration, so any "bonus days" received can be canceled
        // if a new buyer wants to take the offer
        vars.expiryTime = (vars.expiryTime < block.timestamp + vars.boostDuration) ?
            ((block.timestamp + vars.boostDuration + WEEK) / WEEK) * WEEK :
            vars.expiryTime;
        require(
            vars.expiryTime <= votingEscrow.locked__end(delegator),
            "Warden: Lock expires before Boost"
        );

        // VotingEscrowDelegation needs the percent of available tokens for delegation when creating the boost, instead of
        // the percent of the users balance. We calculate this percent representing the amount of tokens wanted by the buyer
        vars.boostPercent = (vars.toDelegateAmount * MAX_PCT) / 
            (vars.delegatorBalance - delegationBoost.delegated_boost(delegator));

        // Get the id (depending on the delegator) for the new Boost
        vars.newId = delegationBoost.total_minted(delegator);
        unchecked {
            // cancelTime stays current timestamp + paid duration
            // Should not overflow : Since expiryTime is the same + some extra time, expiryTime >= cancelTime
            vars.cancelTime = block.timestamp + vars.boostDuration;
        }

        // Creates the DelegationBoost
        delegationBoost.create_boost(
            delegator,
            receiver,
            int256(vars.boostPercent),
            vars.cancelTime,
            vars.expiryTime,
            vars.newId
        );

        // Fetch the tokenId for the new DelegationBoost that was created, and check it was set for the correct delegator
        vars.newTokenId = delegationBoost.get_token_id(delegator, vars.newId);
        require(
            vars.newTokenId ==
                delegationBoost.token_of_delegator_by_index(delegator, vars.newId),
            "Warden: DelegationBoost failed"
        );

        emit BoostPurchase(
            delegator,
            receiver,
            vars.newTokenId,
            percent,
            offer.pricePerVote,
            vars.realFeeAmount,
            vars.expiryTime
        );

        return vars.newTokenId;
    }

    /**
     * @notice Cancels a DelegationBoost
     * @dev Cancels a DelegationBoost :
     * In case the caller is the owner of the Boost, at any time
     * In case the caller is the delegator for the Boost, after cancel_time
     * Else, after expiry_time
     * @param tokenId Id of the DelegationBoost token to cancel
     */
    function cancelDelegationBoost(uint256 tokenId) external whenNotPaused returns(bool) {
        address tokenOwner = delegationBoost.ownerOf(tokenId);
        // If the caller own the token, and this contract is operator for the owner
        // we try to burn the token directly
        if (
            msg.sender == tokenOwner &&
            delegationBoost.isApprovedForAll(tokenOwner, address(this))
        ) {
            delegationBoost.burn(tokenId);
            return true;
        }

        uint256 currentTime = block.timestamp;

        // Delegator can cancel the Boost if Cancel Time passed
        address delegator = _getTokenDelegator(tokenId);
        if (
            delegationBoost.token_cancel_time(tokenId) < currentTime &&
            (msg.sender == delegator &&
                delegationBoost.isApprovedForAll(delegator, address(this)))
        ) {
            delegationBoost.cancel_boost(tokenId);
            return true;
        }

        // Else, we wait Exipiry Time, so anyone can cancel the delegation
        if (delegationBoost.token_expiry(tokenId) < currentTime) {
            delegationBoost.cancel_boost(tokenId);
            return true;
        }

        revert("Cannot cancel the boost");
    }

    /**
     * @notice Returns the amount of fees earned by the user that can be claimed
     * @dev Returns the value in earnedFees for the given user
     * @param user Address of the user
     */
    function claimable(address user) external view returns (uint256) {
        return earnedFees[user];
    }

    /**
     * @notice Claims all earned fees
     * @dev Send all the user's earned fees
     */
    function claim() external nonReentrant returns(bool) {
        require(
            earnedFees[msg.sender] != 0,
            "Warden: Claim null amount"
        );
        return _claim(msg.sender, earnedFees[msg.sender]);
    }

    /**
     * @notice Claims all earned fees, and cancel all expired Delegation Boost for the user
     * @dev Send all the user's earned fees, and fetch all expired Boosts to cancel them
     */
    function claimAndCancel() external nonReentrant returns(bool) {
        _cancelAllExpired(msg.sender);
        return _claim(msg.sender, earnedFees[msg.sender]);
    }

    /**
     * @notice Claims an amount of earned fees through Boost Delegation selling
     * @dev Send the given amount of earned fees (if amount is correct)
     * @param amount Amount of earned fees to claim
     */
    function claim(uint256 amount) external nonReentrant returns(bool) {
        require(amount <= earnedFees[msg.sender], "Warden: Amount too high");
        require(
            amount != 0,
            "Warden: Claim null amount"
        );
        return _claim(msg.sender, amount);
    }

    function _pullFees(
        address buyer,
        uint256 amount,
        address seller
    ) internal {
        // Pull the given token amount ot this contract (must be approved beforehand)
        feeToken.safeTransferFrom(buyer, address(this), amount);

        // Split fees between Boost offerer & Reserve
        earnedFees[seller] += (amount * (MAX_PCT - feeReserveRatio)) / MAX_PCT;
        reserveAmount += (amount * feeReserveRatio) / MAX_PCT;
    }

    function _canDelegate(
        address delegator,
        uint256 amount,
        uint256 delegatorMaxPerc
    ) internal returns (bool) {
        if (!delegationBoost.isApprovedForAll(delegator, address(this)))
            return false;

        // Delegator current balance
        uint256 balance = votingEscrow.balanceOf(delegator);

        // Percent of delegator balance not allowed to delegate (as set by maxPerc in the BoostOffer)
        uint256 blockedBalance = (balance * (MAX_PCT - delegatorMaxPerc)) / MAX_PCT;

        // Available Balance to delegate = VotingEscrow Balance - Delegated Balance - Blocked Balance
        uint256 availableBalance = balance - delegationBoost.delegated_boost(delegator) - blockedBalance;
        if (amount <= availableBalance) return true;

        // Check if cancel expired Boosts could bring enough to delegate
        uint256 potentialBalance = availableBalance;

        uint256 nbTokens = delegationBoost.total_minted(delegator);
        uint256[256] memory toCancel; //Need this type of array because of batch_cancel_boosts() from veBoost
        uint256 nbToCancel = 0;

        // Loop over the delegator current boosts to find expired ones
        for (uint256 i = 0; i < nbTokens; i++) {
            uint256 tokenId = delegationBoost.token_of_delegator_by_index(
                delegator,
                i
            );

            if (delegationBoost.token_cancel_time(tokenId) <= block.timestamp && delegationBoost.token_cancel_time(tokenId) != 0) {
                int256 boost = delegationBoost.token_boost(tokenId);
                uint256 absolute_boost = boost >= 0 ? uint256(boost) : uint256(-boost);
                potentialBalance += absolute_boost;
                toCancel[nbToCancel] = tokenId;
                nbToCancel++;
            }
        }

        // If canceling the tokens can free enough to delegate,
        // cancel the batch and return true
        if (amount <= potentialBalance && nbToCancel > 0) {
            delegationBoost.batch_cancel_boosts(toCancel);
            return true;
        }

        return false;
    }

    function _cancelAllExpired(address delegator) internal {
        uint256 nbTokens = delegationBoost.total_minted(delegator);
        // Delegator does not have active Boosts currently
        if (nbTokens == 0) return;

        uint256[256] memory toCancel;
        uint256 nbToCancel = 0;
        uint256 currentTime = block.timestamp;

        // Loop over the delegator current boosts to find expired ones
        for (uint256 i = 0; i < nbTokens; i++) {
            uint256 tokenId = delegationBoost.token_of_delegator_by_index(
                delegator,
                i
            );
            uint256 cancelTime = delegationBoost.token_cancel_time(tokenId);

            if (cancelTime <= currentTime && cancelTime != 0) {
                toCancel[nbToCancel] = tokenId;
                nbToCancel++;
            }
        }

        // If Boost were found, cancel the batch
        if (nbToCancel > 0) {
            delegationBoost.batch_cancel_boosts(toCancel);
        }
    }

    function _claim(address user, uint256 amount) internal returns(bool) {
        require(
            !_claimBlocked,
            "Warden: Claim blocked"
        );
        require(
            amount <= feeToken.balanceOf(address(this)),
            "Warden: Insufficient cash"
        );

        if(amount == 0) return true; // nothing to claim, but used in claimAndCancel()

        // If fees to be claimed, update the mapping, and send the amount
        unchecked{
            // Should not underflow, since the amount was either checked in the claim() method, or set as earnedFees[user]
            earnedFees[user] -= amount;
        }

        feeToken.safeTransfer(user, amount);

        emit Claim(user, amount);

        return true;
    }

    function _getTokenDelegator(uint256 tokenId)
        internal
        pure
        returns (address)
    {
        //Extract the address from the token id : See VotingEscrowDelegation.vy for the logic
        return address(uint160(tokenId >> 96));
    }

    // Admin Functions :

    /**
     * @notice Updates the minimum percent required to buy a Boost
     * @param newMinPercRequired New minimum percent required to buy a Boost (in BPS)
     */
    function setMinPercRequired(uint256 newMinPercRequired) external onlyOwner {
        require(newMinPercRequired > 0 && newMinPercRequired <= 10000);
        minPercRequired = newMinPercRequired;
    }

        /**
     * @notice Updates the minimum delegation time
     * @param newMinDelegationTime New minimum deelgation time (in seconds)
     */
    function setMinDelegationTime(uint256 newMinDelegationTime) external onlyOwner {
        require(newMinDelegationTime > 0);
        minDelegationTime = newMinDelegationTime;
    }

    /**
     * @notice Updates the ratio of Fees set for the Reserve
     * @param newFeeReserveRatio New ratio (in BPS)
     */
    function setFeeReserveRatio(uint256 newFeeReserveRatio) external onlyOwner {
        require(newFeeReserveRatio <= 5000);
        feeReserveRatio = newFeeReserveRatio;
    }

    /**
     * @notice Updates the Delegation Boost (veBoost)
     * @param newDelegationBoost New veBoost contract address
     */
    function setDelegationBoost(address newDelegationBoost) external onlyOwner {
        delegationBoost = IVotingEscrowDelegation(newDelegationBoost);
    }

    /**
     * @notice Updates the Reserve Manager
     * @param newReserveManager New Reserve Manager address
     */
    function setReserveManager(address newReserveManager) external onlyOwner {
        reserveManager = newReserveManager;
    }

    /**
     * @notice Pauses the contract
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpauses the contract
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Block user fee claims
     */
    function blockClaim() external onlyOwner {
        require(
            !_claimBlocked,
            "Warden: Claim blocked"
        );
        _claimBlocked = true;
    }

    /**
     * @notice Unblock user fee claims
     */
    function unblockClaim() external onlyOwner {
        require(
            _claimBlocked,
            "Warden: Claim not blocked"
        );
        _claimBlocked = false;
    }

    /**
     * @dev Withdraw either a lost ERC20 token sent to the contract (expect the feeToken)
     * @param token ERC20 token to withdraw
     * @param amount Amount to transfer (in wei)
     */
    function withdrawERC20(address token, uint256 amount) external onlyOwner returns(bool) {
        require(_claimBlocked || token != address(feeToken), "Warden: cannot withdraw fee Token"); //We want to be able to recover the fees if there is an issue
        IERC20(token).safeTransfer(owner(), amount);

        return true;
    }

    function depositToReserve(address from, uint256 amount) external onlyAllowed returns(bool) {
        reserveAmount = reserveAmount + amount;
        feeToken.safeTransferFrom(from, address(this), amount);

        return true;
    }

    function withdrawFromReserve(uint256 amount) external onlyAllowed returns(bool) {
        require(amount <= reserveAmount, "Warden: Reserve too low");
        reserveAmount = reserveAmount - amount;
        feeToken.safeTransfer(reserveManager, amount);

        return true;
    }
}