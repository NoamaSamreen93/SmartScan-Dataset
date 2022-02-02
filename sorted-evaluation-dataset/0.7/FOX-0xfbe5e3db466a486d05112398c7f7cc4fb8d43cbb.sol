// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Rocket Fox
/// @author: manifold.xyz

import "./ERC721Creator.sol";

/////////////
//         //
//         //
//    ◤    //
//         //
//         //
/////////////


contract FOX is ERC721Creator {
    constructor() ERC721Creator("Rocket Fox", "FOX") {}
}