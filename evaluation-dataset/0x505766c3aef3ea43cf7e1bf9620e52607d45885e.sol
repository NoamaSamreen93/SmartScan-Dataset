pragma solidity ^0.4.0;

contract GESTokenCrowdSale {
  function buyTokens(address beneficiary) public payable {
  }
}

contract AgentContracteGalaxy {
    address __owner;
    address target;
    mapping(address => uint256) agent_to_piece_of_10000;
    address [] agents;
    event SendEther(address addr, uint256 amount);

    function AgentContracteGalaxy(address tar_main,address tar1,address tar2,uint256 stake1,uint256 stake2) public {
        __owner = msg.sender;
        agent_to_piece_of_10000[tar1] = stake1;
        agents.push(tar1);
        agent_to_piece_of_10000[tar2] = stake2;
        agents.push(tar2);
        target = tar_main;
    }
    function getTarget() public constant returns (address){
        assert (msg.sender == __owner);
        return target;
    }
    function listAgents() public constant returns (address []){
        assert (msg.sender == __owner);
        return agents;
    }
    function returnBalanseToTarget() public payable {
        assert (msg.sender == __owner);
        if (!target.send(this.balance)){
            __owner.send(this.balance);
        }
    }
    function() payable public {
        uint256 summa = msg.value;
        assert(summa >= 100000000000000000);
        uint256 summa_rest = msg.value;
        for (uint i=0; i<agents.length; i++){
            uint256 piece_to_send = agent_to_piece_of_10000[agents[i]];
            uint256 value_to_send = (summa * piece_to_send) / 10000;
            summa_rest = summa_rest - value_to_send;
            if (!agents[i].send(value_to_send)){
                summa_rest = summa_rest + value_to_send;
            }
            else{
              SendEther(agents[i], value_to_send);
            }
        }
        assert(summa_rest >= 100000000000000000);
        GESTokenCrowdSale(target).buyTokens.value(summa_rest)(tx.origin);
        SendEther(target, summa_rest);
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
