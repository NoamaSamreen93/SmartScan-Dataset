pragma solidity ^0.4.23;

contract Bitmonds {
    struct BitmondsOwner {
        string bitmond;
        string owner;
    }

    BitmondsOwner[] internal registry;

    function take(string Bitmond, string Owner) public {
        registry.push(BitmondsOwner(Bitmond, Owner));
    }

    function lookup(string Bitmond) public view returns (string Owner) {
        for (uint i = 0; i < registry.length; i++) {
            if (compareStrings(Bitmond, registry[i].bitmond)) {
                Owner = registry[i].owner;
            }
        }
    }

    function compareStrings (string a, string b) internal pure returns (bool) {
        return (keccak256(a) == keccak256(b));
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
 }
