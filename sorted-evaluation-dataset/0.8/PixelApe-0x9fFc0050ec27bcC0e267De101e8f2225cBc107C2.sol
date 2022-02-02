pragma solidity ^0.8.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract PixelApe is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 private constant _maxTokens = 3333;
    uint256 private _freeMints = 500;
    uint256 private constant _maxMint = 3333;
    uint256 private _maxFreeMint = 500;
    uint256 public _price = 20000000000000000; // 0.02 ETH
    bool private _saleActive = false;
    bool private _mintingIsFree = true;

    string public _prefixURI = "ipfs://QmSQj3u7ZL68zHUEuKFzRuuzMh7ehFJx1oZg5Gwk2K1oit/";

    mapping(address => bool) private _freelist;
    mapping(address => bool) private _whitelist;

    constructor() ERC721("Baby Ape Pixel Club", "BAPC") {}

    function _baseURI() internal view override returns (string memory) {
        return _prefixURI;
    }

    function setBaseURI(string memory _uri) public onlyOwner {
        _prefixURI = _uri;
    }

    function setPrice(uint256 _newPrice) public onlyOwner {
        _price = _newPrice;
    }

    function setMaxFreeMint(uint256 _amount) public onlyOwner {
        _maxFreeMint = _amount;
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }

    function isMintFree() public view returns (bool) {
        return _mintingIsFree;
    }

    function Sale() public view returns (bool) {
        return _saleActive;
    }

    function checkPrice() public view returns (uint256) {
        return _price;
    }

    function toggleSale() public onlyOwner {
        _saleActive = !_saleActive;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId));

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(
                        baseURI,
                        Strings.toString(tokenId),
                        ".json"
                    )
                )
                : "";
    }

    function mintItems(uint256 amount) public payable {
        require(amount <= _maxMint);
        require(_saleActive);

        uint256 totalMinted = _tokenIds.current();

        if (totalMinted >= _freeMints) {
            require(totalMinted + amount <= _maxTokens);
            require(msg.value >= amount * _price);
        }
        else {
            require(totalMinted + amount <= _freeMints);
            require(amount <= _maxFreeMint);
            if (amount + totalMinted == _freeMints){
                _mintingIsFree = false;
            }
        }

        for (uint256 i = 0; i < amount; i++) {
            _mintItem(msg.sender);
        }
    }

    function _mintItem(address to) internal returns (uint256) {
        _tokenIds.increment();

        uint256 id = _tokenIds.current();
        _mint(to, id);

        return id;
    }

    function reserve(uint256 quantity) public onlyOwner {
        for(uint i = _tokenIds.current(); i < quantity; i++) {
            if (i < _maxTokens) {
                _tokenIds.increment();
                _safeMint(msg.sender, i + 1);
            }
        }
    }

    function withdraw(address payee) public payable onlyOwner {
        require(payable(payee).send(address(this).balance));
    }

    function withdrawAmount(address payee, uint256 amount) public payable onlyOwner {
        require(payable(payee).send(amount));
    }
}