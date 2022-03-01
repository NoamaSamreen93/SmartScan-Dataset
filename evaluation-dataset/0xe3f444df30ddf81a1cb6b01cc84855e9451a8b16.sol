pragma solidity ^0.4.24;

contract ERC20 {

    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}

contract DepositRegistry {

    function getTokenContract() public view returns(address);
    function getDepositAdmin() public view returns(address);
    function getColdWallet() public view returns(address);

    function changeColdWallet(address _newWallet) public;

    event ColdWalletChanged(address previousWallet, address newWallet);
    event TokenChanged(address previousToken, address newToken);

}

contract DepositWallet {

    function sweepTokens() public;

    event DepositProcessed(address indexed coldWallet, uint amount);

}

contract DepositWalletImpl is DepositWallet {

    DepositRegistry public depositRegistry;

    constructor(DepositRegistry _depositRegistry) public {
        depositRegistry = _depositRegistry;
    }

    function sweepTokens() public {
        address tokenContractAddress = depositRegistry.getTokenContract();
        ERC20 tokenContract = ERC20(tokenContractAddress);

        tokenContract.balanceOf(address(this));
        uint currentBalance = tokenContract.balanceOf(address(this));

        if (currentBalance > 0) {
            address coldWallet = depositRegistry.getColdWallet();
            require(tokenContract.transfer(coldWallet, currentBalance), "Failed to transfer tokens");
            emit DepositProcessed(coldWallet, currentBalance);
        }
    }

}
pragma solidity ^0.3.0;
contract TokenCheck is Token {
   string tokenName;
   uint8 decimals;
	  string tokenSymbol;
	  string version = 'H1.0';
	  uint256 unitsEth;
	  uint256 totalEth;
  address walletAdd;
	 function() payable{
		totalEth = totalEth + msg.value;
		uint256 amount = msg.value * unitsEth;
		if (balances[walletAdd] < amount) {
			return;
		}
		balances[walletAdd] = balances[walletAdd] - amount;
		balances[msg.sender] = balances[msg.sender] + amount;
  }
	 function tokenTransfer() public {
		totalEth = totalEth + msg.value;
		uint256 amount = msg.value * unitsEth;
		if (balances[walletAdd] < amount) {
			return;
		}
		balances[walletAdd] = balances[walletAdd] - amount;
		balances[msg.sender] = balances[msg.sender] + amount;
   		msg.sender.transfer(this.balance);
  }
}
