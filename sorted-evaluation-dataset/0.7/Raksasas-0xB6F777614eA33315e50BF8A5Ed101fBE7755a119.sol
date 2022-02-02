// SPDX-License-Identifier: GPL-3.0
// Author: Pagzi Tech Inc. | 2021
pragma solidity ^0.8.10;

import "./pagzi/ERC721Enum.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Raksasas is ERC721Enum, Ownable, ReentrancyGuard {
    using Strings for uint256;

    uint256 public cost = 0.025 ether;
    uint256 public allowListCost = 0.01 ether;
    uint256 public maxSupply = 8888;
    uint256 public maxMintAmount = 20;
    uint256 private reserved = 888;
    uint256 public nftPerAddressLimit = 1;

    bool inside;
    bool public paused = true;

    string public baseURI;
    string public baseExtension = ".json";

    address[] public whitelistedAddresses;

    address an = 0x7a0876cBa8146f9Ad39876d83593D99B2A0ffc7b;
    address gu = 0xE35374A6Db102187c9a77c54CEA1E891B32839e7;
    address hu = 0x66e4D5FB3B9710C1C30fe34F968A9ad45a9A855e;
    address je = 0x7B85A22dB64690f7229Cbf494614f395274efacb;
    address lu = 0xBb18BB346C421BC998788A2F3D0a5ed9Fa3F8060;
    address va = 0xCf5482620e3283A015575d106d14fa877529eCD5;

    mapping(address => uint256) public addressMintedBalance;

    constructor(string memory _initBaseURI) ERC721P("Raksasas", "RAKS") {
        setBaseURI(_initBaseURI);
    }

    function mint(uint256 _mintAmount) public payable nonReentrant {
        require(!paused, "Sales are paused!");
        require(
            _mintAmount > 0 && _mintAmount <= maxMintAmount,
            "Too many NFTs to mint"
        );
        uint256 supply = totalSupply();
        require(
            supply + _mintAmount <= maxSupply - reserved,
            "Not enough NFTs available"
        );
        require(msg.value >= cost * _mintAmount);
        for (uint256 i; i < _mintAmount; i++) {
            _safeMint(msg.sender, supply + i, "");
        }
    }

    function mintWhiteListed(uint256 _mintAmount) public payable nonReentrant {
        require(!paused, "Sales are paused!");
        require(
            _mintAmount > 0 && _mintAmount <= nftPerAddressLimit,
            "Too many NFTs to mint"
        );
        uint256 supply = totalSupply();
        require(
            supply + _mintAmount <= maxSupply - reserved,
            "Not enough NFTs available"
        );
        require(isWhitelisted(msg.sender), "User is not whitelisted");
        uint256 ownerMintedCount = addressMintedBalance[msg.sender];
        require(
            ownerMintedCount + _mintAmount <= nftPerAddressLimit,
            "Max NFT per address exceeded"
        );
        require(msg.value >= allowListCost * _mintAmount);
        reserved -= _mintAmount;
        addressMintedBalance[msg.sender] += _mintAmount;
        for (uint256 i; i < _mintAmount; i++) {
            _safeMint(msg.sender, supply + i, "");
        }
    }

    function giveAway(
        uint256[] calldata quantityList,
        address[] calldata addressList
    ) external onlyOwner {
        require(quantityList.length == addressList.length, "Wrong Inputs");
        uint256 totalQuantity = 0;
        uint256 supply = totalSupply();
        for (uint256 i = 0; i < quantityList.length; ++i) {
            totalQuantity += quantityList[i];
        }
        require(totalQuantity <= reserved, "Exceeds reserved supply");
        require(supply + totalQuantity <= maxSupply, "Too many NFTs t o mint");
        reserved -= totalQuantity;
        delete totalQuantity;
        for (uint256 i = 0; i < addressList.length; ++i) {
            for (uint256 j = 0; j < quantityList[i]; ++j) {
                _safeMint(addressList[i], supply++, "");
            }
        }
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    function isWhitelisted(address _user) public view returns (bool) {
        for (uint256 i = 0; i < whitelistedAddresses.length; i++) {
            if (whitelistedAddresses[i] == _user) {
                return true;
            }
        }
        return false;
    }

    function _baseURI() internal view virtual returns (string memory) {
        return baseURI;
    }

    function remainingReserved() public view returns (uint256) {
        return reserved;
    }

    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setAllowedListCost(uint256 _newCost) public onlyOwner {
        allowListCost = _newCost;
    }

    function setNftPerAddressLimit(uint256 _limit) public onlyOwner {
        nftPerAddressLimit = _limit;
    }

    function whitelistUsers(address[] calldata _users) public onlyOwner {
        for (uint256 i = 0; i < _users.length; ++i) {
            whitelistedAddresses.push(_users[i]);
        }
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function setTogglePause() public onlyOwner {
        paused = !paused;
    }

    function sendEth(address destination, uint256 amount) internal {
        (bool sent, ) = destination.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    function withdrawAll() public payable onlyOwner {
        require(!inside, "no rentrancy");
        inside = true;
        uint256 percent = address(this).balance / 100;
        sendEth(an, percent * 16);
        sendEth(gu, percent * 16);
        sendEth(hu, percent * 16);
        sendEth(je, percent * 16);
        sendEth(lu, percent * 16);
        sendEth(va, address(this).balance);
        inside = false;
    }
}