// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../interfaces/tokens/IERC20Internal.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";

import "../interfaces/helpers/IPriceFeed.sol";
import "../interfaces/helpers/IUniswapV2Factory.sol";

import "../interfaces/helpers/IUniswapV2Pair.sol";

contract PriceFeed is IPriceFeed, OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;

    IUniswapV2Router02 public uniswapRouter;
    IUniswapV2Factory public uniswapFactory;
    address public override wethToken;

    function __PriceFeed_init(
        address _uniswapRouter,
        address _uniswapFactory,
        address _weth
    ) external initializer {
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        uniswapFactory = IUniswapV2Factory(_uniswapFactory);
        wethToken = _weth;
    }

    function howManyTokensAinB(
        address tokenA,
        address tokenB,
        address via,
        uint256 amount
    ) external view override returns (uint256) {
        if (amount < 10 * 10**6) {
            //10 mWei
            return 0;
        }

        address[] memory pairs = new address[](3);
        pairs[0] = tokenB;
        if (via == address(0)) {
            pairs[1] = wethToken;
        } else {
            pairs[1] = via;
        }
        pairs[2] = tokenA;

        uint256[] memory amounts = uniswapRouter.getAmountsOut(amount, pairs);

        return amounts[amounts.length - 1];
    }

    function getUniswapRouter() external view override returns (address) {
        return address(uniswapRouter);
    }
}