// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Monoverse
/// @author: manifold.xyz

import "./ERC721Creator.sol";

//////////////////////////////////////////////////////////
//                                                      //
//                                                      //
//           __        __        ___  __   __   ___     //
//     |\/| /  \ |\ | /  \ \  / |__  |__) /__` |__      //
//     |  | \__/ | \| \__/  \/  |___ |  \ .__/ |___     //
//                                                      //
//                                                      //
//                                                      //
//////////////////////////////////////////////////////////


contract Monoverse is ERC721Creator {
    constructor() ERC721Creator("Monoverse", "Monoverse") {}
}