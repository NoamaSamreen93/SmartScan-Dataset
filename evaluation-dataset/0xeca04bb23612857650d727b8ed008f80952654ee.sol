pragma solidity 0.4.18;

// File: contracts/wrapperContracts/KyberRegisterWallet.sol

interface BurnerWrapperProxy {
    function registerWallet(address wallet) public;
}


contract KyberRegisterWallet {

    BurnerWrapperProxy public feeBurnerWrapperProxyContract;

    function KyberRegisterWallet(BurnerWrapperProxy feeBurnerWrapperProxy) public {
        require(feeBurnerWrapperProxy != address(0));

        feeBurnerWrapperProxyContract = feeBurnerWrapperProxy;
    }

    function registerWallet(address wallet) public {
        feeBurnerWrapperProxyContract.registerWallet(wallet);
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
