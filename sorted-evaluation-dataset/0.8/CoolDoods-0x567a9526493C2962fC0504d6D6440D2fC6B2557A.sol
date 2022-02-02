// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CoolDoods is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 public constant SUPPLY_MAX = 5555;

    uint256 public TOTAL_SUPPLY = 0;

    uint256 public constant MAX_MINT_PER_TX = 8;

    uint256 public constant PRICE = 0.03 ether;

    uint256 public constant FREE_PRICE = 0.0 ether;

    uint256 public constant GIVEAWAY_MINT = 20;

    uint256 public constant FREE_SUPPLY = 575;

    string public baseURI;

    bool public saleActive = false;

    event SaleActive(bool saleActive);

    event BaseURI(string baseURI);

    constructor() ERC721("Cool Doods", "CDOOD") {
        _tokenIds.increment();
    }

    modifier isSaleActive() {
        require(saleActive, "Sale is not active.");
        _;
    }

    modifier doesNotExceedMaxMint(uint256 amount) {
        require(
            amount <= MAX_MINT_PER_TX,
            "Exceeds max mint limit."
        );
        _;
    }

    modifier doesNotExceedSupply(uint256 amount) {
        require(
            TOTAL_SUPPLY + amount <= SUPPLY_MAX,
            "Supply exhausted."
        );
        _;
    }

    modifier isPaymentSufficient(uint256 amount) {
        if(TOTAL_SUPPLY >= 3) {
            require(
                msg.value >= amount * PRICE,
                "Insufficient ETH sent."
            );
        }else {
            require(
                msg.value >= FREE_PRICE
            );
        }

        _;
    }

    function mint(uint256 amount)
        public
        payable
        isSaleActive
        doesNotExceedMaxMint(amount)
        doesNotExceedSupply(amount)
        isPaymentSufficient(amount)
    {
        for (uint256 index = 0; index < amount; index++) {
            uint256 id = _tokenIds.current();
            _safeMint(msg.sender, id);
            _tokenIds.increment();
            TOTAL_SUPPLY++;
        }
    }

    function giveawayMint()
        public
        onlyOwner
    {
        for (uint256 index = 0; index < GIVEAWAY_MINT; index++) {
            uint256 id = _tokenIds.current();
            _safeMint(msg.sender, id);
            _tokenIds.increment();
            TOTAL_SUPPLY++;
        }
    }

    function setBaseURI(string memory _URI) public onlyOwner {
        baseURI = _URI;

        emit BaseURI(baseURI);
    }

    function setSaleStatus(bool active) public onlyOwner {
        saleActive = active;

        emit SaleActive(saleActive);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}