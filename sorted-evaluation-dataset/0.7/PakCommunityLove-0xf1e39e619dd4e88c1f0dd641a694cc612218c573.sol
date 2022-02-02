// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
////////MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM////////
////////MMMMMMMMMMMMMMMN0xl;'.        .';cd0NMMMMMMMMMMMMMMM////////
////////MMMMMMMMMMMMNOl,.                  .,lONMMMMMMMMMMMM////////
////////MMMMMMMMMMXx;.                        .,xXMMMMMMMMMM////////
////////MMMMMMMMWO;                              ;OWMMMMMMMM////////
////////MMMMMMMNd.                                .dNMMMMMMM////////
////////MMMMMMNo.                   .',,.          .oNMMMMMM////////
////////MMMMMMx.                  .,xxlokl.         .xMMMMMM////////
////////MMMMMM,           ':cc;. ,dko.  :O:          ,MMMMMM////////
////////MMMMMM.          ,kl,;ldokXx.   :k;          .MMMMMM////////
////////MMMMMM           'xl   .:xOc   ,xl.           MMMMMM////////
////////MMMMMM            ,dl.    .   ;xl.            MMMMMM////////
////////MMMMMM.            .ld;.    .lx:             .MMMMMM////////
////////MMMMMMl              ,oo;'.;xo.              cMMMMMM////////
////////MMMMMMK;               'cool,               ,KMMMMMM////////
////////MMMMMMM0;                                  ,0MMMMMMM////////
////////MMMMMMMMKc.                              .cKMMMMMMMM////////
////////MMMMMMMMMNk;.                           ,kNMMMMMMMMM////////
////////MMMMMMMMMMWNk:.                      .:kNWMMMMMMMMMM////////
////////MMMMMMMMMMMMMWKxc,.              .,cxKWMMMMMMMMMMMMM////////
////////MMMMMMMMMMMMWMMMMNOo:'..    ..':oONMMMMMMMMMMMMMMMMM////////
////////MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM////////
////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////

contract PakCommunityLove is ERC721URIStorage {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor(string memory _tokenURI) ERC721("PakCommunityLove", "PCL") {
        mint(_tokenURI);
    }

    function mint(string memory tokenURI) private
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
    }
}