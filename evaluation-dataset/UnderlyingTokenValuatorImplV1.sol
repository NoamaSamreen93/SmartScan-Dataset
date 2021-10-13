/**
 *Submitted for verification at Etherscan.io on 2020-02-29
*/

// File: contracts/interfaces/IUnderlyingTokenValuator.sol

pragma solidity ^0.5.0;

interface IUnderlyingTokenValuator {

    /**
      * @dev Gets the tokens value in terms of USD.
      *
      * @return The value of the `amount` of `token`, as a number with 18 decimals
      */
    function getTokenValue(address token, uint amount) external view returns (uint);

}

// File: contracts/libs/StringHelpers.sol

pragma solidity ^0.5.0;

library StringHelpers {

    function toString(address _address) public pure returns (string memory) {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++) {
            b[i] = byte(uint8(uint(_address) / (2 ** (8 * (19 - i)))));
        }
        return string(b);
    }

}

// File: contracts/impl/UnderlyingTokenValuatorImplV1.sol

pragma solidity ^0.5.0;



contract UnderlyingTokenValuatorImplV1 is IUnderlyingTokenValuator {

    using StringHelpers for address;

    address public dai;
    address public usdc;

    constructor(
        address _dai,
        address _usdc
    ) public {
        dai = _dai;
        usdc = _usdc;
    }

    // For right now, we use stable-coins, which we assume are worth $1.00
    function getTokenValue(address token, uint amount) public view returns (uint) {
        if (token == usdc) {
            return amount;
        } else if (token == dai) {
            return amount;
        } else {
            revert(string(abi.encodePacked("Invalid token, found: ", token.toString())));
        }
    }

}