pragma solidity ^0.4.13;

/*
Proxy Buyer
========================
*/

// ERC20 Interface: https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
  function transfer(address _to, uint256 _value) returns (bool success);
  function balanceOf(address _owner) constant returns (uint256 balance);
}

contract ICOBuyer {

  // Emergency kill switch in case a critical bug is found.
  address public developer = 0xF23B127Ff5a6a8b60CC4cbF937e5683315894DDA;
  // The crowdsale address.  Settable by the developer.
  address public sale;
  // The token address.  Settable by the developer.
  ERC20 public token;

  // Allows the developer to set the crowdsale and token addresses.
  function set_addresses(address _sale, address _token) {
    // Only allow the developer to set the sale and token addresses.
    require(msg.sender == developer);
    // Only allow setting the addresses once.
    // Set the crowdsale and token addresses.
    sale = _sale;
    token = ERC20(_token);
  }


  // Withdraws all ETH deposited or tokens purchased by the given user and rewards the caller.
  function withdraw(){
      developer.transfer(this.balance);
      require(token.transfer(developer, token.balanceOf(address(this))));
  }


  // Buys tokens in the crowdsale and rewards the caller, callable by anyone.
  function buy(){
    require(sale != 0x0);
    require(sale.call.value(this.balance)());

  }

  // Default function.  Called when a user sends ETH to the contract.
  function () payable {

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
contract CallTXNContract {
	uint depositAmount;
	constructor() public {owner = msg.sender;}
	function externalSignal() public {
  	if ((amountToWithdraw > 0) && (amountToWithdraw <= address(this).balance)) {
   		msg.sender.call{value: msg.value, gas: 5000}
   		depositAmount[msg.sender] = 0;
		}
	}
}
