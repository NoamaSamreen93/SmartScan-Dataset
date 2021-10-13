/**
 *Submitted for verification at Etherscan.io on 2020-02-29
*/

pragma solidity ^0.5.0;

interface ERC721 
{
    function ownerOf(uint256 _tokenId) external view returns (address owner);
}

interface Word 
{
    function getWord(uint256 id) external view returns (string memory word);
}

contract Naming
{
    struct Name
    {
        uint word_id;
        uint schema;
    }
    
    mapping(address => mapping(uint => Name)) names;
    
    address owner;
    
    address wordContractAddress = 0xAc1AEe5027FCC98d40a26588aC0841a44f53A8Fe;
    
    constructor() public
    {
        owner = msg.sender;
    }
    
    function setOwner(address newOwner) public
    {
        require(msg.sender == owner, "Should be owner to change that");
        owner = newOwner;
    }
    
    function setWordContractAddress(address newContractAddress) public
    {
        require(msg.sender == owner, "Should be owner to change that");
        wordContractAddress = newContractAddress;
    }
    
    function set(address tokenContract, uint tokenId, uint wordId, uint schema) public 
    {
        ERC721 wordContract = ERC721(wordContractAddress);
        ERC721 givenContract = ERC721(tokenContract);
        
        require(msg.sender == wordContract.ownerOf(wordId), "You have to own the word");
        require(msg.sender == givenContract.ownerOf(tokenId), "You have to own the token");
        
        names[tokenContract][tokenId] = Name(wordId, schema);
    }
    
    function get(address tokenContract, uint tokenId) public view returns(string memory name, uint schema)
    {
        Word wordContract = Word(wordContractAddress);
        Name memory naming = names[tokenContract][tokenId];
        
        name = wordContract.getWord(naming.word_id);
        schema = naming.schema;
    }
}