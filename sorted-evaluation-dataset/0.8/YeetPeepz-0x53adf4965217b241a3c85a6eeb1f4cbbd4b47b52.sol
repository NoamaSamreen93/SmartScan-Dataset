// SPDX-License-Identifier: MIT
// https://yeetpeepz.com
// Launches 1/11/22 @ 11:11:11 EST.
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

string constant _SIGNATURE_PREFIX = "\x19Ethereum Signed Message:\n32";
string constant _KEY = "Yeet Peepz Whitelist";
uint constant _MINTABLE_PER_TX = 100; // Max tokens available to be minted at once.

contract YeetPeepz is ERC721Enumerable, Ownable {
  using Strings for uint256;

  /**
   * Token IDs counter.
   *
   * Provides an auto-incremented ID for each token minted.
   */
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIDs;

  /**
   * Base URI.
   *
   * The base for relative IPFS paths.
   */
  string _baseURL;

  /**
   * Signer address
   *
   * Validation signature address.
   */
  address private _verificationSigner;

  /**
   * Mint fee.
   *
   * Cost to mint an NFT.
   */
  uint private _mintFee;

  /**
   * Launch timestamp.
   *
   * Prevents minting until the platform launches.
   */
  uint private _launchTimestamp;

  /**
   * Maximum token supply.
   *
   * Defines the total number of NFTs that can
   * ever be minted.
   *
   */
  uint private _maxSupply;

  /**
   * Whitelist allowance.
   *
   * Defines the number of tokens a user can claim
   * from the whitelist.
   */
  uint private _whitelistAllowance;

  /**
   * Minted whitelist.
   *
   * Mapping of address to number of whitelist mints.
   */
  mapping(address => uint) private _mintedWhitelist;

  /**
   * Constructor to deploy the contract.
   *
   * Sets the initial settings for the contract.
   */
  constructor(
    string memory _name,
    string memory _symbol,
    string memory __unrevealedBaseURI,
    address __verificationSigner,
    uint __mintFee,
    uint __maxSupply,
    uint __launchTimestamp,
    uint __whitelistAllowance
  ) ERC721(_name, _symbol) {
    _verificationSigner = __verificationSigner;
    _mintFee = __mintFee;
    _baseURL = __unrevealedBaseURI;
    _maxSupply = __maxSupply;
    _launchTimestamp = __launchTimestamp;
    _whitelistAllowance = __whitelistAllowance;
  }

  /**
   * Split Signature
   *
   * Validation utility
   */
  function _splitSignature(bytes memory sig) private pure returns (bytes32 r, bytes32 s, uint8 v) {
    require(sig.length == 65, "Invalid signature length.");

    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }
  }

  /**
   * Recover Signer
   *
   * Validation utility
   */
  function _recoverSigner(
    bytes32 _hash,
    bytes memory _sig
  ) private pure returns (address) {
    (bytes32 r, bytes32 s, uint8 v) = _splitSignature(_sig);

    return ecrecover(_hash, v, r, s);
  }

  /**
   * Get Message Hash
   *
   * Validation utility.
   */
  function _getMessageHash(
    address _to,
    string memory _key
  ) private pure returns (bytes32) {
    return keccak256(abi.encode(_to, _key));
  }

  /**
   * Signed message hash
   *
   * Validation utility.
   */
  function _signedMsgHash(bytes32 _hash) private pure returns (bytes32) {
    return keccak256(
      abi.encodePacked(_SIGNATURE_PREFIX, _hash)
    );
  }

  /**
   * Verify
   *
   * Validation utility.
   */
  function _verify(
    address _to,
    string memory _key,
    bytes memory _proof
  ) private view returns (bool) {
    bytes32 msgHash = _getMessageHash(_to, _key);
    bytes32 signedMsgHash = _signedMsgHash(msgHash);

    return _recoverSigner(signedMsgHash, _proof) == _verificationSigner;
  }

  /**
   * Contract metadata URI
   *
   * Provides the URI for the contract metadata.
   */
  function contractURI() public view returns (string memory) {
    return string(abi.encodePacked(_baseURI(), "0"));
  }

  /**
   * Override for the OpenZeppelin ERC721 baseURI function.
   *
   * All tokenURIs will use a t3rm.dev whoami base.
   */
  function _baseURI() internal view virtual override returns (string memory) {
    return _baseURL;
  }

  /**
   * Launch timestamp.
   *
   * Returns the launch date timestamp.
   */
  function launchTimestamp() public view returns (uint) {
    return _launchTimestamp;
  }

  /**
   * Maximum supply.
   *
   * Returns the maximum number of tokens that can ever
   * be minted.
   */
  function maxSupply() public view returns (uint) {
    return _maxSupply;
  }

  /**
   * Mint fee.
   *
   * Returns the fee to mint.
   */
  function mintFee() public view returns (uint) {
    return _mintFee;
  }

  /**
   * Mintable per tx.
   *
   * Returns the number of tokens that can be minted
   * in a single transaction.
   */
  function mintablePerTx() public pure returns (uint) {
    return _MINTABLE_PER_TX;
  }

  /**
   * Whitelist allowance.
   *
   * Returns the number of tokens that can be minted
   * for a whitelisted address.
   */
  function whitelistAllowance() public view returns (uint) {
    return _whitelistAllowance;
  }

  /**
   * Claimed.
   *
   * Returns the total tokens claimed from whitelist.
   */
  function claimed(address _receiver) public view returns (uint) {
    return _mintedWhitelist[_receiver];
  }

  /**
   * Mint whitelisted
   *
   * Waives the mintFee if the received is whitelisted.
   */
  function mintWhitelisted(address _receiver, uint _amount, bytes memory _proof) public payable returns (uint[] memory) {
    require(_verify(msg.sender, _KEY, _proof), "Unauthorized.");
    require(_amount <= _MINTABLE_PER_TX, "Exceeds mintable per tx limit.");
    require(_mintedWhitelist[_receiver] + _amount <= _whitelistAllowance, "Exceeds whitelist limit.");

    uint[] memory _mintedIds = new uint[](_amount);
    for (uint i = 0; i < _amount; i++) {
      require(totalSupply() < _maxSupply, "Max supply reached.");

      _tokenIDs.increment();
      uint tokenId = _tokenIDs.current();
      _mint(_receiver, tokenId);
      _mintedWhitelist[_receiver]++;
      _mintedIds[i] = tokenId;
    }

    return _mintedIds;
  }

  /**
   * Mint a token to an address.
   *
   * Requires payment of _mintFee.
   */
  function mintTo(address _receiver, uint _amount) public payable returns (uint[] memory) {
    require(block.timestamp >= _launchTimestamp, "Project hasn't launched.");
    require(msg.value >= _mintFee * _amount, "Requires minimum fee.");
    require(_amount <= _MINTABLE_PER_TX, "Exceeds mintable per tx limit.");

    uint[] memory _mintedIds = new uint[](_amount);
    for (uint i = 0; i < _amount; i++) {
      require(totalSupply() < _maxSupply, "Max supply reached.");

      _tokenIDs.increment();
      uint tokenId = _tokenIDs.current();
      _mint(_receiver, tokenId);
      _mintedIds[i] = tokenId;
    }

    return _mintedIds;
  }

  /**
   * Mint tokens to the sender.
   *
   * Requires payment of _mintFee.
   */
  function mint(uint _amount) public payable returns (uint[] memory) {
    return mintTo(msg.sender, _amount);
  }

  /**
   * Admin function: Update mint fee.
   *
   * Updates the _mintFee value.
   */
  function adminUpdateMintFee(uint _newMintFee) onlyOwner public {
    _mintFee = _newMintFee;
  }

  /**
   * Admin function: Update baseURL.
   *
   * Updates the _baseURL value.
   */
  function adminUpdateBaseURL(string memory _newBaseURL) onlyOwner public {
    _baseURL = _newBaseURL;
  }

  /**
   * Admin function: Update signer
   *
   * Updates the verification address.
   */
  function adminUpdateSigner(address _newSigner) public onlyOwner {
    _verificationSigner = _newSigner;
  }

  /**
   * Admin function: Update launch timestamp.
   *
   * Updates the launch timestamp.
   */
  function adminUpdateLaunchTimestamp(uint _newLaunchTimestamp) public onlyOwner {
    _launchTimestamp = _newLaunchTimestamp;
  }

  /**
   * Admin function: Update whitelist allowance.
   *
   * Updates the whitelist allowance.
   */
  function adminUpdateWhitelistAllowance(uint _newWhitelistAllowance) public onlyOwner {
    _whitelistAllowance = _newWhitelistAllowance;
  }

  /**
   * Admin function: Remove funds.
   *
   * Removes the distribution of funds out of the smart contract.
   */
  function removeFunds() external onlyOwner {
    uint256 funds = address(this).balance;
    uint256 aShare = funds * 33 / 100;
    (bool success1, ) = 0xB24dC90a223Bb190cD28594a1fE65029d4aF5b42.call{
      value: aShare
    }("");

    uint256 bShare = funds * 33 / 100;
    (bool success2, ) = 0x1589a76943f74241320a002C9642C77071021e55.call{
      value: bShare
    }("");

    (bool success, ) = owner().call{value: address(this).balance}("");
    require(
      success &&
      success1 &&
      success2,
      "Error sending funds."
    );
  }

  /**
   * Admin function: Remove remaining funds.
   *
   * Removes the remaining funds out of the smart contract.
   */
  function removeRemainingFunds() public onlyOwner {
    (bool success, ) = owner().call{value: address(this).balance}("");
    require(success, "Unable to remove remaining funds.");
  }
}