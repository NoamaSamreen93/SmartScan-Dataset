// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;

import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import "../external/compound/PriceOracle.sol";
import "../external/compound/CErc20.sol";

import "../external/ichi/IICHIVault.sol";

import "./BasePriceOracle.sol";

/**
 * @title ICHIVaultPriceOracle
 * @notice Returns prices for an ICHI Vault LP Token.
 * @dev Implements `PriceOracle` and `BasePriceOracle`.
 */
contract ICHIVaultPriceOracle is PriceOracle, BasePriceOracle {
    using SafeMathUpgradeable for uint256;

    /**
     * @notice Fetches the token/ETH price, with 18 decimals of precision.
     * @param underlying The underlying token address for which to get the price.
     * @return Price denominated in ETH (scaled by 1e18)
     */
    function price(address underlying) external override view returns (uint) {
        return _price(underlying);
    }

    /**
     * @notice Returns the price in ETH of the token underlying `cToken`.
     * @dev Implements the `PriceOracle` interface for Fuse pools (and Compound v2).
     * @return Price in ETH of the token underlying `cToken`, scaled by `10 ** (36 - underlyingDecimals)`.
     */
    function getUnderlyingPrice(CToken cToken) external override view returns (uint) {
        address underlying = CErc20(address(cToken)).underlying();
        // Comptroller needs prices to be scaled by 1e(36 - decimals)
        // Since `_price` returns prices scaled by 18 decimals, we must scale them by 1e(36 - 18 - decimals)
        return _price(underlying).mul(1e18).div(10 ** uint256(ERC20Upgradeable(underlying).decimals()));
    }

    /**
     * @notice Fetches the token/ETH price, with 18 decimals of precision.
     */
    function _price(address token) internal view returns (uint) {
        IICHIVault vault = IICHIVault(token);
        ERC20Upgradeable token0 = ERC20Upgradeable(vault.token0());
        ERC20Upgradeable token1 = ERC20Upgradeable(vault.token1());
        (uint256 amount0, uint256 amount1) = vault.getTotalAmounts();
        uint256 token0EthPrice = BasePriceOracle(msg.sender).price(address(token0));
        uint256 token1EthPrice = BasePriceOracle(msg.sender).price(address(token1));
        return (amount0.mul(token0EthPrice).div(10 ** uint256(token0.decimals())) + 
            amount1.mul(token1EthPrice).div(10 ** uint256(token1.decimals()))).mul(1e18).div(vault.totalSupply());
    }
}