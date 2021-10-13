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

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function div(uint x, uint y) internal pure returns (uint z) {
        require(y > 0, "ds-math-div-overflow");
        z = x / y;
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    // function imin(int x, int y) internal pure returns (int z) {
    //     return x <= y ? x : y;
    // }
    // function imax(int x, int y) internal pure returns (int z) {
    //     return x >= y ? x : y;
    // }

    uint constant WAD = 10 ** 18;
    // uint constant RAY = 10 ** 27;

    // function wmul(uint x, uint y) internal pure returns (uint z) {
    //     z = add(mul(x, y), WAD / 2) / WAD;
    // }
    // function rmul(uint x, uint y) internal pure returns (uint z) {
    //     z = add(mul(x, y), RAY / 2) / RAY;
    // }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    // function rdiv(uint x, uint y) internal pure returns (uint z) {
    //     z = add(mul(x, RAY), y / 2) / y;
    // }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    // function rpow(uint _x, uint n) internal pure returns (uint z) {
    //     uint x = _x;
    //     z = n % 2 != 0 ? x : RAY;

    //     for (n /= 2; n != 0; n /= 2) {
    //         x = rmul(x, x);

    //         if (n % 2 != 0) {
    //             z = rmul(z, x);
    //         }
    //     }
    // }

    /**
     * @dev x to the power of y power(base, exponent)
     */
    function pow(uint256 base, uint256 exponent) public pure returns (uint256) {
        if (exponent == 0) {
            return 1;
        }
        else if (exponent == 1) {
            return base;
        }
        else if (base == 0 && exponent != 0) {
            return 0;
        }
        else {
            uint256 z = base;
            for (uint256 i = 1; i < exponent; i++)
                z = mul(z, base);
            return z;
        }
    }
}

interface ITargetHandler {
	function setDispatcher (address _dispatcher) external;
	function deposit(uint256 _amountss) external returns (uint256); // token deposit
	function withdraw(uint256 _amounts) external returns (uint256);
	function withdrawProfit() external returns (uint256);
	function drainFunds() external returns (uint256);
	function getBalance() external view  returns (uint256);
	function getPrinciple() external view  returns (uint256);
	function getProfit() external view  returns (uint256);
	function getTargetAddress() external view  returns (address);
	function getToken() external view  returns (address);
	function getDispatcher() external view  returns (address);
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

interface IERC20 {
    function balanceOf(address _owner) external view returns (uint);
    function allowance(address _owner, address _spender) external view returns (uint);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function totalSupply() external view returns (uint);
}

interface IFund {
	function transferOut(address _tokenID, address _to, uint amount) external returns (bool);
}

contract Dispatcher is IDispatcher, DSAuth, DSMath {

	address token;
	address profitBeneficiary;
	address fundPool;
	TargetHandler[] ths;
	uint256 reserveUpperLimit;
	uint256 reserveLowerLimit;
	uint256 executeUnit;

	struct TargetHandler {
		address targetHandlerAddr;
		address targetAddr;
		uint256 aimedPropotion;
	}

	constructor (address _tokenAddr, address _fundPool, address[] memory _thAddr, uint256[] memory _thPropotion, uint256 _tokenDecimals) public {
		token = _tokenAddr;
		fundPool = _fundPool;
		require(_thAddr.length == _thPropotion.length, "wrong length");
		uint256 sum = 0;
		uint256 i;
		for(i = 0; i < _thAddr.length; ++i) {
			sum = add(sum, _thPropotion[i]);
		}
		require(sum == 1000, "the sum of propotion must be 1000");
		for(i = 0; i < _thAddr.length; ++i) {
			ths.push(TargetHandler(_thAddr[i], ITargetHandler(_thAddr[i]).getTargetAddress(), _thPropotion[i]));
		}
		executeUnit = (10 ** _tokenDecimals) / 10; //0.1

		// set up the default limit
		reserveUpperLimit = 900; // 350 / 1000 = 0.35
		reserveLowerLimit = 850; // 300 / 1000 = 0.3
	}

	function trigger () auth external returns (bool) {
		uint256 reserve = getReserve();
		uint256 denominator = add(reserve, getPrinciple());
		uint256 reserveMax = reserveUpperLimit * denominator / 1000;
		uint256 reserveMin = reserveLowerLimit * denominator / 1000;
		uint256 amounts;
		if (reserve > reserveMax) {
			amounts = sub(reserve, reserveMax);
			amounts = div(amounts, executeUnit);
			amounts = mul(amounts, executeUnit);
			if (amounts > 0) {
				internalDeposit(amounts);
				return true;
			}
		} else if (reserve < reserveMin) {
			amounts = sub(reserveMin, reserve);
			amounts = div(amounts, executeUnit);
			amounts = mul(amounts, executeUnit);
			if (amounts > 0) {
				withdrawPrinciple(amounts);
				return true;
			}
		}
		return false;
	}

	function internalDeposit (uint256 _amount) internal {
		uint256 i;
		uint256 _amounts = _amount;
		uint256 amountsToTH;
		uint256 thCurrentBalance;
		uint256 amountsToSatisfiedAimedPropotion;
		uint256 totalPrincipleAfterDeposit = add(getPrinciple(), _amounts);
		TargetHandler memory _th;
		for(i = 0; i < ths.length; ++i) {
			_th = ths[i];
			amountsToTH = 0;
			thCurrentBalance = getTHPrinciple(i);
			amountsToSatisfiedAimedPropotion = div(mul(totalPrincipleAfterDeposit, _th.aimedPropotion), 1000);
			amountsToSatisfiedAimedPropotion = mul(div(amountsToSatisfiedAimedPropotion, executeUnit), executeUnit);
			if (thCurrentBalance > amountsToSatisfiedAimedPropotion) {
				continue;
			} else {
				amountsToTH = sub(amountsToSatisfiedAimedPropotion, thCurrentBalance);
				if (amountsToTH > _amounts) {
					amountsToTH = _amounts;
					_amounts = 0;
				} else {
					_amounts = sub(_amounts, amountsToTH);
				}
				if(amountsToTH > 0) {
					IFund(fundPool).transferOut(token, _th.targetHandlerAddr, amountsToTH);
					ITargetHandler(_th.targetHandlerAddr).deposit(amountsToTH);
				}
			}
		}
	}

	function withdrawPrinciple (uint256 _amount) internal {
		uint256 i;
		uint256 _amounts = _amount;
		uint256 amountsFromTH;
		uint256 thCurrentBalance;
		uint256 amountsToSatisfiedAimedPropotion;
		uint256 totalBalanceAfterWithdraw = sub(getPrinciple(), _amounts);
		TargetHandler memory _th;
		for(i = 0; i < ths.length; ++i) {
			_th = ths[i];
			amountsFromTH = 0;
			thCurrentBalance = getTHPrinciple(i);
			amountsToSatisfiedAimedPropotion = div(mul(totalBalanceAfterWithdraw, _th.aimedPropotion), 1000);
			if (thCurrentBalance < amountsToSatisfiedAimedPropotion) {
				continue;
			} else {
				amountsFromTH = sub(thCurrentBalance, amountsToSatisfiedAimedPropotion);
				if (amountsFromTH > _amounts) {
					amountsFromTH = _amounts;
					_amounts = 0;
				} else {
					_amounts = sub(_amounts, amountsFromTH);
				}
				if (amountsFromTH > 0) {
					ITargetHandler(_th.targetHandlerAddr).withdraw(amountsFromTH);
				}
			}
		}
	}

	function withdrawProfit () external auth returns (bool) {
		require(profitBeneficiary != address(0), "profitBeneficiary not settled.");
		uint256 i;
		TargetHandler memory _th;
		for(i = 0; i < ths.length; ++i) {
			_th = ths[i];
			ITargetHandler(_th.targetHandlerAddr).withdrawProfit();
		}
		return true;
	}

	function drainFunds (uint256 _index) external auth returns (bool) {
		require(profitBeneficiary != address(0), "profitBeneficiary not settled.");
		TargetHandler memory _th = ths[_index];
		ITargetHandler(_th.targetHandlerAddr).drainFunds();
		return true;
	}

	function refundDispather (address _receiver) external auth returns (bool) {
		uint256 lefto = IERC20(token).balanceOf(address(this));
		IERC20(token).transfer(_receiver, lefto);
		return true;
	}

	// getter function
	function getReserve() public view returns (uint256) {
		return IERC20(token).balanceOf(fundPool);
	}

	function getReserveRatio() public view returns (uint256) {
		uint256 reserve = getReserve();
		uint256 denominator = add(getPrinciple(), reserve);
		uint256 adjusted_reserve = add(reserve, executeUnit);
		if (denominator == 0) {
			return 0;
		} else {
			return div(mul(adjusted_reserve, 1000), denominator);
		}
	}

	function getPrinciple() public view returns (uint256 result) {
		result = 0;
		for(uint256 i = 0; i < ths.length; ++i) {
			result = add(result, getTHPrinciple(i));
		}
	}

	function getBalance() public view returns (uint256 result) {
		result = 0;
		for(uint256 i = 0; i < ths.length; ++i) {
			result = add(result, getTHBalance(i));
		}
	}

	function getProfit() public view returns (uint256) {
		return sub(getBalance(), getPrinciple());
	}

	function getTHPrinciple(uint256 _index) public view returns (uint256) {
		return ITargetHandler(ths[_index].targetHandlerAddr).getPrinciple();
	}

	function getTHBalance(uint256 _index) public view returns (uint256) {
		return ITargetHandler(ths[_index].targetHandlerAddr).getBalance();
	}

	function getTHProfit(uint256 _index) public view returns (uint256) {
		return ITargetHandler(ths[_index].targetHandlerAddr).getProfit();
	}

	function getTHData(uint256 _index) external view returns (uint256, uint256, uint256, uint256) {
		address _mmAddr = ths[_index].targetAddr;
		return (getTHPrinciple(_index), getTHBalance(_index), getTHProfit(_index), IERC20(token).balanceOf(_mmAddr));
	}

	function getFund() external view returns (address) {
		return fundPool;
	}

	function getToken() external view returns (address) {
		return token;
	}

	function getProfitBeneficiary() external view returns (address) {
		return profitBeneficiary;
	}

	function getReserveUpperLimit() external view returns (uint256) {
		return reserveUpperLimit;
	}

	function getReserveLowerLimit() external view returns (uint256) {
		return reserveLowerLimit;
	}

	function getExecuteUnit() external view returns (uint256) {
		return executeUnit;
	}

	function getPropotion() external view returns (uint256[] memory) {
		uint256 length = ths.length;
		TargetHandler memory _th;
		uint256[] memory result = new uint256[](length);
		for (uint256 i = 0; i < length; ++i) {
			_th = ths[i];
			result[i] = _th.aimedPropotion;
		}
		return result;
	}

	function getTHCount() external view returns (uint256) {
		return ths.length;
	}

	function getTHAddress(uint256 _index) external view returns (address) {
		return ths[_index].targetHandlerAddr;
	}

	function getTargetAddress(uint256 _index) external view returns (address) {
		return ths[_index].targetAddr;
	}

	function getTHStructures() external view returns (uint256[] memory, address[] memory, address[] memory) {
		uint256 length = ths.length;
		TargetHandler memory _th;
		uint256[] memory prop = new uint256[](length);
		address[] memory thAddr = new address[](length);
		address[] memory mmAddr = new address[](length);

		for (uint256 i = 0; i < length; ++i) {
			_th = ths[i];
			prop[i] = _th.aimedPropotion;
			thAddr[i] = _th.targetHandlerAddr;
			mmAddr[i] = _th.targetAddr;
		}
		return (prop, thAddr, mmAddr);
	}

	// owner function
	function setAimedPropotion(uint256[] calldata _thPropotion) external auth returns (bool){
		require(ths.length == _thPropotion.length, "wrong length");
		uint256 sum = 0;
		uint256 i;
		TargetHandler memory _th;
		for(i = 0; i < _thPropotion.length; ++i) {
			sum = add(sum, _thPropotion[i]);
		}
		require(sum == 1000, "the sum of propotion must be 1000");
		for(i = 0; i < _thPropotion.length; ++i) {
			_th = ths[i];
			_th.aimedPropotion = _thPropotion[i];
			ths[i] = _th;
		}
		return true;
	}

	function removeTargetHandler(address _targetHandlerAddr, uint256 _index, uint256[] calldata _thPropotion) external auth returns (bool) {
		uint256 length = ths.length;
		uint256 sum = 0;
		uint256 i;
		TargetHandler memory _th;

		require(length > 1, "can not remove the last target handler");
		require(_index < length, "not the correct index");
		require(ths[_index].targetHandlerAddr == _targetHandlerAddr, "not the correct index or address");
		require(getTHPrinciple(_index) == 0, "must drain all balance in the target handler");
		ths[_index] = ths[length - 1];
		ths.length --;

		require(ths.length == _thPropotion.length, "wrong length");
		for(i = 0; i < _thPropotion.length; ++i) {
			sum = add(sum, _thPropotion[i]);
		}
		require(sum == 1000, "the sum of propotion must be 1000");
		for(i = 0; i < _thPropotion.length; ++i) {
			_th = ths[i];
			_th.aimedPropotion = _thPropotion[i];
			ths[i] = _th;
		}
		return true;
	}

	function addTargetHandler(address _targetHandlerAddr, uint256[] calldata _thPropotion) external auth returns (bool) {
		uint256 length = ths.length;
		uint256 sum = 0;
		uint256 i;
		TargetHandler memory _th;

		for(i = 0; i < length; ++i) {
			_th = ths[i];
			require(_th.targetHandlerAddr != _targetHandlerAddr, "exist target handler");
		}
		ths.push(TargetHandler(_targetHandlerAddr, ITargetHandler(_targetHandlerAddr).getTargetAddress(), 0));

		require(ths.length == _thPropotion.length, "wrong length");
		for(i = 0; i < _thPropotion.length; ++i) {
			sum += _thPropotion[i];
		}
		require(sum == 1000, "the sum of propotion must be 1000");
		for(i = 0; i < _thPropotion.length; ++i) {
			_th = ths[i];
			_th.aimedPropotion = _thPropotion[i];
			ths[i] = _th;
		}
		return true;
	}

	function setReserveUpperLimit(uint256 _number) external auth returns (bool) {
		require(_number >= reserveLowerLimit, "wrong number");
		reserveUpperLimit = _number;
		return true;
	}

	function setReserveLowerLimit(uint256 _number) external auth returns (bool) {
		require(_number <= reserveUpperLimit, "wrong number");
		reserveLowerLimit = _number;
		return true;
	}

	function setExecuteUnit(uint256 _number) external auth returns (bool) {
		executeUnit = _number;
		return true;
	}

	function setProfitBeneficiary(address _profitBeneficiary) external auth returns (bool) {
		profitBeneficiary = _profitBeneficiary;
		return true;
	}
}

interface IDFView {
	    function getCollateralBalance(address _srcToken) external view returns (uint);
}

contract DFDispatcher is Dispatcher{

	address public dfView;

	constructor (address _dfView,
		         address _tokenAddr,
				 address _fundPool,
				 address[] memory _thAddr,
				 uint256[] memory _thPropotion,
				 uint256 _tokenDecimals)
				 Dispatcher(_tokenAddr, _fundPool, _thAddr, _thPropotion, _tokenDecimals) public
	{
		dfView = _dfView;
	}

	// getter function
	function getReserve() public view returns (uint256) {
		return IDFView(dfView).getCollateralBalance(token) - super.getPrinciple();
	}
}