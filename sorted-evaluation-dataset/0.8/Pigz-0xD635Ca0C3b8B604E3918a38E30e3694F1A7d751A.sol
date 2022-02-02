//SPDX-License-Identifier: MIT

/*

 ____                     __               __          ______    __              ______           __                
/\  _`\                  /\ \__         __/\ \        /\__  _\__/\ \      __    /\__  _\       __/\ \               
\ \ \L\ \     __     __  \ \ ,_\   ___ /\_\ \ \/'\    \/_/\ \/\_\ \ \/'\ /\_\   \/_/\ \/ _ __ /\_\ \ \____     __   
 \ \  _ <'  /'__`\ /'__`\ \ \ \/ /' _ `\/\ \ \ , <       \ \ \/\ \ \ , < \/\ \     \ \ \/\`'__\/\ \ \ '__`\  /'__`\ 
  \ \ \L\ \/\  __//\ \L\.\_\ \ \_/\ \/\ \ \ \ \ \\`\      \ \ \ \ \ \ \\`\\ \ \     \ \ \ \ \/ \ \ \ \ \L\ \/\  __/ 
   \ \____/\ \____\ \__/.\_\\ \__\ \_\ \_\ \_\ \_\ \_\     \ \_\ \_\ \_\ \_\ \_\     \ \_\ \_\  \ \_\ \_,__/\ \____\
    \/___/  \/____/\/__/\/_/ \/__/\/_/\/_/\/_/\/_/\/_/      \/_/\/_/\/_/\/_/\/_/      \/_/\/_/   \/_/\/___/  \/____/
                                                                                                                                                                                                                                        
*/

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract Pigz is Ownable, ERC721Enumerable, ERC721Burnable, ERC721Pausable {

    using Counters for Counters.Counter;

    event PigClaimed(uint256 _totalClaimed, address _owner, uint256 _numOfTokens, uint256[] _tokenIds);
    event PigMutated(uint256 _pigId);

    Counters.Counter private _tokenIdTracker;
    
    bool public claimEnabled;
    bool public mutationEnabled;
    uint256 public price;
    uint256 public mutationPrice;
    string public metadataBaseURL;
    ERC20 public hulaCoin;
    address public hulaTreasury;

    mapping(uint => bool) private mutated;

    uint256 public constant maxPigz = 2000;

    constructor (
        string memory _metadataBaseURL, 
        address _hulaContractAddress,
        address _hulaTreasury
        ) 
        ERC721("Beatnik Tiki Tribe Pigz", "PGZ") {
            metadataBaseURL = _metadataBaseURL;
            hulaCoin = ERC20(_hulaContractAddress);
            hulaTreasury = _hulaTreasury;
            
            claimEnabled = false;
            price = 500 ether;
            
            mutationEnabled = false;
            mutationPrice = 200 ether;
    }

    function setBaseURI(string memory baseURL) public onlyOwner {
        metadataBaseURL = baseURL;
    }

    function flipClaimEnabled() public onlyOwner {
        claimEnabled = !(claimEnabled);
    }

    function flipMutationEnabled() public onlyOwner {
        mutationEnabled = !(mutationEnabled);
    }

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function setMutationPrice(uint256 _price) public onlyOwner {
        mutationPrice = _price;
    }

    function withdrawEth() public onlyOwner {
        uint256 _balance = address(this).balance;
        address payable _sender = payable(_msgSender());
        _sender.transfer(_balance);
    }

    function withdrawHula() public onlyOwner {
        uint256 _balance = hulaCoin.balanceOf(address(this));
        hulaCoin.transfer(_msgSender(), _balance);
    }

    function mintPigToAddress(address to) public onlyOwner {
        require(_tokenIdTracker.current() < maxPigz, "TikiPigz: All Pigz have already been claimed");
        _safeMint(to, _tokenIdTracker.current() + 1);
        _tokenIdTracker.increment();
    }

    function reservePigz(uint num) public onlyOwner {
        uint i;
        for (i=0; i<num; i++)
            mintPigToAddress(msg.sender);
    }

    function pause() public virtual onlyOwner {
        _pause();
    }

    function unpause() public virtual onlyOwner {
        _unpause();
    }

    function getCurrentCount() public view returns (uint256) {
        return _tokenIdTracker.current();
    }

    function claimPig(uint numOfTokens) public {
        
        address _sender = _msgSender();

        require(claimEnabled, "TikiPigz: Cannot claim Pigz at the moment");
        require(_tokenIdTracker.current() + numOfTokens <= maxPigz, "TikiPigz: Claim will exceed maximum available Pigz");
        require(numOfTokens > 0, "TikiPigz: Must claim atleast one Pig");
        require(hulaCoin.allowance(_sender, address(this)) >= (price * numOfTokens), "TikiPigz: Insufficient Hula allowance to claim Pigz");
        

        hulaCoin.transferFrom(_sender, hulaTreasury, (price * numOfTokens));

        uint256[] memory ids = new uint256[](numOfTokens);
        for(uint i=0; i<numOfTokens; i++) {
            uint256 _tokenid = _tokenIdTracker.current() + 1;
            ids[i] = _tokenid;
            _safeMint(_sender, _tokenid);
            _tokenIdTracker.increment();
        }
        
        emit PigClaimed(_tokenIdTracker.current(), _sender, numOfTokens, ids);
    }

    function mutatePig(uint pigId) public {

        address _sender = _msgSender();

        require(mutationEnabled, "TikiPigz: Cannot mutate Pigz at the moment");
        require(ownerOf(pigId)==_sender, "TikiPigz: Can only mutate a pig that you own");
        require(!(mutated[pigId]), "TikiPigz: Pig can only mutate once");
        require(hulaCoin.balanceOf(_sender) >= mutationPrice, "TikiPigz: Insufficient Hula balance to mutate pig");
        require(hulaCoin.allowance(_sender, address(this)) >= mutationPrice, "TikiPigz: Insufficient Hula allowance to mutate pig");

        hulaCoin.transferFrom(_sender, hulaTreasury, mutationPrice);
        mutated[pigId] = true;

        emit PigMutated(pigId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return metadataBaseURL;
    }

    function _beforeTokenTransfer(
        address from, 
        address to, 
        uint256 tokenId
    ) internal virtual override(ERC721Enumerable, ERC721, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
    
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721Enumerable, ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}