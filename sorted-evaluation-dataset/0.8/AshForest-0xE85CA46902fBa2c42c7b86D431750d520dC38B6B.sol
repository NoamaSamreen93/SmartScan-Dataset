// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author: manifold.xyz

import "./access/AdminControl.sol";
import "./core/IERC721CreatorCore.sol";
import "./extensions/ICreatorExtensionTokenURI.sol";
import "./ILazyDelivery.sol";
import "./ILazyDeliveryMetadata.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * Welcome to the #AshForest
 */
contract AshForest is AdminControl, ICreatorExtensionTokenURI, ILazyDelivery, ILazyDeliveryMetadata {

    using Strings for uint256;
    using Strings for uint16;

    address private _creator;
    string private _baseURI;
    string private _previewImage;

    uint _listingId;
    mapping(uint => uint16) hashes;

    constructor(address creator) {
        _creator = creator;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AdminControl, IERC165) returns (bool) {
        return interfaceId == type(ICreatorExtensionTokenURI).interfaceId || interfaceId == type(ILazyDelivery).interfaceId || AdminControl.supportsInterface(interfaceId) || super.supportsInterface(interfaceId);
    }

    function premint(address to, uint num) public adminRequired {
        for (uint256 i = 0; i < num; i++) {
            uint tokenId = IERC721CreatorCore(_creator).mintExtension(to);
            hashes[tokenId] = uint16(uint256(keccak256(abi.encodePacked(block.timestamp, tokenId, msg.sender))));
        }
    }

    function setListingId(uint listingId) public adminRequired {
        _listingId = listingId;
    }

    function deliver(address sender, uint256 listingId, uint256, address, uint256, uint256) external override returns(uint256) {
        require(listingId == _listingId);
        require(IERC721(_creator).balanceOf(sender) < 1, "Can only mint once.");
        uint tokenId = IERC721CreatorCore(_creator).mintExtension(sender);
        hashes[tokenId] = uint16(uint256(keccak256(abi.encodePacked(block.timestamp, tokenId, msg.sender))));
        return tokenId;
    }

    function setBaseURI(string memory baseURI) public adminRequired {
      _baseURI = baseURI;
    }

    function getAnimationURL(uint assetId) private view returns (string memory) {
        return string(abi.encodePacked(_baseURI, assetId.toString(), ":", hashes[assetId].toString()));
    }

    function setPreviewImageForAll(string memory previewImage) public adminRequired {
        _previewImage = previewImage;
    }

    function getName(uint assetId) private pure returns (string memory) {
        return string(abi.encodePacked("The Collected #", assetId.toString()));
    }

    function assetURI(uint256 assetId) external view override returns(string memory) {
        return string(abi.encodePacked('data:application/json;utf8,',
        '{"name":"',
        getName(assetId),
        '","created_by":"yung wknd","description":"One of many trees in the #AshForest.","animation":"',
        getAnimationURL(assetId),
        '","animation_url":"',
        getAnimationURL(assetId),
        '","image":"',
        _previewImage,
        '","image_url":"',
        _previewImage,
        '"}'));
    }

    function tokenURI(address creator, uint256 tokenId) external view override returns (string memory) {
        require(creator == _creator, "Invalid token");
        return this.assetURI(tokenId);
    }
}