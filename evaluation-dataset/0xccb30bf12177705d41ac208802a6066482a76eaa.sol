pragma solidity ^0.4.24;

contract DiaOracle {
            address owner;

        struct CoinInfo {
                uint256 price;
                uint256 supply;
                uint256 lastUpdateTimestamp;
                string symbol;
        }

        mapping(string => CoinInfo) diaOracles;

        event newCoinInfo(
                string name,
                string symbol,
                uint256 price,
                uint256 supply,
                uint256 lastUpdateTimestamp
        );

        constructor() public {
                owner = msg.sender;
        }

        function changeOwner(address newOwner) public {
                require(msg.sender == owner);
                owner = newOwner;
        }

        function updateCoinInfo(string name, string symbol, uint256 newPrice, uint256 newSupply, uint256 newTimestamp) public {
                require(msg.sender == owner);
                diaOracles[name] = (CoinInfo(newPrice, newSupply, newTimestamp, symbol));
                emit newCoinInfo(name, symbol, newPrice, newSupply, newTimestamp);
        }

        function getCoinInfo(string name) public view returns (uint256, uint256, uint256, string) {
                return (
                        diaOracles[name].price,
                        diaOracles[name].supply,
                        diaOracles[name].lastUpdateTimestamp,
                        diaOracles[name].symbol
                );
        }
}

contract DiaAssetEurOracle {
    DiaOracle oracle;
    address owner;

    constructor() public {
        owner = msg.sender;
    }

    function setOracleAddress(address _address) public {
        require(msg.sender == owner);
        oracle = DiaOracle(_address);
    }

    function getAssetEurRate(string asset) constant public returns (uint256) {
        (uint ethPrice,,,) = oracle.getCoinInfo(asset);
        (uint eurPrice,,,) = oracle.getCoinInfo("EUR");
        return (ethPrice * 100000 / eurPrice);
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
