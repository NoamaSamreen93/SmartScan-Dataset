// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.0;

import "./Ownable.sol";
import "./ITransferController.sol";

//implementation to control transfer of q2

contract TransferController is ITransferController, Ownable {
    mapping(address => bool) public whitelistedAddresses;

    mapping(address => bool) moderator;

    // add addresss to transfer q2
    function addAddressToWhiteList(address[] memory _users, bool status)
        public
        override
        returns (bool isWhitelisted)
    {
        require(msg.sender == owner || moderator[msg.sender]);
        for (uint256 x = 0; x < _users.length; x++) {
            if (!isWhiteListed(_users[x])) {
                whitelistedAddresses[_users[x]] = status;
            }
        }

        return true;
    }

    function isWhiteListed(address _user) public view override returns (bool) {
        return whitelistedAddresses[_user];
    }

    function addModerator(address _user, bool status) public onlyOwner {
        moderator[_user] = status;
    }
}