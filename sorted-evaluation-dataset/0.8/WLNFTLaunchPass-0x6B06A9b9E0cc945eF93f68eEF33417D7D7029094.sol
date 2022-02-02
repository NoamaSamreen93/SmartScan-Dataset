// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721Tradable.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

/**
 * @title WhitelistNFT LaunchPass
 * WhitelistNFT LaunchPass - a contract for WhitelistNFT LaunchPass
 */
contract WLNFTLaunchPass is ERC721Tradable {
    using SafeMath for uint256;
    address constant WALLET1 = 0xffe5CBCDdF2bd1b4Dc3c00455d4cdCcf20F77587;
    address constant WALLET2 = 0xC87C8BF777701ccFfB1230051E33f0524E5975b5;
    address constant WALLET3 = 0xe5c07AcF973Ccda3a141efbb2e829049591F938e;
    address constant WALLET4 = 0xA7Ad336868fEB70C83F08f1c28c19e1120AB6351;
    bool public saleIsActive = false;
    uint256 public mintPrice = 1000000000000000000;
    uint256 public maxToMint = 1;
    uint256 public maxSupply = 10000;
    string _baseTokenURI;

    constructor(address _proxyRegistryAddress) ERC721Tradable("WhitelistNFT LaunchPass", "WxLAUNCH", _proxyRegistryAddress) {}

    function baseTokenURI() override virtual public view returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseTokenURI(string memory _uri) public onlyOwner {
        _baseTokenURI = _uri;
    }

    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        require(_maxSupply > maxSupply, "You cannot reduce supply.");
        maxSupply = _maxSupply;
    }

    function setMintPrice(uint256 _price) external onlyOwner {
        mintPrice = _price;
    }

    function setMaxToMint(uint256 _maxToMint) external onlyOwner {
        maxToMint = _maxToMint;
    }

    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    // for compatibility with WenMint's hosted minting form
    function preSalePrice() public view returns (uint256) {
        return mintPrice;
    }

    // for compatibility with WenMint's hosted minting form
    function pubSalePrice() public view returns (uint256) {
        return mintPrice;
    }

    function reserve(address to, uint256 numberOfTokens) public onlyOwner {
        uint i;
        for (i = 0; i < numberOfTokens; i++) {
            mintTo(to);
        }
    }

    function mint(uint256 numberOfTokens) public payable {
        require(saleIsActive, "Sale is not active.");
        require(totalSupply().add(numberOfTokens) <= maxSupply, "Sold out.");
        require(mintPrice.mul(numberOfTokens) <= msg.value, "ETH sent is incorrect.");
        require(numberOfTokens <= maxToMint, "Exceeds per transaction limit.");
        for(uint i = 0; i < numberOfTokens; i++) {
            mintTo(msg.sender);
        }
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        uint256 split1 = balance.mul(45).div(100);
        uint256 split2 = balance.mul(225).div(1000);
        payable(WALLET1).transfer(split1);
        payable(WALLET2).transfer(split2);
        payable(WALLET3).transfer(split2);
        payable(WALLET4).transfer(
            balance.sub(split1.add(split2.mul(2)))
        );
    }
}