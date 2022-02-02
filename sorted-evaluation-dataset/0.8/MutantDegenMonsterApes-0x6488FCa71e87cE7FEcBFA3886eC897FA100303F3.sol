//Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./Math.sol";
import "./ERC721Enumerable.sol";
import "./ITransferController.sol";

contract MutantDegenMonsterApes is ERC721Enumerable, Ownable {
    using SafeMath for uint256;

    // Events
    event TokenMinted(uint256 tokenId, address owner, uint256 first_encounter);

    ITransferController public transferController =
        ITransferController(0x13B3f7Bd9D50B853f3D2Dc44FD8B4BC8fFa34cB0);

    // Provenance number
    string public PROVENANCE = "";

    // Max amount of token to purchase per account each time
    uint256 public MAX_PURCHASE = 2;

    // Maximum amount of tokens to supply.
    uint256 public MAX_TOKENS = 9999;

    // Current price.
    uint256 public CURRENT_PRICE = 20000000000000000;

    // Define if sale is active
    bool public saleIsActive = false;

    bool public isPresale = false;

    mapping(address => bool) public isWhitelistUtilized;

    // Base URI
    string private baseURI;

    /**
     * Contract constructor
     */
    constructor() ERC721("Mutant Degen Monster Apes", "MDMA") {}

    /**
     * With
     */
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    /**
     * Reserve tokens
     */
    function reserveTokens(uint256 amount) public onlyOwner {
        uint256 i;
        uint256 tokenId;
        uint256 first_encounter = block.timestamp;

        for (i = 1; i <= amount; i++) {
            tokenId = totalSupply().add(1);
            if (tokenId <= MAX_TOKENS) {
                _safeMint(msg.sender, tokenId);
                emit TokenMinted(tokenId, msg.sender, first_encounter);
            }
        }
    }

    /*
     * Set provenance once it's calculated
     */
    function setProvenanceHash(string memory provenanceHash) public onlyOwner {
        PROVENANCE = provenanceHash;
    }

    /*
     * Set max tokens
     */
    function setMaxTokens(uint256 maxTokens) public onlyOwner {
        MAX_TOKENS = maxTokens;
    }

    /*
     * Pause sale if active, make active if paused
     */
    function setSaleState(bool newState) public onlyOwner {
        saleIsActive = newState;
    }

    function changeMaxPurchase(uint256 newMaxPurchase) public onlyOwner {
        MAX_PURCHASE = newMaxPurchase;
    }

    /**
     * Mint MutantDegenMonsterApes
     */
    function mintMutantDegenMonsterApes(uint256 numberOfTokens) public payable {
        require(saleIsActive, "Mint is not available right now");
        require(
            numberOfTokens <= MAX_PURCHASE,
            "Can only mint 20 tokens at a time"
        );
        require(
            totalSupply().add(numberOfTokens) <= MAX_TOKENS,
            "Purchase would exceed max supply of MutantDegenMonsterApes"
        );
        require(
            CURRENT_PRICE.mul(numberOfTokens) <= msg.value,
            "Value sent is not correct"
        );
        if (isPresale) {
            require(
                transferController.isWhiteListed(msg.sender) &&
                    !isWhitelistUtilized[msg.sender],
                "You are not Whitelisted, Please contract to administrator"
            );
            isWhitelistUtilized[msg.sender] = true;
        }
        uint256 first_encounter = block.timestamp;
        uint256 tokenId;

        for (uint256 i = 1; i <= numberOfTokens; i++) {
            tokenId = totalSupply().add(1);
            if (tokenId <= MAX_TOKENS) {
                _safeMint(msg.sender, tokenId);
                emit TokenMinted(tokenId, msg.sender, first_encounter);
            }
        }
    }

    function changePresale(bool newisPresale) public onlyOwner {
        isPresale = newisPresale;
    }

    /**
     * @dev Changes the base URI if we want to move things in the future (Callable by owner only)
     */
    function setBaseURI(string memory BaseURI) public onlyOwner {
        baseURI = BaseURI;
    }

    /**
     * @dev Base URI for computing {tokenURI}. Empty by default, can be overriden
     * in child contracts.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    /**
     * Set the current token price
     */
    function setCurrentPrice(uint256 currentPrice) public onlyOwner {
        CURRENT_PRICE = currentPrice;
    }

    function changeControllerAddress(address _contollerAddress)
        public
        onlyOwner
    {
        transferController = ITransferController(_contollerAddress);
    }
}