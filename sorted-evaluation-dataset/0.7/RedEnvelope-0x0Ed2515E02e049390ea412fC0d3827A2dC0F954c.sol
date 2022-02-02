// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./IEnvelope.sol";

contract RedEnvelope is IEnvelope {

    mapping(uint64 => Envelope) private idToEnvelopes;

    function returnEnvelope(uint64 envelopeID) public nonReentrant {
        Envelope storage env = idToEnvelopes[envelopeID];
        require(env.balance > 0, "Balance should be larger than zero");
        require(env.creator == msg.sender, "We only return to the creator!");
        require(block.timestamp - env.timestamp > 86400, "Need to wait for 1 day for the return!");
        address payable receiver = payable(env.creator);
        uint256 oldBalance = env.balance;
        delete idToEnvelopes[envelopeID];
        receiver.call{value: oldBalance}("");
    }

    function addEnvelope(
        uint64 envelopeID,
        uint16 numParticipants,
        uint8 passLength,
        uint256 minPerOpen,
        uint64[] calldata hashedPassword
    ) payable public nonReentrant {
        require(idToEnvelopes[envelopeID].balance == 0, "balance not zero");
        require(msg.value > 0, "Trying to create zero balance envelope");
        validateMinPerOpen(msg.value, minPerOpen, numParticipants);

        Envelope storage envelope = idToEnvelopes[envelopeID];
        envelope.passLength = passLength;
        envelope.minPerOpen = minPerOpen;
        envelope.numParticipants = numParticipants;
        envelope.creator = msg.sender;
        envelope.timestamp = block.timestamp;
        for (uint i=0; i < hashedPassword.length; i++) {
            envelope.passwords[hashedPassword[i]] = initStatus();
        }
        envelope.balance = msg.value;
    }

    function openEnvelope(bytes calldata signature, uint64 envelopeID, string calldata unhashedPassword) public nonReentrant {
        require(recover(signature, unhashedPassword), "signature does not seem to be provided by signer");
        require(idToEnvelopes[envelopeID].balance > 0, "Envelope is empty");
        uint64 passInt64 = hashPassword(unhashedPassword);
        Envelope storage currentEnv = idToEnvelopes[envelopeID];
        Status storage passStatus = currentEnv.passwords[passInt64];
        require(passStatus.initialized, "Invalid password!");
        require(!passStatus.claimed, "Password is already used");
        require(bytes(unhashedPassword).length == currentEnv.passLength, "password is incorrect length");

        // claim the password
        currentEnv.passwords[passInt64].claimed = true;
        address payable receiver = payable(msg.sender);

        // currently withdrawl the full balance, turn this into something either true random or psuedorandom
        if (currentEnv.numParticipants == 1) {
            uint256 oldBalance = currentEnv.balance;
            currentEnv.balance = 0;
            receiver.call{value: oldBalance}("");
            return;
        }

        uint256 moneyThisOpen = getMoneyThisOpen(
            receiver,
            currentEnv.balance,
            currentEnv.minPerOpen,
            currentEnv.numParticipants);
        
        currentEnv.numParticipants--;
        currentEnv.balance -= moneyThisOpen;
        receiver.call{value: moneyThisOpen}("");
    }
}