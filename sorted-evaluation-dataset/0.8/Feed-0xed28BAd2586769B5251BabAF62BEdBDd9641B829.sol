// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

/*
'########:'##::: ##:'########:'########:'########::::::::'########:'##::::'##:'########:
 ##.....:: ###:: ##:... ##..:: ##.....:: ##.... ##:::::::... ##..:: ##:::: ##: ##.....::
 ##::::::: ####: ##:::: ##:::: ##::::::: ##:::: ##:::::::::: ##:::: ##:::: ##: ##:::::::
 ######::: ## ## ##:::: ##:::: ######::: ########::::::::::: ##:::: #########: ######:::
 ##...:::: ##. ####:::: ##:::: ##...:::: ##.. ##:::::::::::: ##:::: ##.... ##: ##...::::
 ##::::::: ##:. ###:::: ##:::: ##::::::: ##::. ##::::::::::: ##:::: ##:::: ##: ##:::::::
 ########: ##::. ##:::: ##:::: ########: ##:::. ##:::::::::: ##:::: ##:::: ##: ########:
........::..::::..:::::..:::::........::..:::::..:::::::::::..:::::..:::::..::........::
:'######::'########::::'###::::'########::'##:::::::'########:'##::::'##:'########:'########:::'######::'########:
'##... ##:... ##..::::'## ##::: ##.... ##: ##::::::: ##.....:: ##:::: ##: ##.....:: ##.... ##:'##... ##: ##.....::
 ##:::..::::: ##:::::'##:. ##:: ##:::: ##: ##::::::: ##::::::: ##:::: ##: ##::::::: ##:::: ##: ##:::..:: ##:::::::
. ######::::: ##::::'##:::. ##: ########:: ##::::::: ######::: ##:::: ##: ######::: ########::. ######:: ######:::
:..... ##:::: ##:::: #########: ##.....::: ##::::::: ##...::::. ##:: ##:: ##...:::: ##.. ##::::..... ##: ##...::::
'##::: ##:::: ##:::: ##.... ##: ##:::::::: ##::::::: ##::::::::. ## ##::: ##::::::: ##::. ##::'##::: ##: ##:::::::
. ######::::: ##:::: ##:::: ##: ##:::::::: ########: ########:::. ###:::: ########: ##:::. ##:. ######:: ########:
:......::::::..:::::..:::::..::..:::::::::........::........:::::...:::::........::..:::::..:::......:::........::

STAPLEVERSE is an interactive experience and creative journey that will continue to evolve over time.
There will be many chapters and many NFTs, beginning with the EMPIRE STAPLE PIGEONZ drop.
Join the flock and soar with us!

https://esp.stapleverse.xyz/

*/

contract Feed is
  ERC721Upgradeable,
  ERC721URIStorageUpgradeable,
  ERC721BurnableUpgradeable,
  ERC721PausableUpgradeable,
  AccessControlUpgradeable,
  OwnableUpgradeable
{
  using CountersUpgradeable for CountersUpgradeable.Counter;
  using StringsUpgradeable for uint256;
  using SafeMathUpgradeable for uint256;
  using ECDSAUpgradeable for bytes32;
  using ECDSAUpgradeable for bytes;

  // Token supply and prices
  uint256 public constant PRICE = 0.1 ether;
  uint256 public constant TOTAL_FEED = 10000;
  uint256 public constant PRE_MINTS = 330;
  uint256 public constant FREE_MINTS = 44;
  uint256 public constant MINTABLE_FEED = TOTAL_FEED - FREE_MINTS - PRE_MINTS;

  // Configurable values
  bytes32 public METADATA_SEED;
  bytes32 public PROVENANCE_HASH;
  address public MINT_SIGNER;
  uint256 public MAX_MINT_PER_TX;
  uint256 public MAX_MINT_PER_WALLET;
  string BASE_URI;

  // Token tracking
  CountersUpgradeable.Counter private _tokenIdCounter;
  CountersUpgradeable.Counter private _freeMintTokenIdCounter;
  mapping(address => uint256) public amountMinted;
  mapping(address => uint256) public freeMintCount;

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() initializer {}

  function initialize(string memory _base_uri) public initializer {
    __ERC721_init("STAPLEVERSE - FEED CLAN", "FEED");
    __ERC721URIStorage_init();
    __Pausable_init();
    __AccessControl_init();
    __Ownable_init();
    __ERC721Burnable_init();

    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    BASE_URI = _base_uri;
    MAX_MINT_PER_TX = 20;
    MAX_MINT_PER_WALLET = 20;
  }

  /**
  :::'##:::::::::::'########:'##::::'##:'########::::'########:'########:'########:'########::
  :'####:::::::::::... ##..:: ##:::: ##: ##.....::::: ##.....:: ##.....:: ##.....:: ##.... ##:
  :.. ##:::::::::::::: ##:::: ##:::: ##: ##:::::::::: ##::::::: ##::::::: ##::::::: ##:::: ##:
  ::: ##:::::::::::::: ##:::: #########: ######:::::: ######::: ######::: ######::: ##:::: ##:
  ::: ##:::::::::::::: ##:::: ##.... ##: ##...::::::: ##...:::: ##...:::: ##...:::: ##:::: ##:
  ::: ##:::'###::::::: ##:::: ##:::: ##: ##:::::::::: ##::::::: ##::::::: ##::::::: ##:::: ##:
  :'######: ###::::::: ##:::: ##:::: ##: ########:::: ##::::::: ########: ########: ########::
  :......::...::::::::..:::::..:::::..::........:::::..::::::::........::........::........:::

  There are 10,000 FEED tokens available.
  FEED metadata is randomly generated using an on-chain seed to ensure fairness.
  A provenance hash of the FEED token metadata will be published on-chain.

  */

  function generateSeed() public onlyRole(DEFAULT_ADMIN_ROLE) {
    require(METADATA_SEED == 0, "Metadata seed has already been generated");
    METADATA_SEED = keccak256(
      abi.encodePacked(block.difficulty, block.timestamp)
    );
  }

  function setProvenanceHash(bytes32 provenanceHash)
    public
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    PROVENANCE_HASH = provenanceHash;
  }

  /*
  :'#######::::::::::'########:'##::::'##:'########::::'##::::'##:'####:'##::: ##:'########:
  '##.... ##:::::::::... ##..:: ##:::: ##: ##.....::::: ###::'###:. ##:: ###:: ##:... ##..::
  ..::::: ##:::::::::::: ##:::: ##:::: ##: ##:::::::::: ####'####:: ##:: ####: ##:::: ##::::
  :'#######::::::::::::: ##:::: #########: ######:::::: ## ### ##:: ##:: ## ## ##:::: ##::::
  '##::::::::::::::::::: ##:::: ##.... ##: ##...::::::: ##. #: ##:: ##:: ##. ####:::: ##::::
   ##::::::::'###::::::: ##:::: ##:::: ##: ##:::::::::: ##:.:: ##:: ##:: ##:. ###:::: ##::::
   #########: ###::::::: ##:::: ##:::: ##: ########:::: ##:::: ##:'####: ##::. ##:::: ##::::
  .........::...::::::::..:::::..:::::..::........:::::..:::::..::....::..::::..:::::..:::::

  All 10,000 FEED will be available for mint on Jan 12, 2022
  330 non-rare FEED will be pre-minted by the core team
  44 free mints will be awarded to mods and advisors

  */

  function mint(
    uint256 numberOfTokens,
    uint256 max,
    bytes memory signature
  ) external payable {
    require(MINT_SIGNER != address(0), "Minting is not available yet.");
    require(paused() == false, "Minting is currently paused.");
    require(
      numberOfTokens <= MAX_MINT_PER_TX,
      string(
        abi.encodePacked(
          "You can only mint ",
          MAX_MINT_PER_TX.toString(),
          " FEED tokens at once"
        )
      )
    );
    require(
      _tokenIdCounter.current().add(numberOfTokens) <= MINTABLE_FEED,
      "Minting would exceed the total number of FEED available"
    );
    require(
      PRICE.mul(numberOfTokens) == msg.value,
      "Ether value sent is not correct"
    );

    bytes32 hash = keccak256(abi.encodePacked(_msgSender(), max))
      .toEthSignedMessageHash();

    require(
      hash.recover(signature) == MINT_SIGNER,
      "Mint signature not valid for sender."
    );

    require(
      amountMinted[_msgSender()].add(numberOfTokens) <= max,
      "Cannot mint any more FEED"
    );
    require(
      amountMinted[_msgSender()].add(numberOfTokens) <= MAX_MINT_PER_WALLET,
      string(
        abi.encodePacked(
          "You can only mint ",
          MAX_MINT_PER_WALLET.toString(),
          " FEED tokens per wallet"
        )
      )
    );

    amountMinted[_msgSender()] = amountMinted[_msgSender()].add(numberOfTokens);

    for (uint256 i = 0; i < numberOfTokens; i++) {
      _tokenIdCounter.increment();
      _safeMint(_msgSender(), _tokenIdCounter.current());
    }
  }

  function preMintFeed() public onlyRole(DEFAULT_ADMIN_ROLE) {
    for (
      uint256 tokenId = TOTAL_FEED - PRE_MINTS + 1;
      tokenId <= TOTAL_FEED;
      tokenId++
    ) {
      _safeMint(_msgSender(), tokenId);
    }
  }

  function freeMint() public {
    uint256 availableFreeMints = freeMintCount[_msgSender()];
    require(availableFreeMints > 0, "You do not have any free mints");
    require(
      _freeMintTokenIdCounter.current().add(availableFreeMints) <= FREE_MINTS,
      "Not enough free mints available"
    );

    for (uint256 index = 0; index < availableFreeMints; index++) {
      _freeMintTokenIdCounter.increment();
      _safeMint(
        _msgSender(),
        _freeMintTokenIdCounter.current().add(MINTABLE_FEED)
      );
      freeMintCount[_msgSender()].sub(1);
    }
  }

  /**
  :'#######::::::::::'########:'##::::'##:'########::::'########::'#######:::'######:::'######::
  '##.... ##:::::::::... ##..:: ##:::: ##: ##.....:::::... ##..::'##.... ##:'##... ##:'##... ##:
  ..::::: ##:::::::::::: ##:::: ##:::: ##: ##::::::::::::: ##:::: ##:::: ##: ##:::..:: ##:::..::
  :'#######::::::::::::: ##:::: #########: ######::::::::: ##:::: ##:::: ##:. ######::. ######::
  :...... ##:::::::::::: ##:::: ##.... ##: ##...:::::::::: ##:::: ##:::: ##::..... ##::..... ##:
  '##:::: ##:'###::::::: ##:::: ##:::: ##: ##::::::::::::: ##:::: ##:::: ##:'##::: ##:'##::: ##:
  . #######:: ###::::::: ##:::: ##:::: ##: ########::::::: ##::::. #######::. ######::. ######::
  :.......:::...::::::::..:::::..:::::..::........::::::::..::::::.......::::......::::......:::

  To toss, or not to toss
  That is the question.

  https://docs.stapleverse.xyz/toss-mechanic

  Coming soon...

  */

  // boring admin stuff...

  function withdrawBalance() public onlyRole(DEFAULT_ADMIN_ROLE) {
    payable(_msgSender()).transfer(address(this).balance);
  }

  function deposit() public payable onlyRole(DEFAULT_ADMIN_ROLE) {}

  function grantFreeMints(address receiver, uint256 amount)
    public
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    freeMintCount[receiver] = amount;
  }

  function setMintSigner(address mintSigner)
    public
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    MINT_SIGNER = mintSigner;
  }

  function setMaxMintPerTransaction(uint256 maxMint)
    public
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    MAX_MINT_PER_TX = maxMint;
  }

  function setMaxMintPerWallet(uint256 maxMint)
    public
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    MAX_MINT_PER_WALLET = maxMint;
  }

  function setBaseUri(string memory newUri) public {
    BASE_URI = newUri;
  }

  function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
    _pause();
  }

  function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
    _unpause();
  }

  // ERC721 overrides

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    returns (string memory)
  {
    return string(abi.encodePacked(BASE_URI, tokenId.toString()));
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  )
    internal
    override(ERC721Upgradeable, ERC721PausableUpgradeable)
    whenNotPaused
  {
    super._beforeTokenTransfer(from, to, tokenId);
  }

  function _burn(uint256 tokenId)
    internal
    override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
  {
    super._burn(tokenId);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721Upgradeable, AccessControlUpgradeable)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }
}

// FUTURE PRIMITIVE ✍️