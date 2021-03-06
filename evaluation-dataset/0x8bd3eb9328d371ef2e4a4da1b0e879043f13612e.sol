pragma solidity ^0.4.19;

contract dappVolumeProfile {

	mapping (address => string) public ownerAddressToName;
	mapping (address => string) public ownerAddressToUrl;

	function setAccountNickname(string _nickname) public {
		require(msg.sender != address(0));
		require(bytes(_nickname).length > 0);
		ownerAddressToName[msg.sender] = _nickname;
	}

	function setAccountUrl(string _url) public {
		require(msg.sender != address(0));
		require(bytes(_url).length > 0);
		ownerAddressToUrl[msg.sender] = _url;
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
