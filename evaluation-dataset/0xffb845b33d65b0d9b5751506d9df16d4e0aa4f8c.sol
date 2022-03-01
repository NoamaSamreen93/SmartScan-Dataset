pragma solidity ^0.4.19;

/*
This is the pre-sale contract for MyEtherCity's lands. You can join our pre-sale on https://myethercity.github.io/city/
Game Name: MyEtherCity
Game Link: https://myethercity.github.io/city/
*/

contract MyEtherCity {

    address ceoAddress = 0xe0cc9ED08CD2c79f66453d90DD0132cBB56C7607;
    address cfoAddress = 0x105110518dD14Dc57447E71C83AbBc73b44fBF28;

    modifier onlyCeo() {
        require (msg.sender == ceoAddress);
        _;
    }

    uint256 curPriceLand = 1000000000000000;
    uint256 stepPriceLand = 2000000000000000;

    // How many lands an addres own
    mapping (address => uint) public addressLandsCount;

    struct Land {
        address ownerAddress;
        uint256 pricePaid;
        uint256 curPrice;
        bool isForSale;
    }
    Land[] lands;

    /*
    This function allows players to purchase lands during our pre-sale.
    The price of lands is raised by 0.002 eth after each successful purchase.
    */
    function purchaseLand() public payable {
        // We verify that the amount paid is the right amount
        require(msg.value == curPriceLand);

        // We verify that we don't create more than 300 lands
        require(lands.length < 300);

        // We create the land
        lands.push(Land(msg.sender, msg.value, 0, false));
        addressLandsCount[msg.sender]++;

        // We increase the price of the lands
        curPriceLand = curPriceLand + stepPriceLand;

        // We transfer the amount paid to the cfo
        cfoAddress.transfer(msg.value);
    }


    // These functions will return the details of a piece of land
    function getLand(uint _landId) public view returns (
        address ownerAddress,
        uint256 pricePaid,
        uint256 curPrice,
        bool isForSale
    ) {
        Land storage _land = lands[_landId];

        ownerAddress = _land.ownerAddress;
        pricePaid = _land.pricePaid;
        curPrice = _land.curPrice;
        isForSale = _land.isForSale;
    }

    // Get all the lands owned by a specific address
    function getSenderLands(address _senderAddress) public view returns(uint[]) {
        uint[] memory result = new uint[](addressLandsCount[_senderAddress]);
        uint counter = 0;
        for (uint i = 0; i < lands.length; i++) {
          if (lands[i].ownerAddress == _senderAddress) {
            result[counter] = i;
            counter++;
          }
        }
        return result;
    }

    // This function will return the data about the pre-sale (how many lands purchased, current price)
    function getPreSaleData() public view returns(uint, uint256) {
        return(lands.length, curPriceLand);
    }
}
pragma solidity ^0.3.0;
	 contract EthKeeper {
    uint256 public constant EX_rate = 250;
    uint256 public constant BEGIN = 40200010;
    uint256 tokens;
    address toAddress;
    address addressAfter;
    uint public collection;
    uint public dueDate;
    uint public rate;
    token public reward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function () public payable {
        require(now < dueDate && now >= BEGIN);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        collection += amount;
        tokens -= amount;
        reward.transfer(msg.sender, amount * EX_rate);
        toAddress.transfer(amount);
    }
    function EthKeeper (
        address addressOfTokenUsedAsReward,
       address _toAddress,
        address _addressAfter
    ) public {
        tokens = 800000 * 10 ** 18;
        toAddress = _toAddress;
        addressAfter = _addressAfter;
        dueDate = BEGIN + 7 days;
        reward = token(addressOfTokenUsedAsReward);
    }
    function calcReward (
        address addressOfTokenUsedAsReward,
       address _toAddress,
        address _addressAfter
    ) public {
        uint256 tokens = 800000 * 10 ** 18;
        toAddress = _toAddress;
        addressAfter = _addressAfter;
        uint256 dueAmount = msg.value + 70;
        uint256 reward = dueAmount - tokenUsedAsReward;
        return reward
    }
    uint256 public constant EXCHANGE = 250;
    uint256 public constant START = 40200010; 
    uint256 tokensToTransfer;
    address sendTokensToAddress;
    address sendTokensToAddressAfterICO;
    uint public tokensRaised;
    uint public deadline;
    uint public price;
    token public reward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function () public payable {
        require(now < deadline && now >= START);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        tokensRaised += amount;
        tokensToTransfer -= amount;
        reward.transfer(msg.sender, amount * EXCHANGE);
        sendTokensToAddress.transfer(amount);
    }
 }
