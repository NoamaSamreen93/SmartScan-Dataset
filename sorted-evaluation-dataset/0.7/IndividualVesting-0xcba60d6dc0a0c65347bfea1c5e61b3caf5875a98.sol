//SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.8.0;

import "./interfaces/IVesting.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract IndividualVesting is IVesting, Ownable, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    uint256 private constant BLOCK_TIME = 13;
    uint256 private constant SECONDS_IN_SIX_MONTH = 182.5 * 60 * 60 * 24;
    uint256 public blockStart;
    uint256 public blockEnd;

    uint256 public blocksPerVesting;

    mapping(address => Investor) private investors;
    uint256 private totalLockedAmount;
    address public token;
    EnumerableSet.AddressSet private addressesInvestors;

    constructor(address _token, uint256 _blockStartLockup, address owner) {
        token = _token;
        blockStart = _blockStartLockup.add(SECONDS_IN_SIX_MONTH.div(BLOCK_TIME));
        blockEnd = blockStart.add((SECONDS_IN_SIX_MONTH.mul(3)).div(BLOCK_TIME));
        blocksPerVesting = blockEnd.sub(blockStart);
        transferOwnership(owner);
    }

    /// @notice Get the amount of tokens released to an investor.
    /// @param investor The address of the investor to check.
    function getReleasedAmount(address investor) external view override returns (uint256 amount){
        return investors[investor].releasedAmount;
    }

    /// @notice Get the amount of tokens to be releaseded to an investor.
    /// @param investor The address of the investor to check.
    function getLockedAmount(address investor) external view override returns (uint256 amount){
        return investors[investor].totalAmount.sub(investors[investor].releasedAmount);
    }

    /// @notice Get the total amount of tokens entitled to an investor, released and not released.
    /// @param investor The address of the investor to check.
    function getTotalAmount(address investor) external view returns (uint256 amount){
        return investors[investor].totalAmount;
    }

    /// @notice Get info about an investor.
    /// @param investor The address of the investor to check.
    function getInvestorInfo(address investor) external view returns (Investor memory amount){
        return investors[investor];
    }

    /// @notice Get the total amount of tokens to be released to all investors.
    function getTotalLockedAmount() external view override returns (uint256 amount){
        return totalLockedAmount;
    }

    /// @notice Get the total amount of tokens that are claimable by all investors at the current moment.
    function getTotalReleasableAmount() external view override returns (uint256 amount){
        uint256 arrayLength = addressesInvestors.length();
        uint256 totalReleasableAmount;
        for (uint256 i = 0; i < arrayLength; i++) {
            (uint256 amount,) = getReleasableAmount(addressesInvestors.at(i));
            totalReleasableAmount += amount;
        }
        return totalReleasableAmount;
    }

    /// @notice Lock an investor's tokens for 6 months more.
    /// @param investor The address of the investor to lock.
    function addLockedTime(address investor) public onlyOwner {
        require(block.number < blockStart, "Vesting was started");
        require(investors[investor].personalBlockStart == blockStart, "Locked time was added already");
        investors[investor].personalBlockStart = blockStart.add(SECONDS_IN_SIX_MONTH.div(BLOCK_TIME));
        investors[investor].personalBlockEnd = investors[investor].personalBlockStart.add((SECONDS_IN_SIX_MONTH.mul(3)).div(BLOCK_TIME));
        investors[investor].lastClaimedBlock = investors[investor].personalBlockStart;
    }

    /// @notice Get the amount of tokens that are claimable by an investor at the current moment.
    /// @param investor The address of the investor to check.
    /// @return amount The amount of claimable tokens.
    /// @return currentBlock Current block if the vesting has started, otherwise the block at which the vesting will start for the investor.
    function getReleasableAmount(address investor) public view override returns (uint256 amount, uint256 currentBlock){
        require(investors[investor].totalAmount > 0, "Investor does not exist or already claimed all tokens");
        currentBlock = block.number;
        require(currentBlock >= investors[investor].personalBlockStart, "Vesting does not start");
        if (currentBlock > investors[investor].personalBlockEnd) {
            currentBlock = investors[investor].personalBlockEnd;
        }
        amount = (currentBlock.sub(investors[investor].lastClaimedBlock)).mul(investors[investor].rewardPerBlock);
    }

    /// @notice Claim your currently available tokens.
    function claim() external override nonReentrant {
        require(investors[msg.sender].totalAmount > 0, "Investor does not exist or already claimed all tokens");
        (uint256 amount, uint256 currentBlock) = getReleasableAmount(msg.sender);
        investors[msg.sender].releasedAmount = investors[msg.sender].releasedAmount.add(amount);
        investors[msg.sender].lastClaimedBlock = currentBlock;
        totalLockedAmount = totalLockedAmount.sub(amount);
        IERC20(token).safeTransfer(msg.sender, amount);
        emit Claimed(msg.sender, amount);
    }

    /// @notice Add investors to the vesting. Only available to the owner.
    /// @param addresses Addresses of the investors to add.
    /// @param amounts Amounts of tokens entitled to the investors from the `addresses` parameter respectively.
    /// @param periods Periods for the investors from the `addresses` parameter respectively. Each period can be either `6` or `12`.
    function specifyInvestors(address[] calldata addresses, uint256[] calldata amounts, uint8[] calldata periods) external onlyOwner override nonReentrant {
        require(addresses.length == amounts.length, "The arrays is not equal");
        require(addresses.length > 0, "The arrays cannot be empty");
        for (uint256 i = 0; i < addresses.length; i++) {
            _addToInvestorsList(addresses[i], amounts[i], periods[i]);
        }
    }

    /// @notice Add a single investor to the vesting. Only available to the owner.
    /// @param investor The address of the investor to add.
    /// @param amount Amount of tokens entitled to the investor.
    /// @param period Period for the investor. Each period can be either `6` or `12`.
    function addInvestor(address investor, uint256 amount, uint8 period) external onlyOwner override nonReentrant {
        _addToInvestorsList(investor, amount, period);
    }

    function _addToInvestorsList(address investor, uint256 amount, uint8 period) private {
        require(investors[investor].totalAmount == 0, "Address is already exist");
        require(period == 6 || period == 12, "Invalid period specified");
        addressesInvestors.add(investor);
        investors[investor].totalAmount = amount;
        investors[investor].lastClaimedBlock = blockStart;
        investors[investor].rewardPerBlock = amount.div(blockEnd.sub(blockStart));
        investors[investor].personalBlockStart = blockStart;
        investors[investor].personalBlockEnd = blockEnd;
        if (period == 12) {
            addLockedTime(investor);
        }
        totalLockedAmount = totalLockedAmount.add(amount);
        require(IERC20(token).balanceOf(address(this)) >= totalLockedAmount, "Insufficient balance");
        emit InvestorAdded(investor, amount, period);
    }

    /// @notice Change an investor address in case he/she does not have access to his account anymore. Only available to the owner.
    /// @param oldAddress The old address of the investor.
    /// @param newAddress The new address of the investor.
    function changeInvestorAddress(address oldAddress, address newAddress) external onlyOwner override nonReentrant {
        require(investors[oldAddress].totalAmount > 0, "Address does not exist");
        require(investors[newAddress].totalAmount == 0, "New address is already exist");
        investors[newAddress] = investors[oldAddress];
        delete investors[oldAddress];
        addressesInvestors.remove(oldAddress);
        addressesInvestors.add(newAddress);
        emit InvestorChanged(oldAddress, newAddress);
    }

    function rescueERC20(address tokenToRescue) external onlyOwner {
        uint256 amount = IERC20(tokenToRescue).balanceOf(address(this));
        IERC20(tokenToRescue).safeTransfer(address(owner()), amount);
    }
}