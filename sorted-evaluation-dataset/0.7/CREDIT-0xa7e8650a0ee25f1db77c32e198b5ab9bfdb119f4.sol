//  _________  _________   _______  __________
// /__     __\|    _____) /   .   \/    _____/
//    |___|   |___|\____\/___/ \___\________\

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import "./ITRAC.sol";

contract CREDIT is ERC20Upgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {

  uint128 constant private REWARD_PER_SECOND = 8 ether / uint128(60 * 60 * 24);

  bool public claimPaused;
  uint128 public globalRewardsClaimed;

  struct RewardSummary {
    uint16[] tokens;
    uint128 claimableReward;
    uint128 totalClaimed;
    uint48 lastClaimTimestamp;
    uint128 globalRewardsClaimed;
    uint256 balance;
  }

  struct OwnerRewards { uint128 totalClaimed; uint48 lastClaim; }
  mapping(address => OwnerRewards) public ownerRewards;
  ITRAC private _trac;
  
  event ClaimReward(address owner, uint128 reward);

  function initialize(address trac, address community) public initializer {
    __ERC20_init_unchained("TRAC CREDIT", "CREDIT");
    __Ownable_init_unchained();
    __ReentrancyGuard_init_unchained();

    _mint(address(this), 355555556 ether);
    _mint(community, 88888888 ether);

    _trac = ITRAC(trac);
  }

  function toggleClaims() public onlyOwner {
    claimPaused = !claimPaused;
  }

  function summaryOf(address account) external view returns (RewardSummary memory summary) {
    ITRAC.TokenTime[] memory tokenTimes = _trac.tokenTimesOf(account);
    uint16[] memory tokens = new uint16[](tokenTimes.length);
    uint48 blockTimestamp = uint48(block.timestamp);
    uint48 lastClaim = ownerRewards[account].lastClaim;

    uint128 rewardSeconds;
    for (uint16 i; i < tokenTimes.length; i++) {
      tokens[i] = tokenTimes[i].token;
      uint48 rewardStart = tokenTimes[i].timestamp;
      if (lastClaim > rewardStart) {
        rewardStart = lastClaim;
      }
      rewardSeconds += blockTimestamp - rewardStart;
    }

    // Calculate summary
    summary = RewardSummary(
      tokens,
      rewardSeconds * REWARD_PER_SECOND,
      ownerRewards[account].totalClaimed,
      lastClaim,
      globalRewardsClaimed,
      balanceOf(account)
    );
  }

  function claimRewards(uint16[] calldata tokens) external nonReentrant {
    require(tx.origin == msg.sender, "eos only");
    require(!claimPaused, "claim paused");

    uint48 lastClaim = ownerRewards[msg.sender].lastClaim;
    ITRAC.OwnerTime[] memory tokenTimes = _trac.ownerTimesOf(tokens);
    uint48 blockTimestamp = uint48(block.timestamp);
    uint48 vestedSeconds;

    for (uint16 i; i < tokenTimes.length; i++) {
      require(tokenTimes[i].owner == msg.sender, "not owner");
      uint48 rewardStart = tokenTimes[i].timestamp;
      if (lastClaim > rewardStart) {
        rewardStart = lastClaim;
      }
      vestedSeconds += blockTimestamp - rewardStart;
    }

    uint128 reward = vestedSeconds * REWARD_PER_SECOND;
    ownerRewards[msg.sender] = OwnerRewards(
      ownerRewards[msg.sender].totalClaimed + reward,
      blockTimestamp
    );

    globalRewardsClaimed += reward;
    emit ClaimReward(msg.sender, reward);
    _transfer(address(this), msg.sender, reward);
  }

  struct Snapshot { address account; uint16 token; uint128 claimableReward; uint128 totalClaimed; }
  function snapshotBalances(uint16 start, uint16 size, uint48 timestamp) external view onlyOwner returns (Snapshot[] memory snaps) {
    uint16[] memory tokens = new uint16[](size);
    for (uint16 i; i < size; i++) {
      tokens[i] = i + start;
    }

    snaps = new Snapshot[](size);
    ITRAC.OwnerTime[] memory ownerTimes = _trac.ownerTimesOf(tokens);
    for (uint16 i; i < size; i++) {
      address account = ownerTimes[i].owner;
      uint128 totalClaimed = ownerRewards[account].totalClaimed;
      uint48 lastClaim = ownerRewards[account].lastClaim;
      uint48 rewardStart = ownerTimes[i].timestamp;
      if (lastClaim > rewardStart) {
        rewardStart = lastClaim;
      }
      uint48 untilTimestamp = timestamp;
      if (rewardStart > untilTimestamp) {
        untilTimestamp = rewardStart;
      }
      uint128 reward = (untilTimestamp - rewardStart) * REWARD_PER_SECOND;

      snaps[i] = Snapshot(account, tokens[i], reward, totalClaimed);
    }
  }
}