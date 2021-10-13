/**
 *Submitted for verification at Etherscan.io on 2020-03-01
*/

pragma solidity 0.4.26;


contract DSMath {
    
    /*
    standard uint256 functions
     */

    function add(uint256 x, uint256 y) pure internal returns (uint256 z) {
        assert((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) pure internal returns (uint256 z) {
        assert((z = x - y) <= x);
    }

    function mul(uint256 x, uint256 y) pure internal returns (uint256 z) {
        assert((z = x * y) >= x);
    }
    
    function div(uint256 x, uint256 y) pure internal returns (uint256 z) {
        require(y > 0);
        z = x / y;
    }
    
    function min(uint256 x, uint256 y) pure internal returns (uint256 z) {
        return x <= y ? x : y;
    }
    function max(uint256 x, uint256 y) pure internal returns (uint256 z) {
        return x >= y ? x : y;
    }

    /*
    uint128 functions (h is for half)
     */


    function hadd(uint128 x, uint128 y) pure internal returns (uint128 z) {
        assert((z = x + y) >= x);
    }

    function hsub(uint128 x, uint128 y) pure internal returns (uint128 z) {
        assert((z = x - y) <= x);
    }

    function hmul(uint128 x, uint128 y) pure internal returns (uint128 z) {
        assert((z = x * y) >= x);
    }

    function hdiv(uint128 x, uint128 y) pure internal returns (uint128 z) {
        assert(y > 0);
        z = x / y;
    }

    function hmin(uint128 x, uint128 y) pure internal returns (uint128 z) {
        return x <= y ? x : y;
    }
    function hmax(uint128 x, uint128 y) pure internal returns (uint128 z) {
        return x >= y ? x : y;
    }


    /*
    int256 functions
     */

    function imin(int256 x, int256 y) pure internal returns (int256 z) {
        return x <= y ? x : y;
    }
    function imax(int256 x, int256 y) pure internal returns (int256 z) {
        return x >= y ? x : y;
    }

    /*
    WAD math
     */

    uint128 constant WAD = 10 ** 18;

    function wadd(uint128 x, uint128 y) pure internal returns (uint128) {
        return hadd(x, y);
    }

    function wsub(uint128 x, uint128 y) pure internal returns (uint128) {
        return hsub(x, y);
    }

    function wmul(uint128 x, uint128 y) view internal returns (uint128 z) {
        z = cast((uint256(x) * y + WAD / 2) / WAD);
    }

    function wdiv(uint128 x, uint128 y) view internal returns (uint128 z) {
        z = cast((uint256(x) * WAD + y / 2) / y);
    }

    function wmin(uint128 x, uint128 y) pure internal returns (uint128) {
        return hmin(x, y);
    }
    function wmax(uint128 x, uint128 y) pure internal returns (uint128) {
        return hmax(x, y);
    }

    /*
    RAY math
     */

    uint128 constant RAY = 10 ** 27;

    function radd(uint128 x, uint128 y) pure internal returns (uint128) {
        return hadd(x, y);
    }

    function rsub(uint128 x, uint128 y) pure internal returns (uint128) {
        return hsub(x, y);
    }

    function rmul(uint128 x, uint128 y) view internal returns (uint128 z) {
        z = cast((uint256(x) * y + RAY / 2) / RAY);
    }

    function rdiv(uint128 x, uint128 y) view internal returns (uint128 z) {
        z = cast((uint256(x) * RAY + y / 2) / y);
    }

    function rpow(uint128 x, uint64 n) view internal returns (uint128 z) {
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

        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }

    function rmin(uint128 x, uint128 y) pure internal returns (uint128) {
        return hmin(x, y);
    }
    function rmax(uint128 x, uint128 y) pure internal returns (uint128) {
        return hmax(x, y);
    }

    function cast(uint256 x) pure internal returns (uint128 z) {
        assert((z = uint128(x)) == x);
    }

}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract WETH is ERC20 {
    function deposit() public payable;
    function withdraw(uint wad) public;
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);
}

interface UniswapExchangeInterface {
    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);
}

interface OracleInterface {
  function bill() external view returns (uint256);
  function update(uint128 payment_, address token_) external;
}

interface MedianizerInterface {
    function oracles(uint256) public view returns (address);
    function peek() public view returns (bytes32, bool);
    function read() public returns (bytes32);
    function poke() public;
    function poke(bytes32) public;
    function fund (uint256 amount, ERC20 token) public;
}

contract FundOracles is DSMath {
  ERC20 link;
  WETH weth;
  UniswapExchangeInterface uniswapExchange;

  MedianizerInterface med;

  /**
    * @notice Construct a new Fund Oracles contract
    * @param med_ The address of the Medianizer
    * @param link_ The LINK token address
    * @param weth_ The WETH token address
    * @param uniswapExchange_ The address of the LINK to ETH Uniswap Exchange
    */
  constructor(MedianizerInterface med_, ERC20 link_, WETH weth_, UniswapExchangeInterface uniswapExchange_) public {
    med = med_;
    link = link_;
    weth = weth_;
    uniswapExchange = uniswapExchange_;
  }

  /**
    * @notice Determines the last oracle token payment
    * @param oracle_ Index of oracle
    * @return Last payment to oracle in token (LINK for Chainlink, WETH for Oraclize)
    */
  function billWithEth(uint256 oracle_) public view returns (uint256) {
      return OracleInterface(med.oracles(oracle_)).bill();
  }

  /**
    * @notice Determines the payment amount in ETH
    * @param oracle_ Index of oracle
    * @param payment_ Payment amount in tokens (LINK or WETH)
    * @return Amount of ETH to pay in updateWithEth to update Oracle
    */
  function paymentWithEth(uint256 oracle_, uint128 payment_) public view returns(uint256) {
      if (oracle_ < 5) {
          return uniswapExchange.getEthToTokenOutputPrice(payment_);
      } else {
          return uint(payment_);
      }
  }

  /**
    * @notice Update the Oracle using ETH
    * @param oracle_ Index of oracle
    * @param payment_ Payment amount in tokens (LINK or WETH)
    * @param token_ Address of token to receive as a reward for updating Oracle
    */
  function updateWithEth(uint256 oracle_, uint128 payment_, address token_) public payable {
    address oracleAddress = med.oracles(oracle_);
    OracleInterface oracle = OracleInterface(oracleAddress);
    if (oracle_ < 5) {
      // ChainLink Oracle
      link.approve(address(uniswapExchange), uint(payment_));
      uniswapExchange.ethToTokenSwapOutput.value(msg.value)(uint(payment_), now + 300);
      link.approve(oracleAddress, uint(payment_));
      oracle.update(payment_, token_);
    } else {
      // Oraclize Oracle
      weth.deposit.value(msg.value)();
      weth.approve(oracleAddress, uint(payment_));
      oracle.update(payment_, token_);
    }
  }
}