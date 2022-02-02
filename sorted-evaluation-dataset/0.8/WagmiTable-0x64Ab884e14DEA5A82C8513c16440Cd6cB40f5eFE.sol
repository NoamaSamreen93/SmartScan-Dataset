// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@1001-digital/erc721-extensions/contracts/WithAdditionalMints.sol";
import "@1001-digital/erc721-extensions/contracts/WithFreezableMetadata.sol";
import "@1001-digital/erc721-extensions/contracts/WithSaleStart.sol";
import "@1001-digital/erc721-extensions/contracts/WithTokenPrices.sol";
import "@1001-digital/erc721-extensions/contracts/WithWithdrawals.sol";

// ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– //
//                                                                                               //
//   __      __  ______  ____             ______      ______ ______  ____    __      ____        //
//  /\ \  __/\ \/\  _  \/\  _`\   /'\_/`\/\__  _\    /\__  _/\  _  \/\  _`\ /\ \    /\  _`\      //
//  \ \ \/\ \ \ \ \ \L\ \ \ \L\_\/\      \/_/\ \/    \/_/\ \\ \ \L\ \ \ \L\ \ \ \   \ \ \L\_\    //
//   \ \ \ \ \ \ \ \  __ \ \ \L_L\ \ \__\ \ \ \ \       \ \ \\ \  __ \ \  _ <\ \ \  _\ \  _\L    //
//    \ \ \_/ \_\ \ \ \/\ \ \ \/, \ \ \_/\ \ \_\ \__     \ \ \\ \ \/\ \ \ \L\ \ \ \L\ \ \ \L\ \  //
//     \ `\___x___/\ \_\ \_\ \____/\ \_\\ \_\/\_____\     \ \_\\ \_\ \_\ \____/\ \____/\ \____/  //
//      '\/__//__/  \/_/\/_/\/___/  \/_/ \/_/\/_____/      \/_/ \/_/\/_/\/___/  \/___/  \/___/   //
//                                                                                               //
// ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– //
//                              trust the process · by aaraalto.eth                              //
// ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– //
contract WagmiTable is
    WithAdditionalMints,
    WithFreezableMetadata,
    WithTokenPrices,
    WithWithdrawals,
    WithSaleStart
{
    /// Initialize the WagmiTable Contract
    /// @param _initialSupply The initial supply of the collection
    /// @param _defaultPrice The default price for all tokens
    /// @param _cid The content identifyer for the collection
    /// @param _time The sale start time
    constructor(
        uint256 _initialSupply,
        uint256 _defaultPrice,
        string memory _cid,
        uint256 _time
    )
        ERC721("WagmiTable", "WT")
        WithSaleStart(_time)
        WithIPFSMetaData(_cid)
        WithTokenPrices(_defaultPrice)
        WithLimitedSupply(_initialSupply)
    {
        // Mint #0 to Aaron
        _mint(0x03C19A8432904f450cc90ba1892329deb43C8077, 0);

        // Mint #17 to Sandy
        _mint(0xE4C107c27AE5869E323289c04aE55827a4EaA7d3, 17);

        // Gift #69 to Jack Butcher / VV
        _mint(0xc8f8e2F59Dd95fF67c3d39109ecA2e2A017D4c8a, 69);

        // Gift #72 to Larva Labs
        _mint(0xC352B534e8b987e036A93539Fd6897F53488e56a, 72);

        // Gift #129 to the Scapoors
        _mint(0xFF9774E77966a96b920791968a41aa840DEdE507, 129);
    }

    /// Mint a new WAGMI TABLE token
    /// @param _tokenId The token to mint
    /// @param _to The address of the recipient of the token
    function mint(uint256 _tokenId, address _to)
        external payable
        withinSupply(_tokenId)
        meetsPrice(_tokenId)
        afterSaleStart
    {
        _mint(_to, _tokenId);
    }

    /// Add new token supply, but only if the collection isn't frozen yet
    /// @param _cid The new IFPS hash (content identifyer) of the collection
    /// @param _count The number of tokens to create
    function addTokens(string memory _cid, uint256 _count)
        public override
        onlyOwner
        unfrozen
    {
        super.addTokens(_cid, _count);
    }

    /// Update the IPFS hash of the collection
    /// @param _cid The new IFPS hash (content identifyer) of the collection
    function setCID(string memory _cid)
        external onlyOwner unfrozen
    {
        _setCID(_cid);
    }

    /// Check whether we are exceeding the token supply.
    /// @param _tokenId The tokenID to check against the supply.
    modifier withinSupply (uint256 _tokenId) {
        require(_tokenId < totalSupply(), "Token not available to mint");

        _;
    }
}

// a gift to aaraalto.eth from jalil.eth