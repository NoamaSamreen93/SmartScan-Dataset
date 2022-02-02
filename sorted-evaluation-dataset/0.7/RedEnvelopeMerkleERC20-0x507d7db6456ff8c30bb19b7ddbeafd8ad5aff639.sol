// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./IEnvelope.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RedEnvelopeMerkleERC20 is IEnvelope {
    using Bits for uint8;

    struct MerkleERC20Envelope {
        uint256 balance;
        uint256 minPerOpen;
        // we need a Merkle roots, to
        // keep track of claimed passwords,
        bytes32 unclaimedPasswords;
        // we will keep a bitset for used passwords
        uint8[] isPasswordClaimed;
        address creator;
        uint16 numParticipants;
        IERC20 token;
    }

    mapping(string => MerkleERC20Envelope) private idToEnvelopes;
    mapping(address => bool) public approvedTokens;

    function returnEnvelope(string calldata envelopeID) public nonReentrant {
        MerkleERC20Envelope storage env = idToEnvelopes[envelopeID];
        require(env.balance > 0, "Balance should be larger than zero");
        require(
            env.creator == msg.sender,
            "We will only return to the creator!"
        );
        IERC20 token = IERC20(env.token);
        address receiver = payable(env.creator);
        uint256 oldBalance = env.balance;
        delete idToEnvelopes[envelopeID];
        SafeERC20.safeApprove(token, address(this), oldBalance);
        SafeERC20.safeTransferFrom(token, address(this), receiver, oldBalance);
    }

    function approveToken(address token) public onlyOwner {
        approvedTokens[token] = true;
    }

    function addEnvelope(
        string calldata envelopeID,
        address tokenAddr,
        uint256 value,
        uint16 numParticipants,
        uint256 minPerOpen,
        bytes32 hashedMerkelRoot,
        uint32 bitarraySize
    ) public nonReentrant {
        require(idToEnvelopes[envelopeID].balance == 0, "balance not zero");
        require(value > 0, "Trying to create zero balance envelope");
        require(approvedTokens[tokenAddr] == true, "We only allow certain tokens!");
        validateMinPerOpen(value, minPerOpen, numParticipants);

        // First try to transfer the ERC20 token
        IERC20 token = IERC20(tokenAddr);
        SafeERC20.safeTransferFrom(token, msg.sender, address(this), value);

        MerkleERC20Envelope storage envelope = idToEnvelopes[envelopeID];
        envelope.minPerOpen = minPerOpen;
        envelope.numParticipants = numParticipants;
        envelope.creator = msg.sender;
        envelope.unclaimedPasswords = hashedMerkelRoot;
        envelope.balance = value;
        envelope.isPasswordClaimed = new uint8[](bitarraySize / 8 + 1);
        envelope.token = token;
    }

    function openEnvelope(
        bytes calldata signature,
        string calldata envelopeID,
        bytes32[] calldata proof,
        bytes32 leaf
    ) public nonReentrant {
        require(
            idToEnvelopes[envelopeID].balance > 0,
            "Envelope cannot be empty"
        );
        require(recover(signature, leaf), "signature does not seem to be provided by signer");
        MerkleERC20Envelope storage currentEnv = idToEnvelopes[envelopeID];

        // First check if the password has been claimed
        uint256 bitarrayLen = currentEnv.isPasswordClaimed.length;
        uint32 idx = uint32(uint256(leaf) % bitarrayLen);
        uint32 bitsetIdx = idx / 8;
        uint8 positionInBitset = uint8(idx % 8);
        uint8 curBitSet = currentEnv.isPasswordClaimed[bitsetIdx];
        require(curBitSet.bit(positionInBitset) == 0, "password already used!");

        // Now check if it is a valid password
        bool isUnclaimed = MerkleProof.verify(
            proof,
            currentEnv.unclaimedPasswords,
            leaf
        );
        require(isUnclaimed, "password need to be valid!");

        // claim the password
        currentEnv.isPasswordClaimed[bitsetIdx].setBit(positionInBitset);

        // currently withdrawl the full balance, turn this into something either true random or psuedorandom
        if (currentEnv.numParticipants == 1) {
            uint256 oldBalance = currentEnv.balance;
            SafeERC20.safeApprove(currentEnv.token, address(this), oldBalance);
            SafeERC20.safeTransferFrom(currentEnv.token, address(this), msg.sender, oldBalance);
            currentEnv.balance = 0;
            return;
        }

        uint256 moneyThisOpen = getMoneyThisOpen(
            msg.sender,
            currentEnv.balance,
            currentEnv.minPerOpen,
            currentEnv.numParticipants
        );

        currentEnv.numParticipants--;
        currentEnv.balance -= moneyThisOpen;
        SafeERC20.safeApprove(currentEnv.token, address(this), moneyThisOpen);
        SafeERC20.safeTransferFrom(currentEnv.token, address(this), msg.sender, moneyThisOpen);
    }
}