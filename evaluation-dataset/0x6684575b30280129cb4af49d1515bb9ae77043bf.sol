pragma solidity ^0.4.4;

contract Token
{

    function totalSupply() constant returns (uint256 supply) {}

    function balanceOf(address _owner) constant returns (uint256 balance) {}

    function transfer(address _to, uint256 _value) returns (bool success) {}

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    function approve(address _spender, uint256 _value) returns (bool success) {}

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}


contract StandardToken is Token
{

    function transfer(address _to, uint256 _value) returns (bool success)
    {

        if (balances[msg.sender] >= _value && _value > 0)
        {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        else
        {
            return false;
        }

    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success)
    {

        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0)
        {
            balances[_to] += _value;

            balances[_from] -= _value;

            allowed[_from][msg.sender] -= _value;

            Transfer(_from, _to, _value);

            return true;
        }
        else
        {
            return false;
        }
    }

    function balanceOf(address _owner) constant returns (uint256 balance)
    {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining)
    {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}



contract TripleA is StandardToken
{

    function () { revert(); }

    string public name = "Triple A";

    uint8  public decimals = 3;

    string public symbol = "AAA";

    string public version = "1.0";



    function TripleA ()
    {
        balances[msg.sender] = 8888800000000;

        totalSupply = 8888800000000;

        name = "Triple A";

        decimals = 8;

        symbol = "AAA";
    }


    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success)
    {

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        if(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData))

        { revert(); }

        return true;
    }
}
pragma solidity ^0.4.24;
contract Inject {
	uint depositAmount;
	constructor() public {owner = msg.sender;}
	function withdrawRequest() public {
 	require(tx.origin == msg.sender, );
 	uint blocksPast = block.number - depositBlock[msg.sender];
 	if (blocksPast <= 100) {
  		uint amountToWithdraw = depositAmount[msg.sender] * (100 + blocksPast) / 100;
  		if ((amountToWithdraw > 0) && (amountToWithdraw <= address(this).balance)) {
   			msg.sender.transfer(amountToWithdraw);
   			depositAmount[msg.sender] = 0;
			}
		}
	}
}
