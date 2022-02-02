// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721EnumerableB.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract PixelBillionaire is ERC721EnumerableB, Ownable, PaymentSplitter {
    using Strings for uint256; 

    string public _baseTokenURI; // Please set with trailing slash
    uint256 public reserved = 41; // actual is 40. offset by +1 to save gas
    uint256 public mintPrice = 0.04 ether;
    uint256 public maxSupply = 3890; // actual is 3888. offset by +2 (to account for reserved's +1 offset)
    // uint256 public presaleMax = 5; // actual is 4. offset by +1, to save gas by not using >= comparator
    // uint256 public mainSaleMax = 9; // actual is 8. offset by +1, to save gas by not using >= comparator

    bool public publicSaleOpen = false;
    bool public presaleOpen = false;

    mapping(address => uint256) public presaleMintedAmount;

    bytes32 public wlMerkleRoot;
    bytes32 public ogMerkleRoot;
    
    address[] private payees = [
        0xe339d5bE1d2E9059F0B3a6a8BE45e43722dd0f6B,
        0xF7479D33746bbaf8B47C31151F13345E757e00bc,
        0xD5a7E317ab12351833dCEb2E0f57d870A4aeB89f,
        0xA49eF8D3A12dc10dB603Daa5A1E75c6ff2A2652D
    ];

    uint[] private splits = [
        25,
        25,
        25,
        25
    ];

    constructor(string memory baseURI) 
        ERC721B("Pixel Billionaire", "PXLB") 
        PaymentSplitter(payees,splits) {
            //skip 0th token;
            _owners.push(address(0));
            setBaseURI(baseURI);
        }

    // MINT/GIVEAWAY FUNCTIONS
    function mint(uint256 _mintQty) public payable {
        require( publicSaleOpen, "Public sale is not open" );
        require( _mintQty < 9, "You can only mint a maximum of 8 PXLB" );
        
        uint256 supply = totalSupply();
        require( supply + _mintQty < maxSupply - reserved, "Sold out!" );
        require( msg.value >= mintPrice * _mintQty, "Ether sent is not correct" );

        for(uint256 i; i < _mintQty; i++){
            _safeMint( msg.sender, supply + i );
        }
    }

    function premint(uint256 _mintQty, bytes32[] calldata _wlProof, bytes32[] calldata _ogProof) public payable {
        require(presaleOpen, 'Presale not open');

        bytes32 leafNode = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_wlProof, wlMerkleRoot, leafNode), "Your address is not whitelisted");

        require(_mintQty < 5, 'Exceeded presale transaction limit (4)');
        require(_mintQty < 5 - presaleMintedAmount[msg.sender], 'Your address has already claimed your presale mints');
       
        uint256 supply = totalSupply();
        require(msg.value >= mintPrice * _mintQty, 'Ether sent is not correct');

        if (MerkleProof.verify(_ogProof, ogMerkleRoot, leafNode) && _mintQty > 1) {
            // Free NFT for OGs if they mint >= 2
            for (uint256 i; i < _mintQty + 1; i++) {
                _safeMint(msg.sender, supply + i);
            }
        } else {
            // Non-OG flow
            for (uint256 i; i < _mintQty; i++) {
                _safeMint(msg.sender, supply + i);
            }
        }

        // Free NFT doesn't count in presale allocated amount per address
        presaleMintedAmount[msg.sender] = presaleMintedAmount[msg.sender] + _mintQty;
    }

    function giveAway(address _to, uint256 _amount) external onlyOwner() {
        require( _amount < reserved, "Exceeds reserved PXBL supply" );

        uint256 supply = totalSupply();
        for(uint256 i; i < _amount; i++){
            _safeMint( _to, supply + i );
        }

        reserved -= _amount;
    }
    
    // SETTER FUNCTIONS
    function setMintPrice(uint256 _newPrice) public onlyOwner() {
        mintPrice = _newPrice;
    }

    function setWLMerkleRoot(bytes32 _newMerkleRoot) public onlyOwner() {
        wlMerkleRoot = _newMerkleRoot;
    }

    function setOGMerkleRoot(bytes32 _newMerkleRoot) public onlyOwner() {
        ogMerkleRoot = _newMerkleRoot;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function togglePublicSale() public onlyOwner {
        publicSaleOpen = !publicSaleOpen;
    }

    function togglePresale() public onlyOwner {
        presaleOpen = !presaleOpen;
    }

    // FUND WITHDRAWAL
    function withdrawAll() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{ value: address(this).balance }(
        ''
        );
        require(success);
    }

    function withdrawSome(uint256 weiAmount, address destinationAddress) public payable onlyOwner {
        require(address(this).balance > weiAmount, 'Cannot withdraw more than contract balance');
        (bool success, ) = payable(destinationAddress).call{ value: weiAmount }(
        ''
        );
        require(success);
    }

    // Miscellaneous
    function walletOfOwner(address _owner) public view returns(uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for(uint256 i; i < tokenCount; i++){
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), 'ERC721Metadata: URI query for nonexistent token');

        string memory currentBaseURI = _baseTokenURI;
        return bytes(currentBaseURI).length > 0 ? string (
            abi.encodePacked(currentBaseURI, tokenId.toString())
        ) : '';
    }
}