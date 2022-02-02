//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

contract TwoChains is PaymentSplitter {

    constructor(address[] memory _payees, uint256[] memory _shares) PaymentSplitter(_payees, _shares) { }

}