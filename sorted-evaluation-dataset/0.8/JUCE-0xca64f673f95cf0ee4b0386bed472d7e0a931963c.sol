// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: JUCE FARM
/// @author: manifold.xyz

import "./ERC721Creator.sol";

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                                                                                                      //
//                                                                                                                                                                                                                      //
//                                                                                                                                                                                                                      //
//                                                                                                                                                                                                                      //
//           A true deflationary platform paying 1% daily ROI with compound interest options.  Sustainable through the tax on the TX this revolutionary platform will be one of the strongest platforms available.      //
//                                                                                                                                                                                                                      //
//                                                                                                                                                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


contract JUCE is ERC721Creator {
    constructor() ERC721Creator("JUCE FARM", "JUCE") {}
}