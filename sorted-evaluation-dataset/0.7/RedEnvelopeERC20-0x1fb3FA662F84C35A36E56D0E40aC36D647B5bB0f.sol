// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IEnvelope.sol";

contract RedEnvelopeERC20 is Ownable, IEnvelope {

    // sigh https://github.com/ethereum/aleth/issues/1788
    struct ERC20Envelope {
        Envelope env;
        IERC20 token;
    }

    mapping(uint64 => ERC20Envelope) private idToEnvelopes;
    mapping(address => bool) public approvedTokens;

    function returnEnvelope(uint64 envelopeID) public nonReentrant {
        ERC20Envelope storage envERC20 = idToEnvelopes[envelopeID];
        require(envERC20.env.balance > 0, "balance cannot be zero");
        require(envERC20.env.creator == msg.sender, "We only return to the creator!");
        require(block.timestamp - envERC20.env.timestamp > 86400, "Need to wait for 1 day for the return!");
        address receiver = payable(envERC20.env.creator);
        IERC20 token = IERC20(envERC20.token);
        uint256 oldBalance = envERC20.env.balance;
        delete idToEnvelopes[envelopeID];
        SafeERC20.safeApprove(token, address(this), oldBalance);
        SafeERC20.safeTransferFrom(token, address(this), receiver, oldBalance);
    }

    function approveToken(address token) public onlyOwner {
        approvedTokens[token] = true;
    }

    function addEnvelope(uint64 envelopeID, address tokenAddr, uint256 value, uint16 numParticipants, uint8 passLength, uint256 minPerOpen, uint64[] memory hashedPassword) public nonReentrant {
        require(idToEnvelopes[envelopeID].env.balance == 0, "balance not zero");
        require(value > 0, "Trying to create zero balance envelope");
        require(approvedTokens[tokenAddr] == true, "We only allow certain tokens!");
        validateMinPerOpen(value, minPerOpen, numParticipants);

        // First try to transfer the ERC20 token
        IERC20 token = IERC20(tokenAddr);
        SafeERC20.safeTransferFrom(token, msg.sender, address(this), value);

        ERC20Envelope storage envelope = idToEnvelopes[envelopeID];
        envelope.env.minPerOpen = minPerOpen;
        envelope.env.numParticipants = numParticipants;
        envelope.env.creator = msg.sender;
        for (uint i=0; i < hashedPassword.length; i++) {
            envelope.env.passwords[hashedPassword[i]] = initStatus();
        }
        envelope.env.balance = value;
        envelope.token = token;
        envelope.env.passLength = passLength;
        envelope.env.timestamp = block.timestamp;
    }

    function openEnvelope(bytes calldata signature, uint64 envelopeID, string calldata unhashedPassword) public nonReentrant {
        require(recover(signature, unhashedPassword), "signature does not seem to be provided by signer");
        require(idToEnvelopes[envelopeID].env.balance > 0, "Envelope is empty");
        uint64 passInt64 = hashPassword(unhashedPassword);
        ERC20Envelope storage currentEnv = idToEnvelopes[envelopeID];

        // validate the envelope
        Status storage passStatus = currentEnv.env.passwords[passInt64];
        require(passStatus.initialized, "Invalid password!");
        require(!passStatus.claimed, "Password is already used");
        require(bytes(unhashedPassword).length == currentEnv.env.passLength, "password is incorrect length");

        // claim the password
        currentEnv.env.passwords[passInt64].claimed = true;
        address receiver = msg.sender;

        // currently withdrawl the full balance, turn this into something either true random or psuedorandom
        if (currentEnv.env.numParticipants == 1) {
            uint256 fullBalance = currentEnv.env.balance;
            currentEnv.env.balance = 0;
            SafeERC20.safeApprove(currentEnv.token, address(this), fullBalance);
            SafeERC20.safeTransferFrom(currentEnv.token, address(this), receiver, fullBalance);
            return;
        }
        uint256 moneyThisOpen = getMoneyThisOpen(
            receiver,
            currentEnv.env.balance,
            currentEnv.env.minPerOpen,
            currentEnv.env.numParticipants);
        currentEnv.env.numParticipants--;

        currentEnv.env.balance -= moneyThisOpen;
        SafeERC20.safeApprove(currentEnv.token, address(this), moneyThisOpen);
        SafeERC20.safeTransferFrom(currentEnv.token, address(this), receiver, moneyThisOpen);
    }
}