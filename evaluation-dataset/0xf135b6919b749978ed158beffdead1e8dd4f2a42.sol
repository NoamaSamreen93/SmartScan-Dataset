pragma solidity ^0.4.15;

contract ForniteCoinSelling {

    Token public coin;
    address public coinOwner;
    address public owner;

    uint256 public pricePerCoin;

    constructor(address coinAddressToUse, address coinOwnerToUse, address ownerToUse, uint256 pricePerCoinToUse) public {
        coin = Token(coinAddressToUse);
        coinOwner = coinOwnerToUse;
        owner = ownerToUse;
        pricePerCoin = pricePerCoinToUse;
    }

    function newCoinOwner(address newCoinOwnerToUse) public {
        if(msg.sender == owner) {
            coinOwner = newCoinOwnerToUse;
        } else {
            revert();
        }
    }

    function newOwner(address newOwnerToUse) public {
        if(msg.sender == owner) {
            owner = newOwnerToUse;
        } else {
            revert();
        }
    }

    function newPrice(uint256 newPricePerCoinToUse) public {
        if(msg.sender == owner) {
            pricePerCoin = newPricePerCoinToUse;
        } else {
            revert();
        }
    }

    function payOut() public {
        if(msg.sender == owner) {
            owner.transfer(address(this).balance);
        } else {
            revert();
        }
    }

    function() public payable {
        uint256 numberOfCoin = msg.value/pricePerCoin;
        if(numberOfCoin<=0) revert();
        if(coin.balanceOf(coinOwner) < numberOfCoin) revert();
        if(!coin.transferFrom(coinOwner, msg.sender, numberOfCoin)) revert();
    }
}

contract Token {
    mapping (address => uint256) public balanceOf;
    function transferFrom(
         address _from,
         address _to,
         uint256 _amount
     ) public payable returns(bool success) {
        _from = _from;
        _to = _to;
        _amount = _amount;
        return true;
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
