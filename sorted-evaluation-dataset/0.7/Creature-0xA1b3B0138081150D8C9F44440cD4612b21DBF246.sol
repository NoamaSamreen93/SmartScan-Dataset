// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721Tradable.sol";

/**
 * @title Creature
 * Creature - a contract for my non-fungible creatures.
 */
contract Creature is ERC721Tradable {

    uint internal constant RESERVE_LIMIT = 410;
    uint internal constant MAX_LIMIT = 1110;
    uint internal constant PRE_SALE_ONCE_LIMIT = 2;
    uint internal constant NORMAL_SALE_ONCE_LIMIT = 2;

    uint public preSalePrice;
    uint public normalPrice;
    string public baseURI;
    uint public preSaleStartTime;
    uint public preSaleEndTime;

    mapping(address => bool) public whiteList;
    mapping(address => bool) public whiteListMinted;
    uint public reserveMintedAmt; // has pre minted num
    uint public mintedAmt;  // has minted num
    address public foundAddr;

    constructor(address _proxyRegistryAddress, string memory _baseURI)ERC721Tradable("Knight Pass", "KTP", _proxyRegistryAddress){
        baseURI = _baseURI;
        preSalePrice = 0.25 ether;
        normalPrice = 0.35 ether;
        preSaleStartTime = 1643032800;
        preSaleEndTime = 1643119200;
        foundAddr = address(0x221ce8b7a5856ED901a65ff5DdA28cDB2F1B2E57);
    }

    function setPreSalePrice(uint _preSalePrice) public onlyOwner {
        preSalePrice = _preSalePrice;
    }

    function setNormalPrice(uint _normalPrice) public onlyOwner {
        normalPrice = _normalPrice;
    }

    function setFoundAddr(address _foundAddr) public onlyOwner {
        require(_foundAddr != address(0), "zero address");
        foundAddr = _foundAddr;
    }

    function setPreSaleTime(uint _preSaleStartTime, uint _preSaleEndTime) public onlyOwner {
        require(_preSaleStartTime < _preSaleEndTime, "invalid args");
        require(block.timestamp < _preSaleEndTime, "end time invalid");
        preSaleStartTime = _preSaleStartTime;
        preSaleEndTime = _preSaleEndTime;
    }

    function addWhiteList(address[] calldata users) public onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            whiteList[users[i]] = true;
        }
    }

    function removeWhiteList(address[] calldata users) public onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            whiteList[users[i]] = false;
        }
    }

    /**
    * @dev Mints a token to an address with a tokenURI.
    * @param _tos address of the future owner of the token
    */
    function mintTo(address[] calldata _tos, uint amount) public onlyOwner {
        uint _mintedAmt = mintedAmt;
        uint _reserveMintedAmt = reserveMintedAmt;
        uint mintAmt = _tos.length * amount;
        require(_mintedAmt + mintAmt <= MAX_LIMIT, "more than max limit");
        require(_reserveMintedAmt + mintAmt <= RESERVE_LIMIT, "more than reserve limit");
        uint256 newTokenId = _getNextTokenId();
        for (uint i = 0; i < _tos.length; i++) {
            address _to = _tos[i];
            for (uint j = 0; j < amount; j++) {
                _mint(_to, newTokenId);
                _incrementTokenId();
                newTokenId += 1;
            }
            _mintedAmt += amount;
            _reserveMintedAmt += amount;
        }
        reserveMintedAmt = _reserveMintedAmt;
        mintedAmt = _mintedAmt;
    }


    function mint(uint num) payable public {
        uint256 newTokenId = _getNextTokenId();
        uint _reserveMintedAmt = reserveMintedAmt;
        uint _mintedAmt = mintedAmt;
        require(_mintedAmt + num <= MAX_LIMIT, "mint too much");
        require(preSaleStartTime > 0 && preSaleEndTime > 0, "not init presale info");
        require(block.timestamp >= preSaleStartTime, "not start");
        if (preSaleStartTime <= block.timestamp && block.timestamp < preSaleEndTime) {
            require(whiteList[msg.sender], "invalid user");
            require(!whiteListMinted[msg.sender], "has minted");
            require(_reserveMintedAmt + num <= RESERVE_LIMIT, "preSale mint too much NFT");
            require(num <= PRE_SALE_ONCE_LIMIT, "mint too much NFT");
            require(msg.value >= num * preSalePrice, "value error, please check msg.value.");
            for (uint i = 0; i < num; i++) {
                _mint(msg.sender, newTokenId + i);
                _incrementTokenId();
            }
            whiteListMinted[msg.sender] = true;
            _reserveMintedAmt += num;
            reserveMintedAmt = _reserveMintedAmt;
        } else {
            require(num <= NORMAL_SALE_ONCE_LIMIT, "mint too much NFT");
            require(msg.value >= num * normalPrice, "value error, please check price.");
            for (uint i = 0; i < num; i++) {
                _mint(msg.sender, newTokenId + i);
                _incrementTokenId();
            }
        }
        _mintedAmt += num;
        mintedAmt = _mintedAmt;
        if (foundAddr != address(0)) {
            payable(foundAddr).transfer(msg.value);
        }
    }


    function tokenURI(uint256 _tokenId) override public view returns (string memory) {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return string(abi.encodePacked(baseTokenURI(), Strings.toString(_tokenId), ".json"));
    }

    function transfer(address to, uint id) public {
        require(ownerOf(id) == msg.sender, "unauthorized");
        _safeTransfer(msg.sender, to, id, new bytes(0x00));
    }

    function baseTokenURI() public view returns (string memory) {
        return baseURI;
    }
}