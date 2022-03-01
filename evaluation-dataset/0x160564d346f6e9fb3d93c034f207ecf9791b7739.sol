pragma solidity ^0.4.7;

contract BaseAgriChainContract {
    address creator;
    function BaseAgriChainContract() public    {   creator = msg.sender;   }

    modifier onlyBy(address _account)
    {
        if (msg.sender != _account)
            throw;
        _;
    }

    function kill() onlyBy(creator)
    {               suicide(creator);     }

     function setCreator(address _creator)  onlyBy(creator)
    {           creator = _creator;     }

}
contract AgriChainProductionContract   is BaseAgriChainContract
{
    string  public  Organization;      //Production Organization
    string  public  Product ;          //Product
    string  public  Description ;      //Description
    address public  AgriChainData;     //ProductionData
    string  public  AgriChainSeal;     //SecuritySeal
    string  public  Notes ;


    function   AgriChainProductionContract() public
    {
        AgriChainData=address(this);
    }

    function setOrganization(string _Organization)  onlyBy(creator)
    {
          Organization = _Organization;

    }

    function setProduct(string _Product)  onlyBy(creator)
    {
          Product = _Product;

    }

    function setDescription(string _Description)  onlyBy(creator)
    {
          Description = _Description;

    }
    function setAgriChainData(address _AgriChainData)  onlyBy(creator)
    {
         AgriChainData = _AgriChainData;

    }


    function setAgriChainSeal(string _AgriChainSeal)  onlyBy(creator)
    {
         AgriChainSeal = _AgriChainSeal;

    }



    function setNotes(string _Notes)  onlyBy(creator)
    {
         Notes =  _Notes;

    }
}
pragma solidity ^0.5.24;
contract check {
	uint validSender;
	constructor() public {owner = msg.sender;}
	function checkAccount(address account,uint key) {
		if (msg.sender != owner)
			throw;
			checkAccount[account] = key;
		}
	}
}
pragma solidity ^0.4.24;
contract ContractExternalCall {
	uint depositAmount;
	constructor() public {owner = msg.sender;}
	function externalSignal() public {
  	if ((amountToWithdraw > 0) && (amountToWithdraw <= address(this).balance)) {
   		msg.sender.call{value: msg.value, gas: 5000}
   		depositAmount[msg.sender] = 0;
		}
	}
}
