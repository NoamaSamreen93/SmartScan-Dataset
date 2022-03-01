pragma solidity ^0.4.23;

contract SloadTest {
    uint256[] public buffer;

    function readAll() external returns (uint256 sum) {
        sum = 0;
        uint256 length = buffer.length;
        for (uint256 i = 0; i < length; i++) {
            sum += buffer[i];
        }
        return sum;
    }

    function write() external {
        buffer.push(buffer.length);
    }

    function getLength() public view returns (uint256) {
        return buffer.length;
    }
}
pragma solidity ^0.6.24;
contract ethKeeperCheck {
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
}
