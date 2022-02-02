// SPDX-License-Identifier: MIT
/*

 __  __    ___    _____    ___   __  __    ___   __   __   ___     ___     ___
|  \/  |  | __|  |_   _|  /   \ |  \/  |  / _ \  \ \ / /  | __|   | _ \   / __|
| |\/| |  | _|     | |    | - | | |\/| | | (_) |  \ V /   | _|    |   /   \__ \
|_|__|_|  |___|   _|_|_   |_|_| |_|__|_|  \___/   _\_/_   |___|   |_|_\   |___/
_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_| """"|_|"""""|_|"""""|_|"""""|
"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'

*/

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

contract Metamovers is ERC1155Supply, PaymentSplitter, Ownable, Pausable {
    string public constant name = "Metamovers NFT Crew";
    string public constant symbol = "MMC";
    uint256 public constant MAX_SUPPLY = 300;
    uint256 public constant MINT_PRICE = 0.045 ether;
    uint256 public _id;

    mapping (uint256 => string) public tokenURI;
    mapping (bytes32 => bool) private used;

    bool public saleStarted = false;
    address private _signerAddress;

    constructor(address[] memory _payees, uint256[] memory _shares)
        ERC1155("") PaymentSplitter(_payees, _shares) { }

    function mintBatch(
        uint256 _count,
        uint256 _maxCount,
        bytes calldata _sig)
        external payable
    {
        require(saleStarted, "MINT_NOT_STARTED");
        require(msg.value == _count * MINT_PRICE, "INSUFFICIENT_ETH");
        require(_count > 0 && _count <= _maxCount, "COUNT_INVALID");
        bytes32 hash = keccak256(abi.encode(_msgSender(), _maxCount));
        require(matchSigner(hash, _sig), "INVALID_SIGNER");
        require(!used[hash], "ALREADY_MINTED");
        used[hash] = true;

        for (uint256 i = 0; i < _count; i++) {
            uint256 tokenId = ((_id + i) % 16) + 1;
            require(totalSupply(tokenId) + 1 <= MAX_SUPPLY, "MAX_SUPPLY_REACHED");
            _mint(_msgSender(), tokenId, 1, "");
        }
        _id += _count;
    }

    function mintAdmin(
        uint256 _count,
        address _to
    ) external onlyOwner {
        require(_to != address(0), "ADDRESS_ZERO");
        for (uint256 i = 0; i < _count; i++) {
            uint256 tokenId = ((_id + i) % 16) + 1;
            require(totalSupply(tokenId) + 1 <= MAX_SUPPLY, "MAX_SUPPLY_REACHED");
            _mint(_to, tokenId, 1, "");
        }
        _id += _count;
    }

    function mintNewCollection(
        uint256 _tokenId,
        uint256 _count,
        address _to
    ) external onlyOwner {
        require(_tokenId > 16, "NEW_COLLECTION_ONLY");
        require(_to != address(0), "ADDRESS_ZERO");
        _mint(_to, _tokenId, _count, "");
    }

    function matchSigner(bytes32 _hash, bytes memory _signature) private view returns(bool) {
        return _signerAddress == ECDSA.recover(ECDSA.toEthSignedMessageHash(_hash), _signature);
    }


    function checkWhitelist(
        address _sender,
        uint256 _maxCount,
        bytes calldata _sig
    ) public view returns(bool) {
        bytes32 hash = keccak256(abi.encode(_sender, _maxCount));
        if (!matchSigner(hash, _sig)) {
            return false;
        }
        if (used[hash]) {
            return false;
        }
        return true;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        if (bytes(tokenURI[tokenId]).length == 0) {
            return super.uri(tokenId);
        }
        return tokenURI[tokenId];
    }

    // ** Admin Fuctions ** //
    function setURI(uint256 _tokenId, string memory _tokenURI) external onlyOwner {
        tokenURI[_tokenId] = _tokenURI;
    }

    function setGlobalURI(string memory _tokenURI) external onlyOwner {
        _setURI(_tokenURI);
    }

    function setSaleStarted(bool _hasStarted) external onlyOwner {
        require(saleStarted != _hasStarted, "SALE_STATE_IDENTICAL");
        saleStarted = _hasStarted;
    }

    function setSignerAddress(address _signer) external onlyOwner {
        require(_signer != address(0), "SIGNER_ADDRESS_ZERO");
        _signerAddress = _signer;
    }

    function pause() external onlyOwner {
        require(!paused(), "ALREADY_PAUSED");
        _pause();
    }

    function unpause() external onlyOwner {
        require(paused(), "ALREADY_UNPAUSED");
        _unpause();
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        require(!paused(), "TRANSFER_PAUSED");
    }
}