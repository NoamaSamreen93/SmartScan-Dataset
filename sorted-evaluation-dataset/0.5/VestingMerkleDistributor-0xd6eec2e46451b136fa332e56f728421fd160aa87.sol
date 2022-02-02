// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.5.16;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/lifecycle/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/cryptography/MerkleProof.sol";
import "../OwnableWhitelist.sol";

contract VestingMerkleDistributor is Pausable, OwnableWhitelist {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public constant msig = 0xF49440C1F012d041802b25A73e5B0B9166a75c02;

    address public token;
    uint256 public claimedTotal;

    mapping(address => uint256) public totalClaimedAmountByUser;
    mapping(uint256 => bytes32) public merkleRoots;

    uint256 timestampStart;
    uint256 weekOffset;

    event ClaimComplete(
      uint256 weekNum,
      uint256 index,
      address account,
      uint256 merkleTreeAmount,
      uint256 actualTransferAmount
    );

    constructor(address token_) public {
      token = token_;
      addPauser(msig);
      pause();
      claimedTotal = 0;
    }

    function setWeekParams(uint256 newTimestamp, uint256 newWeekOffset) public onlyOwner {
      timestampStart = newTimestamp;
      weekOffset = newWeekOffset;
    }

    function currentWeek() public view returns(uint256) {
      require(block.timestamp > timestampStart, "timestampStart incorrect");
      // block.timestamp is in seconds
      uint256 weekPassed = block.timestamp.sub(timestampStart).div(86400).div(7);
      return weekOffset.add(weekPassed);
    }

    function setMerkleRoots(
      uint256[] calldata newWeekNumbers,
      bytes32[] calldata merkleRoots_,
      bool forceOverwrite
     ) external onlyOwner {
        require(newWeekNumbers.length == merkleRoots_.length, "Length doesn't match");
        for(uint256 i = 0 ; i < newWeekNumbers.length ; i++) {
          require(merkleRoots[newWeekNumbers[i]] == bytes32(0) || forceOverwrite, "merkleRoot not empty, need to overwrite");
          merkleRoots[newWeekNumbers[i]] = merkleRoots_[i];
        }
    }

    function claim(uint256 curWeek, uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external whenNotPaused() {
      require(account != address(0), "empty account cannot be claimed.");
      require(curWeek == currentWeek(), "curWeek passed in doesn't match");
      bytes32 merkleRoot = merkleRoots[curWeek];
      require(merkleRoot != bytes32(0), "current merkle root is empty");
      // Verify the merkle proof.
      bytes32 node = keccak256(abi.encodePacked(index, account, amount));
      require(MerkleProof.verify(merkleProof, merkleRoot, node), 'MerkleDistributor: Invalid proof.');

      // the Merkle tree contains the cumulative amount (that includes already claimed amount)
      // so, we need to subtract it
      uint256 actualTransferAmount = amount.sub(totalClaimedAmountByUser[account]);
      require(actualTransferAmount > 0, "Nothing to claim");
      IERC20(token).safeTransfer(account, actualTransferAmount);
      claimedTotal = claimedTotal.add(actualTransferAmount);

      // update the total amount claimed
      totalClaimedAmountByUser[account] = amount;
      emit ClaimComplete(curWeek, index, account, amount, actualTransferAmount);
    }

    function collectDust(address _token, uint256 _amount) external onlyOwner {
      if (_token == address(0)) { // token address(0) = ETH
        address payable dest = address(uint160(owner()));
        dest.transfer(_amount);
      } else {
        IERC20(_token).safeTransfer(owner(), _amount);
      }
    }
}