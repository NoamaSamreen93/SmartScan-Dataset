//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./Collection.sol";
import "./ICollectionManager.sol";

contract CollectionManager is ICollectionManager, Ownable {
    address[] private collections;

    // Mapping from artist to collection addresses
    mapping(address => address[]) private collectionsOf;

    // Mapping from collection address to artist
    mapping(address => address) private collectionArtist;

    mapping(address => bool) private isArtist;

    constructor() {
        isArtist[msg.sender] = true;
    }

    function initializeCollection(
        string memory _uri,
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        uint256 _startingAt,
        uint256 _initialPrice,
        address[] memory _payees,
        uint256[] memory _shares
    ) public {
        require(_startingAt > block.timestamp, "Invalid timestamp");

        address _artist = msg.sender;

        require(isArtist[_artist], "Invalid artist");

        Collection collection = new Collection(
            _startingAt,
            _maxSupply,
            _initialPrice,
            _uri,
            _name,
            _symbol,
            _artist,
            _payees,
            _shares
        );

        address collectionAddr = address(collection);

        collections.push(collectionAddr);
        collectionsOf[_artist].push(collectionAddr);
        collectionArtist[collectionAddr] = _artist;

        emit CollectionInitialized(
            _artist,
            collectionAddr,
            _uri,
            _name,
            _symbol,
            block.timestamp,
            _startingAt,
            _maxSupply,
            _initialPrice,
            _payees,
            _shares
        );
    }

    function getCollections() external view returns (address[] memory) {
        return collections;
    }

    function getCollectionForArtist(address _artist) external view returns (address[] memory) {
        return collectionsOf[_artist];
    }

    function getArtistOfCollection(address _collectionAddress) external view returns (address) {
        return collectionArtist[_collectionAddress];
    }

    function setArtist(address artist) external onlyOwner {
        isArtist[artist] = true;
    }
}