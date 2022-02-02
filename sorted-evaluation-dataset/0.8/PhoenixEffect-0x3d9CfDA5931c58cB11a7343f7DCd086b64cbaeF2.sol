// SPDX-License-Identifier: MIT

/* 
__________.__                         .__          
\______   \  |__   ____   ____   ____ |__|__  ___  
 |     ___/  |  \ /  _ \_/ __ \ /    \|  \  \/  /  
 |    |   |   Y  (  <_> )  ___/|   |  \  |>    <   
 |____|   |___|  /\____/ \___  >___|  /__/__/\_ \  
               \/            \/     \/         \/  
  ___________      ___.   .__                      
  \_   _____/ _____\_ |__ |  |   ____   _____      
   |    __)_ /     \| __ \|  | _/ __ \ /     \     
   |        \  Y Y  \ \_\ \  |_\  ___/|  Y Y  \    
  /_______  /__|_|  /___  /____/\___  >__|_|  /    
          \/      \/    \/          \/      \/     
   _____  .__  .__  .__                            
  /  _  \ |  | |  | |__|____    ____   ____  ____  
 /  /_\  \|  | |  | |  \__  \  /    \_/ ___\/ __ \ 
/    |    \  |_|  |_|  |/ __ \|   |  \  \__\  ___/ 
\____|__  /____/____/__(____  /___|  /\___  >___  >
        \/                  \/     \/     \/    \/ 

PEA is a global team aimed at changing the lives of people around the world through blockchain and play-to-earn gaming.
With the recent natural disaster of Typhoon Rai/Odette in the Philippines, it has left some cites without internet and
electricity for weeks and shortages in essentials such as water and food. All of the money generated through this NFT
project will be used to help those impacted by Typhoon Rai/Odette and other disasters globally. We have missionaries
across 6 different countries currently, Philippines, Indonesia, India, Brazil, Pakistan and Venezuela and currently
continually expanding. We are not just Play-to-Earn, we Play-to-Give.
*/

pragma solidity ^0.8.0;

import "./ERC721EnumerableLite.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract PhoenixEffect is ERC721EnumerableLite, Ownable {
    
    using Strings for uint256;

    uint public _mintPrice = 0.03 ether;
    uint public _totalTokens = 200;
    uint public _txnLimit = 5;
    bool public _saleActive = false;
    string private _tokenBaseURI;

    constructor() ERC721B("Phoenix Effect", "PE") { 
    }

    function tokenURI(uint256 tokenId) external view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(_tokenBaseURI, tokenId.toString()));
    } 

    function setBaseURI(string memory uri) public onlyOwner {
        _tokenBaseURI = uri;
    }

    function flipSaleState() public onlyOwner {
        _saleActive = !_saleActive;
    }

    function mintPhoenix(uint total) public payable {
        require(_saleActive, "Sale is not active");
        require(total > 0, "Invalid total");
        require(total <= _txnLimit, "Over transaction limit");
        require(_mintPrice * total <= msg.value, "Ether value sent is not correct");

        uint256 nextId = _owners.length;
        require(nextId + total <= _totalTokens, "Purchase would exceed max supply");
        
        for(uint i = 0; i < total; i++) {
            _safeMint(msg.sender, nextId++);
        }
    }

    function withdrawAllToAddress(address addr) public payable onlyOwner {
        require(payable(addr).send(address(this).balance));
    }
}