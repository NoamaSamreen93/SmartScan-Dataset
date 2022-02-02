// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: mko photography
/// @author: manifold.xyz

import "./ERC721Creator.sol";

///////////////////////////////////////////////////////////////////////
//                                                                   //
//                                                                   //
//      _   _   _     _   _   _   _   _   _   _   _   _   _   _      //
//     / \ / \ / \   / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \     //
//    ( m | k | o ) ( p | h | o | t | o | g | r | a | p | h | y )    //
//     \_/ \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/     //
//                                                                   //
//                                                                   //
///////////////////////////////////////////////////////////////////////


contract MKO is ERC721Creator {
    constructor() ERC721Creator("mko photography", "MKO") {}
}