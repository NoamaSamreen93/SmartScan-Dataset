// SPDX-License-Identifier: UNLICENSED

// Copyright (c) WildCredit - All rights reserved
// https://twitter.com/WildCredit

pragma solidity 0.8.6;

import "TransferHelper.sol";
import "SafeOwnable.sol";

import "IUniswapV2Router.sol";
import "ILendingPair.sol";

contract LiquidationHelper is SafeOwnable, TransferHelper {

  IUniswapV2Router uniV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

  receive() external payable { }

  function operate(
    address          _pair,
    uint[]  calldata _actions,
    bytes[] calldata _data
  ) external {
    ILendingPair(_pair).operate(_actions, _data);
  }

  function wildCall(bytes calldata _callData) external {
    (
      address fromToken,
      address toToken,
      uint    fromAmount,
      uint    minOutput,
      uint    deadline
    ) = abi.decode(_callData, (address, address, uint, uint, uint));
    uint swapOutput = _swap(fromToken, toToken, fromAmount, minOutput, deadline);

    ILendingPair pair = ILendingPair(msg.sender);
    uint profit = swapOutput - pair.debtOf(toToken, address(this)) - 1;

    _safeTransfer(toToken, tx.origin, profit);
  }

  // Non-issue since this contract should never hold any funds,
  // aside from rounding error dust.
  function approve(
    address _token,
    address _spender,
    uint    _amount
  ) external {
    IERC20(_token).approve(_spender, _amount);
  }

  event LogInt(uint index, uint value);

  function _swap(
    address _fromToken,
    address _toToken,
    uint    _fromAmount,
    uint    _minOutput,
    uint    _deadline
  ) internal returns (uint) {

    if (_fromToken == address(WETH)) {
      WETH.deposit { value: address(this).balance }();
    }

    _approveIfNeeded(_fromToken, address(uniV2Router), _fromAmount);

    address[] memory path = new address[](2);
    path[0] = _fromToken;
    path[1] = _toToken;

    uint[] memory amounts = uniV2Router.swapExactTokensForTokens(
      _fromAmount,
      _minOutput,
      path,
      address(this),
      _deadline
    );

    return amounts[1];
  }

  function _approveIfNeeded(
    address _token,
    address _spender,
    uint    _amount
  ) internal {
    IERC20 token = IERC20(_token);
    uint allowance = token.allowance(msg.sender, _spender);

    if (allowance < _amount) {
      token.approve(_spender, type(uint).max);
    }
  }
}