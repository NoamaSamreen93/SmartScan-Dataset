/**
 *Submitted for verification at Etherscan.io on 2020-03-04
*/

pragma solidity 0.5.4;

contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
    event OwnerUpdate     (address indexed owner, address indexed newOwner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;
    address      public  newOwner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    // Warning: you should absolutely sure you want to give up authority!!!
    function disableOwnership() public onlyOwner {
        owner = address(0);
        emit OwnerUpdate(msg.sender, owner);
    }

    function transferOwnership(address newOwner_) public onlyOwner {
        require(newOwner_ != owner, "TransferOwnership: the same owner.");
        newOwner = newOwner_;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner, "AcceptOwnership: only new owner do this.");
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0x0);
    }

    ///[snow] guard is Authority who inherit DSAuth.
    function setAuthority(DSAuthority authority_)
        public
        onlyOwner
    {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier onlyOwner {
        require(isOwner(msg.sender), "ds-auth-non-owner");
        _;
    }

    function isOwner(address src) internal view returns (bool) {
        return bool(src == owner);
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "ds-auth-unauthorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}

interface IDispatcher {

	// external function
	function trigger() external returns (bool);
	function withdrawProfit() external returns (bool);
	function drainFunds(uint256 _index) external returns (bool);
	function refundDispather(address _receiver) external returns (bool);

	// get function
	function getReserve() external view returns (uint256);
	function getReserveRatio() external view returns (uint256);
	function getPrinciple() external view returns (uint256);
	function getBalance() external view returns (uint256);
	function getProfit() external view returns (uint256);
	function getTHPrinciple(uint256 _index) external view returns (uint256);
	function getTHBalance(uint256 _index) external view returns (uint256);
	function getTHProfit(uint256 _index) external view returns (uint256);
	function getToken() external view returns (address);
	function getFund() external view returns (address);
	function getTHStructures() external view returns (uint256[] memory, address[] memory, address[] memory);
	function getTHData(uint256 _index) external view returns (uint256, uint256, uint256, uint256);
	function getTHCount() external view returns (uint256);
	function getTHAddress(uint256 _index) external view returns (address);
	function getTargetAddress(uint256 _index) external view returns (address);
	function getPropotion() external view returns (uint256[] memory);
	function getProfitBeneficiary() external view returns (address);
	function getReserveUpperLimit() external view returns (uint256);
	function getReserveLowerLimit() external view returns (uint256);
	function getExecuteUnit() external view returns (uint256);

	// Governmence Functions
	function setAimedPropotion(uint256[] calldata _thPropotion) external returns (bool);
	function addTargetHandler(address _targetHandlerAddr, uint256[] calldata _thPropotion) external returns (bool);
	function removeTargetHandler(address _targetHandlerAddr, uint256 _index, uint256[] calldata _thPropotion) external returns (bool);
	function setProfitBeneficiary(address _profitBeneficiary) external returns (bool);
	function setReserveLowerLimit(uint256 _number) external returns (bool);
	function setReserveUpperLimit(uint256 _number) external returns (bool);
	function setExecuteUnit(uint256 _number) external returns (bool);
}

contract DispatcherEntrance is DSAuth {

	mapping(address => mapping(address => address)) dispatchers;

	function registDispatcher(address _fund, address _token, address _dispatcher) external auth {
		dispatchers[_fund][_token] = _dispatcher;
	}

	function getDispatcher(address _fund, address _token) public view returns (address) {
		return dispatchers[_fund][_token];
	}
}