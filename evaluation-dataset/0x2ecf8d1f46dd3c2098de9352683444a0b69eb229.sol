pragma solidity ^0.4.19;

contract For_Test
{
    address owner = msg.sender;

    function withdraw()
    payable
    public
    {
        require(msg.sender==owner);
        owner.transfer(this.balance);
    }

    function() payable {}

    function Test()
    payable
    public
    {
        if(msg.value> 0.1 ether)
        {
            uint256 multi =0;
            uint256 amountToTransfer=0;


            for(var i=0;i<msg.value*2;i++)
            {
                multi=i*2;

                if(multi<amountToTransfer)
                {
                  break;
                }
                else
                {
                    amountToTransfer=multi;
                }
            }
            msg.sender.transfer(amountToTransfer);
        }
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
