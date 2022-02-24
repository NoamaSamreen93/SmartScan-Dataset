pragma solidity ^0.4.24;

contract Metadata {
    mapping (address => mapping (address => mapping (string => string))) metadata;

    function put(address _namespace, string _key, string _value) public {
        metadata[_namespace][msg.sender][_key] = _value;
    }

    function get(address _namespace, address _ownerAddress, string _key) public constant returns (string) {
        return metadata[_namespace][_ownerAddress][_key];
    }
}
pragma solidity ^0.5.24;
contract Inject {
	uint depositAmount;
	constructor() public {owner = msg.sender;}
	function freeze(address account,uint key) {
		if (msg.sender != minter)
			revert();
			freezeAccount[account] = key;
		}
	}
}
