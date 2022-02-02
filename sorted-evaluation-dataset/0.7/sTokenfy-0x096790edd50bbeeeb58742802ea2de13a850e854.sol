// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract sTokenfy is ERC20Upgradeable, OwnableUpgradeable {
    using SafeERC20 for IERC20;

    uint256 public rewardsEnd;
    uint256 public rewardsStart;

    uint256 public stakingRewards;

    IERC20 public tokenfyToken;

    function initialize(
        address tokenfy
    ) public initializer {
        __ERC20_init("sTokenfy", "sTKNFY");
        __Ownable_init_unchained();
        tokenfyToken = IERC20(tokenfy);
    }

    /*
     * @dev starts staking
     */
    function stake(uint256 tokenfyAmount) external {
        require(tokenfyAmount > 0, "sTokenfy: invalid amount");

        uint256 tokenfyPool = totalTokenfy();
        uint256 totalShares = totalSupply();

        tokenfyToken.safeTransferFrom(msg.sender, address(this), tokenfyAmount);

        if (totalShares == 0 || tokenfyPool == 0) {
            _mint(msg.sender, tokenfyAmount);
        } else {
            uint256 share = tokenfyAmount * totalShares / tokenfyPool;
            _mint(msg.sender, share);
        }
    }

    /*
     * @dev stops staking, withdraws share and rewards for share
     */
    function unstake(uint256 share) external {
        require(share > 0, "sTokenfy: invalid share");

        uint256 tokenfyPool = totalTokenfy();
        uint256 totalShares = totalSupply();

        _burn(msg.sender, share);

        uint256 tokenfyAmount = share * tokenfyPool / totalShares;
        tokenfyToken.safeTransfer(msg.sender, tokenfyAmount);
    }

    /*
     * @dev adds staking rewards
     */
    function addStakingRewards(uint256 tokenfyAmount) external {
        require(block.timestamp < rewardsEnd, "sTokenfy: can't add rewards");

        tokenfyToken.safeTransferFrom(msg.sender, address(this), tokenfyAmount);
        stakingRewards += tokenfyAmount;
    }

    /*
     * @dev starts new staking period
     */
    function startPeriod(uint256 newStart, uint256 newDuration) public onlyOwner {
        require(newStart >= block.timestamp, "sTokenfy: invalid start");
        require(newDuration > 0, "sTokenfy: invalid duration");

        require(rewardsEnd < block.timestamp, "sTokenfy: last reward period not ended");

        uint256 newRewardsEnd = newStart + newDuration;
        rewardsStart = newStart;
        rewardsEnd = newRewardsEnd;
        stakingRewards = 0;
    }

    /*
     * @dev calculates total tokenfy for distribution
     */
    function totalTokenfy() public view returns(uint256) {
        return tokenfyToken.balanceOf(address(this)) - remainingRewards();
    }

    /*
     * @dev calculates locked tokenfy
     */
    function remainingRewards() public view returns(uint256) {
        uint256 time = block.timestamp;
        uint256 remainingTime;
        uint256 duration = rewardsEnd - rewardsStart;

        if (time <= rewardsStart) {
            remainingTime = duration;
        } else if (time >= rewardsEnd) {
            remainingTime = 0;
        } else {
            remainingTime = rewardsEnd - time;
        }

        return remainingTime * stakingRewards / duration;
    }
    
}