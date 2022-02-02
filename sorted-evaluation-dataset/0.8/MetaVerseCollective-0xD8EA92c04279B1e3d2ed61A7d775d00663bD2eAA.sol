//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";






contract MetaVerseCollective is ERC721, Ownable {
    using Strings for uint256;
  
    using Counters for Counters.Counter;
    
    uint256 public constant MVC_LIMIT = 1;
    uint public price = 0.08 ether;

    
   
   
    
    
    
   bool public mintEnabled;
    string private baseTokenURI;
    string private defaultTokenURI;
    
	
    address private ownerAddress;
    
   
    
    
    string private _contractURI = '';
    string private _tokenBaseURI = '';
    
    Counters.Counter private _publicMVC;
    
     modifier isNotPaused(bool _enabled) {
        require(_enabled, "Mint paused");
        _;
     }


    constructor() ERC721("MetaVerse Collective", "MVC")  {
           
        
    }
    
    function setPrice(uint _newPrice) external onlyOwner {
        price = _newPrice;
    }

function setContractURI(string memory URI) public onlyOwner {
    _contractURI = URI;
  }

    function purchase(uint numberOfTokens)  public payable {
       
        require(numberOfTokens <= MVC_LIMIT, 'Can only mint up to 1 MVC');
        require(price * numberOfTokens <= msg.value, 'ETH amount is not sufficient');
        
        
       
            
    for (uint256 i = 0; i < numberOfTokens; i++) {
      uint256 tokenId =  _publicMVC.current();
       _publicMVC.increment();
       _safeMint(msg.sender, tokenId);
    }
      
      
      
        
        
      }
    
    
    
  function setMintEnabled(bool _val) external onlyOwner {
        mintEnabled = _val;
    }
        
        


    
       
   
    
     function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }
    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    
    function withdraw() external  onlyOwner {
    uint256 balance = address(this).balance;

    

    payable(msg.sender).transfer(balance);
  }

}