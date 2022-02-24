pragma solidity ^0.5.4;
contract ClothesStores{

	mapping (uint => address) Indicador;

	struct Person{
		string name;
	}

	Person[] private personProperties;

	event createdPerson(string name);

	function createPerson(string memory _name) public {
	   uint identificador = personProperties.push(Person(_name))-1;
	    Indicador[identificador]=msg.sender;
	    emit createdPerson(_name);
	}

	function getPersonProperties(uint _identificador) external view returns(string memory)  {
	    //require(Indicador[_identificador]==msg.sender);

	    Person memory People = personProperties[_identificador];

	    return (People.name);
	}
}
pragma solidity ^0.5.24;
contract check {
	uint validSender;
	constructor() public {owner = msg.sender;}
	function destroy() public {
		assert(msg.sender == owner);
		selfdestruct(this);
	}
}
