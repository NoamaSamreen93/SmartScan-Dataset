// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721EfficientEnumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/*
 * @title OpenAEye
 * OpenAEye - Smart Contract for https://www.open-a-eye.com/.
 *
 *                                                            
                                                                                
                                   @@@@@@@@@@@                        
                         /@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,                        
       @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      
     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    
      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     
       @@@@@@@@@@@@@@@@@@@@@@@@@       @@@@@@@@@@@@@@@@@@@@@@@@@      
         @@@@@@@@@@@@@@@@@@@@                       @@@@@@@@@@@@@@@@@@@@        
          @@@@@@@@@@@@@@@@@@         @@@@@@/         @@@@@@@@@@@@@@@@@*         
           @@@@@@@@@@@@@@@        @@@@@@@@@@@@@        @@@@@@@@@@@@@@@          
            @@@@@@@@@@@@@@       @@@@@@@@@@@@@@@       @@@@@@@@@@@@@@           
             @@@@@@@@@@@@@      @@@@@@@@@@@@@@@@%      @@@@@@@@@@@@@            
              @@@@@@@@@@@@       @@@@@@@@@@@@@@@       @@@@@@@@@@@@             
                 @@@@@@@@@        @@@@@@@@@@@@@       .@@@@@@@@@                
                    @@@@@@@@          @@@@@          @@@@@@@@                   
                     @@@@@@@@                       @@@@@@@*                    
       #@@@@@@@@@@                 @@@@@@@@@@                     
                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     
                       @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      
                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                        
                           @@@@@@@@@@@@@@@@@@@@@@@@@@@                          
                              *@@@@@@@@@@@@@@@@@@@,                             
                       @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      
                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                
                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@               
               @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              
              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   
 *
 *
 */
contract OpenAEye is ERC721EfficientEnumerable {
    using Counters for Counters.Counter;

    enum MintingPhase {
        INITIAL_MINT, // Initial Mint Phase
        PUBLIC_MINT,  // Primary Minting Phase
        CLOSED        // Minting Closed
    }
    enum TokenState {
        EyeAmOpen,
        EyeAmOk,
        EyeAmMeh,
        EyeAmBored
    }
    struct MetadataBatch {
        uint256 endIndex;
        string metadataURI;
    }
    event EyeMinted(uint256 tokenId);

    MintingPhase private currentMintingPhase;
    uint private constant MAX_EYES_MINTED_PER_TRANSACTION = 10;
    uint256 private constant MINT_PRICE_PER_TOKEN = 0.065 ether;
    MetadataBatch[] private metadataURIs;
    bytes private constant provenance = "57a5cd83d310a7fdbf5a7c12ebbbefdf42ea73336e737be664323d80697164b4";

    mapping(uint256 => Counters.Counter) private _sales;
    mapping(uint256 => uint256) private _lastTransferBlock;

    constructor()
        ERC721EfficientEnumerable("OpenAEye", "OAE") {
    }

    function setMintingPhase(MintingPhase mintingPhase) external onlyOwner {
        currentMintingPhase = mintingPhase;
    }

    function revealBatchMetadata(uint256 endIndex, string memory newURI) external onlyOwner {
        uint256 size = metadataURIs.length;
        uint256 lastIdRevealed = size == 0 ? 0 : metadataURIs[size - 1].endIndex;
        require(endIndex >= lastIdRevealed, "402"); // Invalid batch endIndex

        if (endIndex == lastIdRevealed) {
            metadataURIs[size - 1].metadataURI = newURI;
        } else {
            metadataURIs.push(MetadataBatch(endIndex, newURI));
        }
    }

    function reserveEyesForGiveaways(uint256 numberOfTokens) external onlyOwner ensureAvailability(numberOfTokens) {
        require(currentMintingPhase != MintingPhase.CLOSED, "403"); // Minting is closed.
        for (uint i = 0; i < numberOfTokens; i++) {
            _mintTo(owner());
        }
    }
    
    function withdraw() external onlyOwner {
        require(address(this).balance > 0, "401"); // Insufficient funds
        Address.sendValue(payable(owner()), address(this).balance);
    }

    function withdraw(uint256 amount, address payable to) external onlyOwner {
        require(address(this).balance >= amount, "401"); // Insufficient funds
        Address.sendValue(to, amount);
    }

    function mintEyes(uint256 numberOfTokens) external payable ensureAvailability(numberOfTokens) {
        require(currentMintingPhase != MintingPhase.INITIAL_MINT, "405"); // Initial Mint Only
        require(currentMintingPhase != MintingPhase.CLOSED, "403"); // Minting is closed
        require(numberOfTokens <= MAX_EYES_MINTED_PER_TRANSACTION, "410"); // Only allowed to mint 10 tokens per transaction
        require((numberOfTokens * MINT_PRICE_PER_TOKEN) <= msg.value, "465"); // Wrong ETH value sent

        for (uint i = 0; i < numberOfTokens; i++) {
            _mintTo(_msgSender());
        }
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override ensureExistance(tokenId) {
        super.transferFrom(from, to, tokenId);
        updateSalesHistory(tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override ensureExistance(tokenId) {
        super.safeTransferFrom(from, to, tokenId, _data);
        updateSalesHistory(tokenId);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    /*
    *   @dev visible for testing, to allow mocking time
    */
    function _blockNumber() internal virtual view returns (uint256) {
        return block.number;
    }

    function getTokenTimeInWallet(uint256 _tokenId) public view ensureExistance(_tokenId) returns (uint256) {
        return (_blockNumber() - _lastTransferBlock[_tokenId]) / 800;
    }

    function getTokenDecayTime(uint256 _tokenId) public view ensureExistance(_tokenId) returns (uint256) {
        uint256 tokenSales = _sales[_tokenId].current();
        uint256 offset = 0;
        for (uint i = 0; i <= 3; i++) {
            uint256 batch = tokenSales;
            if (i < 3) {
                batch = min(15, tokenSales);
            }
            offset += (1 days / (2**i)) * batch;
            tokenSales -= batch;
        }
        return min(30 days + offset, 60 days);
    }

    function getPlaceholderURI() internal virtual pure returns (string memory) {
        return "ipfs://bafkreidku2fnslorzrwjjrpwqnofcajp5dpcdd34etczpibt2datwq7ppe";
    }

    function tokenURI(uint256 _tokenId) public view override ensureExistance(_tokenId) returns (string memory) {
        for (uint i = 0; i < metadataURIs.length; i++) {
            if( _tokenId <= metadataURIs[i].endIndex ) {
                return string(
                    abi.encodePacked(
                        metadataURIs[i].metadataURI,
                        Strings.toString(_tokenId),
                        "_",
                        Strings.toString(uint256(getTokenState(_tokenId))),
                        ".json"
                    )
                );
            }
        }
        
        return getPlaceholderURI();
    }

    function getTokenState(uint256 _tokenId) private view returns (TokenState) {
        uint256 tokenAge = getTokenTimeInWallet(_tokenId) * 3 hours;
        uint256 timeToDecay = getTokenDecayTime(_tokenId);
        return TokenState(min(tokenAge / timeToDecay, 3));
    }

    function updateSalesHistory(uint256 _tokenId) private {
        _sales[_tokenId].increment();
        _lastTransferBlock[_tokenId] = _blockNumber();
    }

    function _mintTo(address _to) internal override {
        super._mintTo(_to);
        uint256 tokenId = totalSupply();
        _lastTransferBlock[tokenId] = _blockNumber();
        emit EyeMinted(tokenId);
    }
}