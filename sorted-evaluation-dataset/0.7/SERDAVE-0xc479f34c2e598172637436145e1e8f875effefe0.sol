// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: SerDave Test
/// @author: manifold.xyz

import "./ERC1155Creator.sol";

///////////////////////////////////////////////////
//                                               //
//                                               //
//    Test ERC1155 smart contract for SerDave    //
//                                               //
//                                               //
///////////////////////////////////////////////////


contract SERDAVE is ERC1155Creator {
    constructor() ERC1155Creator() {}
}