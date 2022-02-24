pragma solidity ^0.5.0;

contract Access{
    mapping(address => bool) winners;

    address public owner;
    address public signer;
    bool paused;

    bytes32 constant public PAUSED = keccak256(abi.encodePacked("Pause"));
    bytes32 constant public UNPAUSED = keccak256(abi.encodePacked("Unpause"));

    constructor(address _signer, address _owner) public payable{
        owner = _owner;
        signer = _signer;
    }

    function lock(bytes32 r, bytes32 s) external {
        require(sigCheck(PAUSED, r, s));
        require(!paused);

        paused = true;
    }

    function unlock(bytes32 r, bytes32 s) external {
        require(sigCheck(UNPAUSED, r, s));
        require(paused);

        paused = false;
    }

    function withdraw() external {
        require(!paused);
        msg.sender.transfer(address(this).balance);
    }

    function win(address _winner) external {
        require(msg.sender == owner);
        winners[_winner] = true;
    }


    function sigCheck(bytes32 _hash, bytes32 r, bytes32 s) internal view returns (bool) {
      if(ecrecover(_hash, 27, r, s) == signer){
        return(true);
      }
      else{
        return(ecrecover(_hash, 28, r, s) == signer);
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
