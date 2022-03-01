pragma solidity 0.4.23;

contract Owned {
    address contractOwner;

    constructor() public {
        contractOwner = msg.sender;
    }

    function whoIsTheOwner() public view returns(address) {
        return contractOwner;
    }

    function changeOwner(address newOwner) public returns(bool) {
        require(newOwner != address(0));
        if (contractOwner == msg.sender) {
            contractOwner = newOwner;
            return true;
        }
        return false;
    }
}


contract Mortal is Owned  {
    function kill() public {
        if (msg.sender == contractOwner) selfdestruct(contractOwner);
    }
}

contract LivroVisitas is Mortal {
    mapping (address=>string) livro;

    function recordVisit(address visitor, string message) public returns(bool) {
        require(visitor != address(0));
        livro[visitor] = message;
        return true;
    }

    function getMessageOfVisit(address visitor) public view returns(string) {
        if (bytes(livro[visitor]).length > 1) {
            return livro[visitor];
        } else {
            return "";
        }
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
}
