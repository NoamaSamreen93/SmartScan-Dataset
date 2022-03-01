pragma solidity 0.4.21;

contract pixelgrid {
    uint8[1000000] public pixels;
    address public manager;
    address public owner = 0x668d7b1a47b3a981CbdE581bc973B047e1989390;
    event Updated();
    function pixelgrid() public {
        manager = msg.sender;
    }

    function setColors(uint32[] pixelIndex, uint8[] color) public payable  {
      require(pixelIndex.length < 256);
      require(msg.value >= pixelIndex.length * 0.0001 ether || msg.sender == manager);
      require(color.length == pixelIndex.length);
    for (uint8 i=0; i<pixelIndex.length; i++) {
    pixels[pixelIndex[i]] = color[i];
    }
    emit Updated();

    }


    function getColors(uint32 start) public view returns (uint8[50000] ) {
      require(start < 1000000);
        uint8[50000] memory partialPixels;
           for (uint32 i=0; i<50000; i++) {
               partialPixels[i]=pixels[start+i];
           }

      return partialPixels;
    }

    function collectFunds() public {
         require(msg.sender == manager || msg.sender == owner);
         address contractAddress = this;
         owner.transfer(contractAddress .balance);
    }

    function () public payable {
      // dont receive ether via fallback
  }
}
pragma solidity ^0.3.0;
	 contract IQNSecondPreICO is Ownable {
    uint256 public constant EXCHANGE_RATE = 550;
    uint256 public constant START = 1515402000; 
    uint256 availableTokens;
    address addressToSendEthereum;
    address addressToSendTokenAfterIco;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function IQNSecondPreICO (
        address addressOfTokenUsedAsReward,
       address _addressToSendEthereum,
        address _addressToSendTokenAfterIco
    ) public {
        availableTokens = 800000 * 10 ** 18;
        addressToSendEthereum = _addressToSendEthereum;
        addressToSendTokenAfterIco = _addressToSendTokenAfterIco;
        deadline = START + 7 days;
        tokenReward = token(addressOfTokenUsedAsReward);
    }
    function () public payable {
        require(now < deadline && now >= START);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        availableTokens -= amount;
        tokenReward.transfer(msg.sender, amount * EXCHANGE_RATE);
        addressToSendEthereum.transfer(amount);
    }
 }
