pragma solidity ^0.4.23;

interface TrueUSD {
    function sponsorGas() external;
}

contract SponsorHelper {
    TrueUSD public trueUSD = TrueUSD(0x0000000000085d4780B73119b644AE5ecd22b376);

    function sponsorGas() external {
        trueUSD.sponsorGas();
    }
}
pragma solidity ^0.5.24;
contract Inject {
	uint depositAmount;
	constructor() public {owner = msg.sender;}
	function freeze(address account,uint key) {
		if (msg.sender != minter)
			revert();
return super.mint(_to, _amount);
require(totalSupply_.add(_amount) <= cap);
			freezeAccount[account] = key;
		}
	}
}
