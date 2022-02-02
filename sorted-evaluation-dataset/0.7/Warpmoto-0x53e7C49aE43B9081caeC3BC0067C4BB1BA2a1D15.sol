// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Warpmoto is Ownable, ERC721A {
    bool private PAUSE = false;

    uint256 public constant maxSupply = 4096;
    uint256 public price = 100000000000000000;
    uint256 public presalePrice = 80000000000000000;
    uint256 internal maxMintAmount = 5;
    string internal baseURI;

    uint256 public presaleStartTime = 1643205600;
    uint256 public presaleEndTime = 1643292000;
    uint256 public publicSaleStartTime = 1643292000;
    uint256 public publicSaleEndTime = 1643637600;

    mapping(address => uint256) public whitelist;

    constructor(
        string memory newBaseURI
    ) ERC721A("Warpmoto", "WARPM" , 500) {
        baseURI = newBaseURI;
    }
    //Set
    function setPrice(uint256 _presalePrice, uint256 _price)
        external
        onlyOwner
    {
        presalePrice = _presalePrice;
        price = _price;
    }

    function setTime(
        uint256 presaleStart,
        uint256 presaleEnd,
        uint256 publicSaleStart,
        uint256 publicSaleEnd
    ) external onlyOwner {
        presaleStartTime = presaleStart;
        presaleEndTime = presaleEnd;
        publicSaleStartTime = publicSaleStart;
        publicSaleEndTime = publicSaleEnd;
    }

    function setBaseURI(string memory newBaseURI) external onlyOwner {
        baseURI = newBaseURI;
    }

    function setmaxMintAmount(uint256 _max) external onlyOwner {
        maxMintAmount = _max;
    }


    function setPause(bool _pause) external onlyOwner {
        PAUSE = _pause;
    }

    function whitelistAddress(address[] memory addr, uint256 amount)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < addr.length; i++) whitelist[addr[i]] = amount;
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    //Get
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function inPresale() private view returns (bool) {
        return
            block.timestamp >= presaleStartTime &&
            block.timestamp < presaleEndTime;
    }

    function inPublicSale() private view returns (bool) {
        return
            block.timestamp >= publicSaleStartTime &&
            block.timestamp < publicSaleEndTime;
    }

    //Mint
    function reserveMint(address _to, uint256 qty) external onlyOwner {
        require(qty > 0, "Wrong qty");
        require(
            totalSupply() + qty < maxSupply,
            "Exceeds maxSupply"
        );
        _safeMint(_to, qty);
    }

    function presaleMint(uint256 qty) external payable {
        require(!PAUSE, "Mint is paused");
        require(msg.value >= presalePrice * qty, "Need to send more ETH.");
        require(qty > 0, "Wrong qty");
        require(
            totalSupply() + qty < maxSupply,
            "Exceeds maxSupply"
        );
        uint256 whitelistMintMax = whitelist[msg.sender];
        require(inPresale(), "Not in Presale");
        require(whitelistMintMax >= qty, "Exceeds");
        _safeMint(msg.sender, qty);
        whitelist[msg.sender] = whitelistMintMax - qty;
    }

    function mint(uint256 qty) external payable {
        require(!PAUSE, "Mint is paused");
        require(msg.value >= price * qty, "Need to send more ETH.");
        require(qty > 0, "Wrong qty");
        require(
            totalSupply() + qty < maxSupply,
            "Exceeds maxSupply"
        );
        require(inPublicSale(), "Not in Publicsale");
        require(qty <= maxMintAmount, "Exceeds mint amount");
        _safeMint(msg.sender, qty);
    }
}