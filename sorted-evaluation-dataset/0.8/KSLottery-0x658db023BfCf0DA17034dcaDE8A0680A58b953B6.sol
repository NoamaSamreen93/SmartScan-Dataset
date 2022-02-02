// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * #    #
 * #   #  #####  #   # #####  #####  ####   ####  #  ####  #    #
 * #  #   #    #  # #  #    #   #   #    # #      # #    # ##   #
 * ###    #    #   #   #    #   #   #    #  ####  # #      # #  #
 * #  #   #####    #   #####    #   #    #      # # #  ### #  # #
 * #   #  #   #    #   #        #   #    # #    # # #    # #   ##
 * #    # #    #   #   #        #    ####   ####  #  ####  #    #
 *
 * @title Lottery contract for Kryptosign
 * @dev This contract picks a winner for kryptosign's lottery
 *
 *
 * BLOCK::BLOCK
 *
 * Smart contract work done by Mathieu Rivier
 */

contract KSLottery is VRFConsumerBase, Ownable {
  using SafeMath for uint256;
  using ECDSA for bytes32;

  uint256 NULL = 0;

  // @dev keeps track of a given document's status
  enum LotteryStatus {
    IN_PROGRESS,
    COMPLETED
  }

  // @dev Holds all the Lottery related data
  struct Lottery {
    LotteryStatus status;
    uint256 winner;
  }

  // @dev Holds all the documents data, including a Lottery instance
  struct Document {
    string documentId;
    uint256 nbSigners;
    Lottery lottery;
  }

  mapping(string => bytes32) internal requestIds;
  mapping(bytes32 => Document) internal documents;

  event RequestWinner(string documentId, bytes signature);
  event ReturnWinner(string documentId, uint256 result);

  bytes32 private chainlinkKeyHash;
  address internal signedVerifier;

  uint256 internal price;
  uint256 internal linkFee;

  constructor(
    address chainlinkCoordinator,
    address chainlinkLinkToken,
    bytes32 _chainlinkKeyHash,
    address _signedVerifier
  ) VRFConsumerBase(chainlinkCoordinator, chainlinkLinkToken) {
    chainlinkKeyHash = _chainlinkKeyHash;
    signedVerifier = _signedVerifier;

    price = 0.05 ether;
    linkFee = 2000000000000000000;
  }

  // @dev retruns a signing hash used to the user is who they say they are
  // @param documentId - id passed in from front-end
  // @param nbSigners - number of signers of the document
  function getLoterySigningHash(string memory documentId, uint256 nbSigners)
    public
    view
    returns (bytes32)
  {
    return keccak256(abi.encodePacked(documentId, nbSigners));
  }

  // @dev verifies that the signature is original
  // @param signature - the result of @requestWinnerSigningHash
  // @param documentId - id passed in from front-end
  // @param nbSigners - number of signers of the document
  function verifySignature(
    bytes memory signature,
    string memory documentId,
    uint256 nbSigners
  ) internal view returns (bool) {
    bytes32 signingHash = getLoterySigningHash(documentId, nbSigners)
      .toEthSignedMessageHash();
    address recoveredSig = ECDSA.recover(signingHash, signature);

    return recoveredSig == signedVerifier;
  }

  // @dev Request a winner for the document
  // @param signature - the result of @getLoterySigningHash
  // @param documentId - id passed in from front-end
  // @param nbSigners - number of signers of the document
  function runLottery(
    bytes memory signature,
    string memory documentId,
    uint256 nbSigners
  ) public payable {
    require(msg.value == price, "Wrong ETH amount sent");
    require(
      verifySignature(signature, documentId, nbSigners),
      "Signer verification failed"
    );
    require(
      requestIds[documentId] == 0,
      "A winner already exists for this document"
    );
    require(
      LINK.balanceOf(address(this)) >= linkFee,
      "Please contact B::B - add LINK to the contract"
    );

    bytes32 requestId = requestRandomness(chainlinkKeyHash, linkFee);
    requestIds[documentId] = requestId;

    documents[requestIds[documentId]] = Document(
      documentId,
      nbSigners,
      Lottery(LotteryStatus.IN_PROGRESS, NULL)
    );

    emit RequestWinner(documentId, signature);
  }

  // @dev What actually makes the randmoness call
  //   chainlink's callback function.
  //   sets the random value returned by chainlink
  // @param requestId value created in runLottery
  // @param randomness thing for chainlink
  function fulfillRandomness(bytes32 requestId, uint256 randomness)
    internal
    override
  {
    Document storage document = documents[requestId];

    document.lottery.winner = randomness.mod(document.nbSigners).add(1);
    document.lottery.status = LotteryStatus.COMPLETED;

    emit ReturnWinner(document.documentId, document.lottery.winner);
  }

  // @dev Get the lottery winner once the winner has been chosen
  // @params documentId the documentId from front end to get the winner for.
  function getLotteryWinner(string memory documentId)
    public
    view
    returns (Lottery memory)
  {
    require(
      requestIds[documentId] != 0,
      "Please run a lottery before requesting Winner"
    );
    require(
      documents[requestIds[documentId]].lottery.status ==
        LotteryStatus.COMPLETED,
      "Lottery run in progress"
    );

    return documents[requestIds[documentId]].lottery;
  }

  // Maintenance Functions

  // @dev Get the current signed verifier
  function getSignedVerifier() public view returns (address) {
    return signedVerifier;
  }

  // @dev Set a new signed verifier to use for signing verification (verify)
  // @param _signedVerifier the new signed verifier address
  function setSignedVerifier(address _signedVerifier) external onlyOwner {
    signedVerifier = _signedVerifier;
  }

  // @dev Get the current price of the contract
  function getPrice() public view returns (uint256) {
    return price;
  }

  // @dev Set new contract ETH price
  // @params _price is the new contract price
  function setPrice(uint256 _price) external onlyOwner {
    price = _price;
  }

  // @dev get current LINK fee from contract
  function getLinkFee() public view returns (uint256) {
    return linkFee;
  }

  // @dev Update LINK fee for contract
  // @param _linkFee the new LINK fee
  function setLinkFee(uint256 _linkFee) external onlyOwner {
    linkFee = _linkFee;
  }

  // @dev Withdraw ETH from contract
  function withdrawEth() external onlyOwner {
    uint256 balance = address(this).balance;
    payable(msg.sender).transfer(balance);
  }

  // @dev Withdraw LINK from contract
  function withdrawLink() external onlyOwner {
    require(
      LINK.transfer(msg.sender, LINK.balanceOf(address(this))),
      "Unable to transfer LINK"
    );
  }
}