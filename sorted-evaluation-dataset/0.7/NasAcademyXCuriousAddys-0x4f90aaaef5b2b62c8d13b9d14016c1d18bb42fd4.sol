// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title Nas Academy NFT Contract
 * @author Mai Akiyoshi & Ben Yu (https://twitter.com/mai_on_chain & https://twitter.com/intenex)
 * @notice This contract handles minting Nas Academy NFT tokens.
 */
contract NasAcademyXCuriousAddys is ERC721, Ownable {
    using ECDSA for bytes32;
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter public tokenIds;
    string public baseTokenURI;

    uint256 public immutable maxSupply;
    uint256 public immutable firstSaleSupply;

    /**
     * @notice Construct a Nas Academy NFT instance
     * @param name Token name
     * @param symbol Token symbol
     * @param baseTokenURI_ Base URI for all tokens
     */
    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI_,
        uint256 maxSupply_,
        uint256 firstSaleSupply_
    ) ERC721(name, symbol) {
        require(maxSupply_ > 0, "INVALID_SUPPLY");
        baseTokenURI = baseTokenURI_;
        maxSupply = maxSupply_;
        firstSaleSupply = firstSaleSupply_;

        // Start token IDs at 1
        tokenIds.increment();
    }

    // Used to validate authorized mint addresses
    address private signerAddress = 0x0cCF0888754C15f2624952AbE6b491239148F2F1;

    mapping (address => bool) public alreadyMinted;

    bool public isFirstSaleActive = false;
    bool public isSecondSaleActive = false;

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "URI query for nonexistent token");

        return string(abi.encodePacked(_baseURI(), tokenId.toString(), ".json"));
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }
    
    /**
     * To be updated by contract owner to allow for the first tranche of members to mint
     */
    function setFirstSaleState(bool _firstSaleActiveState) public onlyOwner {
        require(isFirstSaleActive != _firstSaleActiveState, "NEW_STATE_IDENTICAL_TO_OLD_STATE");
        isFirstSaleActive = _firstSaleActiveState;
    }

    /**
     * To be updated once maxSupply equals totalSupply. This will deactivate minting.
     * Can also be activated by contract owner to begin public sale
     */
    function setSecondSaleState(bool _secondSaleActiveState) public onlyOwner {
        require(isSecondSaleActive != _secondSaleActiveState, "NEW_STATE_IDENTICAL_TO_OLD_STATE");
        isSecondSaleActive = _secondSaleActiveState;
    }

    function setSignerAddress(address _signerAddress) external onlyOwner {
        require(_signerAddress != address(0));
        signerAddress = _signerAddress;
    }
    
    /**
     * Update the base token URI
     */
    function setBaseURI(string calldata _newBaseURI) external onlyOwner {
        baseTokenURI = _newBaseURI;
    }

    function verifyAddressSigner(bytes32 messageHash, bytes memory signature) private view returns (bool) {
        return signerAddress == messageHash.toEthSignedMessageHash().recover(signature);
    }

    function hashMessage(address sender) private pure returns (bytes32) {
        return keccak256(abi.encode(sender));
    }

    /**
     * @notice Allow for token minting for an approved minter with a valid message signature.
     * The address of the sender is hashed and signed with the server's private key and verified.
     */
    function mint(
        bytes32 messageHash,
        bytes calldata signature
    ) external virtual {
        require(isFirstSaleActive || isSecondSaleActive, "SALE_IS_NOT_ACTIVE");
        require(!alreadyMinted[msg.sender], "ALREADY_MINTED");
        require(hashMessage(msg.sender) == messageHash, "MESSAGE_INVALID");
        require(verifyAddressSigner(messageHash, signature), "SIGNATURE_VALIDATION_FAILED");

        uint256 currentId = tokenIds.current();

        if (isFirstSaleActive) {
            require(currentId <= firstSaleSupply, "NOT_ENOUGH_MINTS_AVAILABLE");
        } else {
            require(currentId <= maxSupply, "NOT_ENOUGH_MINTS_AVAILABLE");
        }

        alreadyMinted[msg.sender] = true;

        _safeMint(msg.sender, currentId);
        tokenIds.increment();

        if (isFirstSaleActive && (currentId == firstSaleSupply)) {
            isFirstSaleActive = false;
        } else if (isSecondSaleActive && (currentId == maxSupply)) {
            isSecondSaleActive = false;
        }
    }

    /**
     * @notice Allow owner to send `mintNumber` tokens without cost to multiple addresses
     */
    function gift(address[] calldata receivers, uint256 mintNumber) external onlyOwner {
        require((tokenIds.current() - 1 + (receivers.length * mintNumber)) <= maxSupply, "MINT_TOO_LARGE");

        for (uint256 i = 0; i < receivers.length; i++) {
            for (uint256 j = 0; j < mintNumber; j++) {
                _safeMint(receivers[i], tokenIds.current());
                tokenIds.increment();
            }
        }
    }
}