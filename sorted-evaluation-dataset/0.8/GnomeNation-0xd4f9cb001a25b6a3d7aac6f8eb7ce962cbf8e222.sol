// SPDX-License-Identifier: GPL-3.0
// Author: Pagzi Tech Inc. | 2022
// Gnome Nation | 2022
pragma solidity ^0.8.11;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GnomeNation is ERC721, Ownable {
  string public baseURI;
  uint256 public cost = 0.08 ether;
  uint256 public supply = 10000;
  uint256 public totalSupply;
  address gnomebuilder = 0xF4617b57ad853f4Bc2Ce3f06C0D74958c240633c;
  address gnomeartist = 0xB2a0a3568ae7370310F489EbB8947964353D4620;
  address gnomeleader = 0x53729421B21d06E65fbc4C67d12B04A66EC182aA;
  //presale settings
  uint256 public claimDate = 1642078800;
  uint256 public publicDate = 1642165200;
  mapping(address => uint256) public mintPasses;

  constructor(
  string memory _initBaseURI
  ) ERC721("Gnome Nation", "GNOME"){
  setBaseURI(_initBaseURI);
  setMintPasses();
  }
  
  // public
  function mint(uint256 _mintAmount) public payable{
  require(publicDate <= block.timestamp, "Not yet");
  require(totalSupply + _mintAmount + 1 <= supply, "0" );
  require(msg.value >= cost * _mintAmount);
  for (uint256 i; i < _mintAmount; i++) {
  _safeMint(msg.sender, totalSupply + 1 + i);
  }
  totalSupply += _mintAmount;
  }
  function presaleMint(uint256 _mintAmount) public payable{
  require(claimDate <= block.timestamp, "Not yet");
  require(totalSupply + _mintAmount + 1 <= supply, "0" );
  require(msg.value >= cost * _mintAmount);
  for (uint256 i; i < _mintAmount; i++) {
  _safeMint(msg.sender, totalSupply + 1 + i);
  }
  totalSupply += _mintAmount;
  }
  function claim() public{
  require(claimDate <= block.timestamp, "Not yet");
  require(totalSupply + 2 <= supply, "0" );
  uint256 reserve = mintPasses[msg.sender];
  require(reserve > 0, "Low reserve");
  _safeMint(msg.sender, totalSupply + 1);
  mintPasses[msg.sender] = 0;
  totalSupply++;
  }

  //only owner
  function gift(uint[] calldata quantity, address[] calldata recipient) external onlyOwner{
  require(quantity.length == recipient.length, "Provide quantities and recipients" );
  uint totalQuantity = 0;
  for(uint i = 0; i < quantity.length; ++i){
    totalQuantity += quantity[i];
  }
  require(totalSupply + totalQuantity + 1 <= supply, "0" );
  delete totalQuantity;
  for(uint i = 0; i < recipient.length; ++i){
    for(uint j = 0; j < quantity[i]; ++j){
    _safeMint(recipient[i], totalSupply + 1);
    }
  }
  totalSupply += totalQuantity;
  }
  function withdraw() public onlyOwner {
  uint256 balance = address(this).balance;
  payable(gnomeartist).transfer((balance * 100) / 1000);
  payable(gnomebuilder).transfer((balance * 200) / 1000);
  payable(gnomeleader).transfer((balance * 700) / 1000);
  }  
  function setCost(uint256 _cost) public onlyOwner {
  cost = _cost;
  }
  function setSupply(uint256 _supply) public onlyOwner {
  supply = _supply;
  }
  function setBaseURI(string memory _newBaseURI) public onlyOwner {
  baseURI = _newBaseURI;
  }
  
  //internal
  function setMintPasses() internal {
  mintPasses[0x169353769BE5ff4bC5781d6776DD84af408c7414] = 1;
  mintPasses[0x0005dd02a10F6d0Ba855691B2Ee4457FaC425249] = 1;
  mintPasses[0x96C81A1B91c1E98EC486289113A95E9c69906e26] = 1;
  mintPasses[0x63504aCa8fB4c9C16C2F435adBEfAAEc218b0277] = 1;
  mintPasses[0xF23a6D0b3e1E166c78CA2FaB4C524cFA9d2198E3] = 1;
  mintPasses[0x3A516381A0A49534C1576C3F28C646beBb3c8AeB] = 1;
  mintPasses[0x1298BA6179936FDFc7e55f27F58b3b5fe3E09e9e] = 1;
  mintPasses[0x4e0096489B2b3B4b878ab40A33bD53ae38DE4943] = 1;
  mintPasses[0x64Aa03Ae866cc2C3090bd8A868Fdd2D44aD3f3B4] = 1;
  mintPasses[0xf4b3Bd8d26820B2E5e300524000d4eE0FAF7405F] = 1;
  mintPasses[0xAA3CE3786277AbFEBA360aA253D563ed3eb39DEb] = 1;
  mintPasses[0xB2D58aF720ee38f1a9f9c5feD3aB0ffBbc29d183] = 1;
  mintPasses[0xe2729Bc1e9fb2eFA2182e7f44431978CE06352fE] = 1;
  mintPasses[0xEF36f4d2A2f04D9284b1758518A9B8C6371ACCEa] = 1;
  mintPasses[0x23f0FDCf528D715A155A00c07C6B592069BE906F] = 1;
  mintPasses[0xb8a338497c6D44Ced849507a95A79B7dF671D625] = 1;
  mintPasses[0x99b7a3A449849C31Dd693c6E1Cf22D1fd9Eb1450] = 1;
  for (uint256 i; i < 20; i++) {
  _safeMint(gnomeleader, totalSupply + 1 + i);
  }
  totalSupply = 20;
  }
  function _baseURI() internal view override returns (string memory) {
  return baseURI;
  }
}