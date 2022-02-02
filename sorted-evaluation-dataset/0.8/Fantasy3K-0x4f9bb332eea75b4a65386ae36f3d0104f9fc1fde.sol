// contracts/Fantasy3K.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "./access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Fantasy3K is ERC721, Pausable, Ownable {

    event BaseURIChanged(string newBaseURI);
    event Mint(address minter, uint256 count);
    event IsBurnEnabledChanged(bool newIsBurnEnabled);

    uint256 private _nextTokenId = 1;
    uint256 private _totalSupply;
    uint256 private _startTokenId;

    bool public isBurnEnabled;
    string public baseURI;

    constructor() ERC721("Fantasy3K", "F3K") {}

    function mintTokens(address to, uint256 count) external onlyAdmin {

        require(count > 0, "Fantasy3k: invalid count");
        
        for (uint256 ind = 0; ind < count; ind++) {
            _safeMint(to, _nextTokenId + ind);
        }

        _nextTokenId += count;
        _totalSupply += count;
        emit Mint(to, count);
    }

    function setIsBurnEnabled(bool _isBurnEnabled) external onlyOwner {
        isBurnEnabled = _isBurnEnabled;
        emit IsBurnEnabledChanged(_isBurnEnabled);
    }

    function setBaseURI(string calldata newbaseURI) external onlyOwner {
        baseURI = newbaseURI;
        emit BaseURIChanged(newbaseURI);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function nextTokenId() public view returns (uint256) {
        return _nextTokenId;
    }

    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _totalSupply--;
        _burn(tokenId);
    }

    function pauseContract() external onlyOwner {
        _pause();
    }

    function unpauseContract() external onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);
        require(!paused(), "ERC721Pausable: token transfer while paused");
    }
}