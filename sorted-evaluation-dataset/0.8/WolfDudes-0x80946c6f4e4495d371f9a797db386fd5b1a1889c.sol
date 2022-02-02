// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract WolfDudes is ERC721, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;

    uint256 public constant PRICE_DEFAULT = 0.04 ether;
    uint256 public constant PRICE_OWNERS = 0.03 ether;

    constructor() ERC721("Wolf Dudes", "WDZ") {
        for (uint i = 0; i < 30; i++) {
            _tokenIdCounter.increment();
            _safeMint(_msgSender(), i);
        }
    }

    function mint(uint amount) external payable {
        require(amount > 0 && amount <= 20, "INVALID_TOKEN_AMT");
        require(_tokenIdCounter.current() + amount < 5000, "SOLD_OUT");

        uint256 totalPrice = 0;
        for (uint i = 0; i < amount; i++) {
            uint tokenId = _tokenIdCounter.current() + i;

            if (tokenId > 999) {
                if (balanceOf(_msgSender()) > 0) totalPrice += PRICE_OWNERS;
                else totalPrice += PRICE_DEFAULT;
            }
        }

        require(totalPrice == msg.value, "INVALID_ETH_AMT");

        for (uint i = 0; i < amount; i++) {
            uint tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(_msgSender(), tokenId);
        }
    }

    function tokenURI(uint tokenId) public pure override returns (string memory) {
        return string(abi.encodePacked("ipfs://QmXDNmYbwi1H5PooM99YEUZvD8wxn1KSwihan6WvACiLqP/", (tokenId + 1).toString(), ".json"));
    }

    function currentToken() public view returns (uint) {
        return _tokenIdCounter.current();
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_msgSender()).transfer(balance);
    }
}