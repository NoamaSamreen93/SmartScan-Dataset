// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Permissions} from "./Permissions.sol";


contract VestedPendleDistribution is Permissions {
    using SafeERC20 for IERC20;

    IERC20 internal constant ETH_TOKEN_ADDRESS = IERC20(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );

    constructor(address _admin) Permissions(_admin) {}

    receive() external payable {}

    function distributeToOne(
        address payable user,
        IERC20 token,
        uint256 amount
    ) public onlyDistributor {
        require(user != address(0), "user cannot be zero address");
        require(address(token) != address(0), "token cannot be zero address");
        require(amount > 0, "amount is 0");

        if (token == ETH_TOKEN_ADDRESS) {
            require(address(this).balance >= amount, "eth amount required > balance");
            (bool success, ) = user.call{value: amount}("");
            require(success, "send to user failed");
        } else {
            require(token.balanceOf(address(this)) >= amount, "token amount required > balance");
            token.safeTransfer(user, amount);
        }
    }

    function distributeToMany(
        address[] calldata users,
        IERC20 token,
        uint256[] calldata amounts
    ) public onlyDistributor {
        require(users.length == amounts.length, "length mismatch");

        for (uint256 i = 0; i < users.length; i++) {
            distributeToOne(payable(users[i]), token, amounts[i]);
        }
    }
}