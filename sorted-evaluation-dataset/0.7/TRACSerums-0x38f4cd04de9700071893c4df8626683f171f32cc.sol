//  _________  _________   _______  __________
// /__     __\|    _____) /   .   \/    _____/
//    |___|   |___|\____\/___/ \___\________\

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

import "./ILBAC.sol";

contract TRACSerums is ERC1155Upgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
  using ECDSAUpgradeable for bytes32;

  bool public presaleActive;
  bool public publicSaleActive;

  string public constant name = "Milk Serums";
  string public constant symbol = "SERUM";

  uint128 public constant MINT_PRICE = 0.08 ether;

  uint8 private constant SKIM_MILK_ID = 0;
  uint8 private constant ONE_PERCENT_MILK_ID = 1;
  uint8 private constant TWO_PERCENT_MILK_ID = 2;
  uint8 private constant WHOLE_MILK_ID = 3;
  uint8 private constant MUTANT_MILK_ID = 4;

  uint16 private maxClaimMints;
  uint16 private maxPaidMints;
  uint16 private claimMints;
  uint16 private paidMints;
  uint16[5] private claimMilks;
  uint16[5] private paidMilks;

  ILBAC private lbac;
  address private verifier;
  mapping(uint16 => bool) private claimedTokens;
  mapping(address => uint16) private whitelistMints;

  address private trac;
  uint16[5] private supply;

  function initialize() public initializer { }

  function initExchange(address _trac, string memory _newuri) external onlyOwner {
    trac = _trac;
    _setURI(_newuri);

    supply = [4440, 2664, 888, 888, 8];
  }

  function totalSupply(uint256 id) external view returns (uint256) {
    require(id >= 0 && id < 5, "invalid token");
    return supply[id];
  }

  function burnBatch(address account, uint256[] calldata ids, uint256[] calldata amounts) external {
    require(msg.sender == trac, "unauthorized caller");
    require(tx.origin == account, "unauthorized account");

    for (uint8 i; i < ids.length; i++) {
      if (amounts[i] > 0) {
        supply[ids[i]] -= uint16(amounts[i]);
      }
    }

    _burnBatch(account, ids, amounts);
  }

  struct CheckResponse { uint16 tokenId; address owner; bool claimed; }

  function checkTokens(uint16[] calldata tokenIds) external view returns (CheckResponse[] memory checks) {
    checks = new CheckResponse[](tokenIds.length);
    for (uint16 i; i < tokenIds.length; i++) {
      uint16 tokenId = tokenIds[i];
      checks[i] = CheckResponse({
        tokenId: tokenId,
        owner: lbac.ownerOf(tokenId),
        claimed: claimedTokens[tokenId]
      });
    }
  }

  function checkOwnerOf(address owner) external view returns (CheckResponse[] memory checks) {
    uint256 tokenCount = lbac.balanceOf(owner);
    checks = new CheckResponse[](tokenCount);
    for (uint16 i; i < tokenCount; i++) {
      uint16 tokenId = uint16(lbac.tokenOfOwnerByIndex(owner, i));
      checks[i] = CheckResponse({
        tokenId: tokenId,
        owner: owner,
        claimed: claimedTokens[tokenId]
      });
    }
  }

  function getRemainingClaimMilks() external view returns (uint16[5] memory) {
    return [
      claimMilks[SKIM_MILK_ID],
      claimMilks[ONE_PERCENT_MILK_ID],
      claimMilks[TWO_PERCENT_MILK_ID],
      claimMilks[WHOLE_MILK_ID],
      claimMilks[MUTANT_MILK_ID]
    ];
  }

  function getRemainingPaidMilks() external view returns (uint16[5] memory) {
    return [
      paidMilks[SKIM_MILK_ID],
      paidMilks[ONE_PERCENT_MILK_ID],
      paidMilks[TWO_PERCENT_MILK_ID],
      paidMilks[WHOLE_MILK_ID],
      paidMilks[MUTANT_MILK_ID]
    ];
  }

  function getMintCounts() external view returns(uint16[2] memory) {
    return [ claimMints, paidMints ];
  }

  /**
   * Ennumerate tokens by owner.
   */
  function tokensOf(address owner) external view returns (uint16[5] memory) {
    return [
      uint16(balanceOf(owner, SKIM_MILK_ID)),
      uint16(balanceOf(owner, ONE_PERCENT_MILK_ID)),
      uint16(balanceOf(owner, TWO_PERCENT_MILK_ID)),
      uint16(balanceOf(owner, WHOLE_MILK_ID)),
      uint16(balanceOf(owner, MUTANT_MILK_ID))
    ];
  }

  /**
   * @notice returns the metadata uri for a given id
   *
   * @param id the card id to return metadata for
   */
  function uri(uint256 id) public view override returns (string memory) {
    require(id >= 0 && id < 5, "URI: nonexistent token");

    return string(abi.encodePacked(super.uri(0), StringsUpgradeable.toString(id)));
  }

  /**
   * Allows withdrawing funds.
   */
  function withdraw() external onlyOwner {
    uint256 balance = address(this).balance;
    payable(0x1Ff269813ECFff82cb608C32B8b37A08b7334339).transfer(balance * 30 / 100);
    payable(0x48987e3d27927c34E2Afe526c671352D68d69238).transfer(balance * 12 / 100);
    payable(0x3Efce8bd4903711D9C1393bDfE319Fe482085778).transfer(balance * 12 / 100);
    payable(0x37E8E5fCf5969A54eF86aBACA35EF6Cd2c8D5da4).transfer(balance * 12 / 100);
    payable(0x1c9A0a18a47BbB622b986b805483EC2192BE75BC).transfer(balance * 12 / 100);
    payable(0xbbaAf85F87aBC8B288925D5886FBc0DCB1ae8f57).transfer(balance * 12 / 100);
    payable(0x1F03D6222Be7E7f9a3EA1788bE2ffb601803E953).transfer(balance * 5  / 100);
    payable(0xF6D860F29326bac24306A6Fa623a357B93245213).transfer(balance * 5  / 100);
  }
}