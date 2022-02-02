// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/EnumerableMap.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./interfaces/tokens/erc20permit-upgradeable/IERC20PermitUpgradeable.sol";

import "./interfaces/IPolicyBookRegistry.sol";
import "./interfaces/IBMICoverStaking.sol";
import "./interfaces/IContractsRegistry.sol";
import "./interfaces/IRewardsGenerator.sol";
import "./interfaces/ILiquidityMining.sol";
import "./interfaces/IPolicyBook.sol";
import "./interfaces/IBMIStaking.sol";
import "./interfaces/ILiquidityRegistry.sol";
import "./interfaces/IShieldMining.sol";

import "./tokens/ERC1155Upgradeable.sol";

import "./abstract/AbstractDependant.sol";
import "./abstract/AbstractSlasher.sol";

import "./Globals.sol";

contract BMICoverStaking is
    IBMICoverStaking,
    OwnableUpgradeable,
    ERC1155Upgradeable,
    AbstractDependant,
    AbstractSlasher
{
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using SafeMath for uint256;
    using Math for uint256;

    IERC20 public bmiToken;
    IPolicyBookRegistry public policyBookRegistry;
    IRewardsGenerator public rewardsGenerator;
    ILiquidityMining public liquidityMining;
    IBMIStaking public bmiStaking;
    ILiquidityRegistry public liquidityRegistry;

    mapping(uint256 => StakingInfo) public override _stakersPool; // nft index -> info
    uint256 internal _nftMintId; // next nft mint id

    mapping(address => EnumerableSet.UintSet) internal _nftHolderTokens; // holder -> nfts
    EnumerableMap.UintToAddressMap internal _nftTokenOwners; // index nft -> holder
    // new state post v2
    IShieldMining public shieldMining;

    event StakingNFTMinted(uint256 id, address policyBookAddress, address to);
    event StakingNFTBurned(uint256 id, address policyBookAddress);
    event StakingBMIProfitWithdrawn(
        uint256 id,
        address policyBookAddress,
        address to,
        uint256 amount
    );
    event StakingFundsWithdrawn(uint256 id, address policyBookAddress, address to, uint256 amount);
    event TokensRecovered(address to, uint256 amount);

    modifier onlyPolicyBooks() {
        require(policyBookRegistry.isPolicyBook(_msgSender()), "BDS: No access");
        _;
    }

    function __BMICoverStaking_init() external initializer {
        __Ownable_init();
        __ERC1155_init("");

        _nftMintId = 1;
    }

    function setDependencies(IContractsRegistry _contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {
        bmiToken = IERC20(_contractsRegistry.getBMIContract());
        rewardsGenerator = IRewardsGenerator(_contractsRegistry.getRewardsGeneratorContract());
        policyBookRegistry = IPolicyBookRegistry(
            _contractsRegistry.getPolicyBookRegistryContract()
        );
        liquidityMining = ILiquidityMining(_contractsRegistry.getLiquidityMiningContract());
        bmiStaking = IBMIStaking(_contractsRegistry.getBMIStakingContract());
        liquidityRegistry = ILiquidityRegistry(_contractsRegistry.getLiquidityRegistryContract());
        shieldMining = IShieldMining(_contractsRegistry.getShieldMiningContract());
    }

    /// @dev the output URI will be: "https://token-cdn-domain/<tokenId>"
    function uri(uint256 tokenId)
        public
        view
        override(ERC1155Upgradeable, IBMICoverStaking)
        returns (string memory)
    {
        return string(abi.encodePacked(super.uri(0), Strings.toString(tokenId)));
    }

    /// @dev this is a correct URI: "https://token-cdn-domain/"
    function setBaseURI(string calldata newURI) external onlyOwner {
        _setURI(newURI);
    }

    function recoverTokens() external onlyOwner {
        uint256 balance = bmiToken.balanceOf(address(this));

        bmiToken.transfer(_msgSender(), balance);

        emit TokensRecovered(_msgSender(), balance);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override {
        for (uint256 i = 0; i < ids.length; i++) {
            if (amounts[i] != 1) {
                // not an NFT
                continue;
            }

            if (from == address(0)) {
                // mint happened
                _nftHolderTokens[to].add(ids[i]);
                _nftTokenOwners.set(ids[i], to);
            } else if (to == address(0)) {
                // burn happened
                _nftHolderTokens[from].remove(ids[i]);
                _nftTokenOwners.remove(ids[i]);
            } else {
                // transfer happened
                _nftHolderTokens[from].remove(ids[i]);
                _nftHolderTokens[to].add(ids[i]);

                _nftTokenOwners.set(ids[i], to);

                _updateLiquidityRegistry(to, from, _stakersPool[ids[i]].policyBookAddress);
            }
        }
    }

    function _updateLiquidityRegistry(
        address to,
        address from,
        address policyBookAddress
    ) internal {
        liquidityRegistry.tryToAddPolicyBook(to, policyBookAddress);
        liquidityRegistry.tryToRemovePolicyBook(from, policyBookAddress);
    }

    function _mintStake(address staker, uint256 id) internal {
        _mint(staker, id, 1, ""); // mint NFT
    }

    function _burnStake(address staker, uint256 id) internal {
        _burn(staker, id, 1); // burn NFT
    }

    function _mintAggregatedNFT(
        address staker,
        address policyBookAddress,
        uint256[] memory tokenIds
    ) internal {
        require(policyBookRegistry.isPolicyBook(policyBookAddress), "BDS: Not a PB");

        uint256 totalBMIXAmount;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(ownerOf(tokenIds[i]) == _msgSender(), "BDS: Not a token owner");
            require(
                _stakersPool[tokenIds[i]].policyBookAddress == policyBookAddress,
                "BDS: NFTs from distinct origins"
            );

            totalBMIXAmount = totalBMIXAmount.add(_stakersPool[tokenIds[i]].stakedBMIXAmount);

            _burnStake(staker, tokenIds[i]);

            emit StakingNFTBurned(tokenIds[i], policyBookAddress);

            /// @dev should be enough
            delete _stakersPool[tokenIds[i]].policyBookAddress;
        }

        _mintStake(staker, _nftMintId);

        _stakersPool[_nftMintId] = StakingInfo(policyBookAddress, totalBMIXAmount);

        emit StakingNFTMinted(_nftMintId, policyBookAddress, staker);

        _nftMintId++;
    }

    function _mintNewNFT(
        address staker,
        uint256 bmiXAmount,
        address policyBookAddress
    ) internal {
        _mintStake(staker, _nftMintId);

        _stakersPool[_nftMintId] = StakingInfo(policyBookAddress, bmiXAmount);

        emit StakingNFTMinted(_nftMintId, policyBookAddress, staker);

        _nftMintId++;
    }

    function aggregateNFTs(address policyBookAddress, uint256[] calldata tokenIds)
        external
        override
    {
        require(tokenIds.length > 1, "BDS: Can't aggregate");

        _mintAggregatedNFT(_msgSender(), policyBookAddress, tokenIds);
        rewardsGenerator.aggregate(policyBookAddress, tokenIds, _nftMintId - 1); // nftMintId is changed, so -1
    }

    function stakeBMIX(uint256 bmiXAmount, address policyBookAddress) external override {
        _stakeBMIX(_msgSender(), bmiXAmount, policyBookAddress);
    }

    function stakeBMIXWithPermit(
        uint256 bmiXAmount,
        address policyBookAddress,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        _stakeBMIXWithPermit(_msgSender(), bmiXAmount, policyBookAddress, v, r, s);
    }

    function stakeBMIXFrom(address user, uint256 bmiXAmount) external override onlyPolicyBooks {
        _stakeBMIX(user, bmiXAmount, _msgSender());
    }

    function stakeBMIXFromWithPermit(
        address user,
        uint256 bmiXAmount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override onlyPolicyBooks {
        _stakeBMIXWithPermit(user, bmiXAmount, _msgSender(), v, r, s);
    }

    function _stakeBMIXWithPermit(
        address staker,
        uint256 bmiXAmount,
        address policyBookAddress,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        IERC20PermitUpgradeable(policyBookAddress).permit(
            staker,
            address(this),
            bmiXAmount,
            MAX_INT,
            v,
            r,
            s
        );

        _stakeBMIX(staker, bmiXAmount, policyBookAddress);
    }

    function _stakeBMIX(
        address user,
        uint256 bmiXAmount,
        address policyBookAddress
    ) internal {
        require(policyBookRegistry.isPolicyBook(policyBookAddress), "BDS: Not a PB");
        require(IPolicyBook(policyBookAddress).whitelisted(), "BDS: PB is not whitelisted");
        require(bmiXAmount > 0, "BDS: Zero tokens");

        uint256 stblAmount = IPolicyBook(policyBookAddress).convertBMIXToSTBL(bmiXAmount);

        IERC20(policyBookAddress).transferFrom(user, address(this), bmiXAmount);

        _mintNewNFT(user, bmiXAmount, policyBookAddress);
        rewardsGenerator.stake(policyBookAddress, _nftMintId - 1, stblAmount); // nftMintId is changed, so -1
    }

    function _transferProfit(uint256 tokenId, bool onlyProfit) internal {
        address policyBookAddress = _stakersPool[tokenId].policyBookAddress;
        uint256 totalProfit;

        if (onlyProfit) {
            totalProfit = rewardsGenerator.withdrawReward(policyBookAddress, tokenId);
        } else {
            totalProfit = rewardsGenerator.withdrawFunds(policyBookAddress, tokenId);
        }

        uint256 bmiStakingProfit =
            _getSlashed(totalProfit, liquidityMining.startLiquidityMiningTime());
        uint256 profit = totalProfit.sub(bmiStakingProfit);

        // transfer slashed bmi to the bmiStaking and add them to the pool
        bmiToken.transfer(address(bmiStaking), bmiStakingProfit);
        bmiStaking.addToPool(bmiStakingProfit);

        // transfer bmi profit to the user
        bmiToken.transfer(_msgSender(), profit);

        emit StakingBMIProfitWithdrawn(tokenId, policyBookAddress, _msgSender(), profit);
    }

    /// @param staker address of the staker account
    /// @param policyBookAddress addres of the policbook
    /// @param offset pagination start up place
    /// @param limit size of the listing page
    /// @param func callback function that returns a uint256
    /// @return total
    function _aggregateForEach(
        address staker,
        address policyBookAddress,
        uint256 offset,
        uint256 limit,
        function(uint256) view returns (uint256) func
    ) internal view returns (uint256 total) {
        bool nullAddr = policyBookAddress == address(0);

        require(nullAddr || policyBookRegistry.isPolicyBook(policyBookAddress), "BDS: Not a PB");

        uint256 to = (offset.add(limit)).min(balanceOf(staker)).max(offset);

        for (uint256 i = offset; i < to; i++) {
            uint256 nftIndex = tokenOfOwnerByIndex(staker, i);

            if (nullAddr || _stakersPool[nftIndex].policyBookAddress == policyBookAddress) {
                total = total.add(func(nftIndex));
            }
        }
    }

    function _transferForEach(address policyBookAddress, function(uint256) func) internal {
        require(policyBookRegistry.isPolicyBook(policyBookAddress), "BDS: Not a PB");

        uint256 stakerBalance = balanceOf(_msgSender());

        for (int256 i = int256(stakerBalance) - 1; i >= 0; i--) {
            uint256 nftIndex = tokenOfOwnerByIndex(_msgSender(), uint256(i));

            if (_stakersPool[nftIndex].policyBookAddress == policyBookAddress) {
                func(nftIndex);
            }
        }
    }

    function restakeBMIProfit(uint256 tokenId) public override {
        require(_stakersPool[tokenId].policyBookAddress != address(0), "BDS: Token doesn't exist");
        require(ownerOf(tokenId) == _msgSender(), "BDS: Not a token owner");

        uint256 totalProfit =
            rewardsGenerator.withdrawReward(_stakersPool[tokenId].policyBookAddress, tokenId);

        bmiToken.transfer(address(bmiStaking), totalProfit);
        bmiStaking.stakeFor(_msgSender(), totalProfit);
    }

    function restakeStakerBMIProfit(address policyBookAddress) external override {
        _transferForEach(policyBookAddress, restakeBMIProfit);
    }

    function withdrawBMIProfit(uint256 tokenId) public override {
        require(_stakersPool[tokenId].policyBookAddress != address(0), "BDS: Token doesn't exist");
        require(ownerOf(tokenId) == _msgSender(), "BDS: Not a token owner");

        _transferProfit(tokenId, true);
    }

    function withdrawStakerBMIProfit(address policyBookAddress) external override {
        _transferForEach(policyBookAddress, withdrawBMIProfit);

        if (policyBookRegistry.isUserLeveragePool(policyBookAddress)) {
            shieldMining.getRewardFor(_msgSender(), policyBookAddress);
        } else {
            shieldMining.getRewardFor(_msgSender(), policyBookAddress, address(0));
        }
    }

    function withdrawFundsWithProfit(uint256 tokenId) public override {
        address policyBookAddress = _stakersPool[tokenId].policyBookAddress;

        require(policyBookAddress != address(0), "BDS: Token doesn't exist");
        require(ownerOf(tokenId) == _msgSender(), "BDS: Not a token owner");

        _transferProfit(tokenId, false);

        uint256 stakedFunds = _stakersPool[tokenId].stakedBMIXAmount;

        // transfer bmiX from staking to the user
        IERC20(policyBookAddress).transfer(_msgSender(), stakedFunds);

        emit StakingFundsWithdrawn(tokenId, policyBookAddress, _msgSender(), stakedFunds);

        _burnStake(_msgSender(), tokenId);

        emit StakingNFTBurned(tokenId, policyBookAddress);

        delete _stakersPool[tokenId];
    }

    function withdrawStakerFundsWithProfit(address policyBookAddress) external override {
        _transferForEach(policyBookAddress, withdrawFundsWithProfit);
    }

    /// @dev returns percentage multiplied by 10**25
    function getSlashingPercentage() external view override returns (uint256) {
        return getSlashingPercentage(liquidityMining.startLiquidityMiningTime());
    }

    function getSlashedBMIProfit(uint256 tokenId) public view override returns (uint256) {
        return _applySlashing(getBMIProfit(tokenId), liquidityMining.startLiquidityMiningTime());
    }

    /// @notice retrieves the BMI profit of a tokenId
    /// @param tokenId numeric id identifier of the token
    /// @return profit amount
    function getBMIProfit(uint256 tokenId) public view override returns (uint256) {
        return rewardsGenerator.getReward(_stakersPool[tokenId].policyBookAddress, tokenId);
    }

    function getSlashedStakerBMIProfit(
        address staker,
        address policyBookAddress,
        uint256 offset,
        uint256 limit
    ) external view override returns (uint256 totalProfit) {
        uint256 stakerBMIProfit = getStakerBMIProfit(staker, policyBookAddress, offset, limit);

        return _applySlashing(stakerBMIProfit, liquidityMining.startLiquidityMiningTime());
    }

    function getStakerBMIProfit(
        address staker,
        address policyBookAddress,
        uint256 offset,
        uint256 limit
    ) public view override returns (uint256) {
        return _aggregateForEach(staker, policyBookAddress, offset, limit, getBMIProfit);
    }

    function totalStaked(address user) external view override returns (uint256) {
        return _aggregateForEach(user, address(0), 0, MAX_INT, stakedByNFT);
    }

    function totalStakedSTBL(address user) external view override returns (uint256) {
        return _aggregateForEach(user, address(0), 0, MAX_INT, stakedSTBLByNFT);
    }

    function stakedByNFT(uint256 tokenId) public view override returns (uint256) {
        return _stakersPool[tokenId].stakedBMIXAmount;
    }

    function stakedSTBLByNFT(uint256 tokenId) public view override returns (uint256) {
        return rewardsGenerator.getStakedNFTSTBL(tokenId);
    }

    /// @notice returns number of NFTs on user's account
    function balanceOf(address user) public view override returns (uint256) {
        return _nftHolderTokens[user].length();
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _nftTokenOwners.get(tokenId);
    }

    function tokenOfOwnerByIndex(address user, uint256 index)
        public
        view
        override
        returns (uint256)
    {
        return _nftHolderTokens[user].at(index);
    }
}