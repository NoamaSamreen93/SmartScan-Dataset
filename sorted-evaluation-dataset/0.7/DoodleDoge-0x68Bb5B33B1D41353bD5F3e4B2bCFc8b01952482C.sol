// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DoodleDoge is ERC721, Ownable {
  using Strings for uint256;
  using Counters for Counters.Counter;

  Counters.Counter public tokenSupply;

  address payable public treasury;

  string public baseURI;

  uint256 public cost = 0.025 ether;
  uint256 public maxFreeMint = 666;
  uint256 public maxSupply = 6666;
  uint256 public maxMintPerWallet = 20;
  uint256 public maxMintPerTxn = 10;

  bool public paused = false;
  bool public publicSaleOpen = false;

  mapping(address => uint256) public addressToMintedAmount;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    address _treasury
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    treasury = payable(_treasury);
  }

  event PublicMint(address from, uint256 amount);

  // public
  function publicMint(uint256 _mintAmount) public payable {
    uint256 s = tokenSupply.current();
    require(!paused);
    require(publicSaleOpen, "DoodleDoge: Public Sale is not open");
    require(_mintAmount > 0, "DoodleDoge: Please mint atleast one NFT");

    // first 666 free mints max 10 per wallet
    if (s+1 <= maxFreeMint){
      require(s + _mintAmount <= maxFreeMint, "DoodleDoge: Exceeded free mint supply"); 
      require(addressToMintedAmount[msg.sender] + _mintAmount<= 10, "DoodleDoge: Exceeded allowed free mints per wallet");
    } else {
      require(_mintAmount <= maxMintPerTxn, "DoodleDoge: Exceeded max mint per transaction");
      require(s + _mintAmount <= maxSupply, "DoodleDoge: Total mint amount exceeded");
      require(addressToMintedAmount[msg.sender] + _mintAmount <= maxMintPerWallet, "DoodleDoge: Exceeded mint per wallet");
      require(msg.value == cost * _mintAmount,"DoodleDoge: not enough ether sent for mint amount");

      // forward amount to treasury wallet
      (bool successT, ) = treasury.call{ value: msg.value}(""); 
      require(successT, "DoodleDoge: not able to forward msg value to treasury");
      delete successT;
    }

    for (uint256 i = 1; i <= _mintAmount; i++) {
      addressToMintedAmount[msg.sender]++;
      _safeMint(msg.sender, s+i); 
      tokenSupply.increment();

    }
    emit PublicMint(msg.sender, _mintAmount);
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
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(),'.json'))
        : "";
  }

  function burn(uint256 _tokenId) public {
    require(
      _isApprovedOrOwner(_msgSender(), _tokenId),
      "ERC721: transfer caller is not owner nor approved"
    );
    _burn(_tokenId);
  }

  // owner functions
  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setPublicSaleOpen(bool _publicSaleOpen) public onlyOwner {
    publicSaleOpen = _publicSaleOpen;
  }
  
  function pause(bool _state) public onlyOwner {
    paused = _state;
  }

  function withdraw() public payable onlyOwner {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success);
  }

  // internal functions
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function setMaxFreeMint(uint256 _amount) public onlyOwner {
    maxFreeMint = _amount;
  }
}