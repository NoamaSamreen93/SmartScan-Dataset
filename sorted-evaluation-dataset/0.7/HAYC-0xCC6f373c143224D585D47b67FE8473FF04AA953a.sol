// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

pragma solidity ^0.8.0;

contract HAYC is ERC721("Hex Ape Yacht Club", "HAYC"), Ownable {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenSupply;

  string baseURI;
  uint256 maxMintAmount = 20;
  uint256 maxSupply = 10_000;
  uint256 price = 0.02 ether;

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  // public
  function mint(uint256 _mintAmount) public payable {
    uint256 supply = _tokenSupply.current();
    require(_mintAmount < maxMintAmount + 1, "Can only mint 20 at a time");
    require(supply + _mintAmount <= maxSupply, "Must mint within supply");

    require(msg.value >= price * _mintAmount, "Must pay appropriate cost for NFT");

    for (uint256 i = 0; i < _mintAmount; i++) {
      _tokenSupply.increment();
      _safeMint(msg.sender, supply + i);
    }
  }

  function setPrice(uint256 _newPrice) public onlyOwner() {
    price = _newPrice;
  }
  
  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function withdraw() public payable onlyOwner {
    address a = 0xecF037b1eA1e7A29909e9C696091E7AAcb3eB573;
    uint256 bal = address(this).balance;
    require(payable(a).send(bal));
  }

  function totalSupply() public view returns (uint256) {
      return _tokenSupply.current() - 1;
  }

  function walletOfOwner(address owner) public view returns (uint256[] memory) {
    uint256 ownerBalance = balanceOf(owner);
    uint256[] memory tokenIds = new uint256[](ownerBalance);
    uint256 tokenCounter = 0;
    for (uint256 i=0; i < maxSupply; i++) {
      if (ownerOf(i) == owner) {
        tokenIds[tokenCounter] = i;
      }
      tokenCounter++;
      if (tokenCounter==ownerBalance) {
        break;
      }
    }
    return tokenIds;
  }
}