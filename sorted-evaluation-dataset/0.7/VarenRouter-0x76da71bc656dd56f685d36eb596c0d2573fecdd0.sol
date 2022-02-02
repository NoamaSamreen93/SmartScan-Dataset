// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IGatewayRegistry.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract VarenRouter is ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public constant ETH_REPRESENTING_ADDRESS = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    uint256 public FEE = 50;
    uint256 public constant PERCENTAGE_DIVIDER = 100_000;

    IGatewayRegistry public registry;
    address public router;
    address payable public devWallet;

    // Swap info to avoid the stack too deep error
    struct SwapVars {
        address srcToken;
        uint256 srcAmount;
        address destToken;
        bytes data;
    }

    // Memory variables
    struct Vars {
        uint256 mintedAmount;
        uint256 swappedAmount;
    }

    struct BurnVars {
        uint256 burnAmount;
        address burnToken;
        bytes burnSendTo;
        bool shouldTakeFee;
    }

    // Events
    event Mint(address indexed sender, uint256 amount);
    event Burn(address indexed sender, uint256 amount);
    event Swap(address indexed sender, address indexed from, address indexed to, uint256 amount);

    constructor(
        address _router,
        address _registry,
        address payable _devWallet
    ) {
        router = _router;
        registry = IGatewayRegistry(_registry);
        devWallet = _devWallet;
    }

    function swap(
        //// protected
        address sender,
        //// unprotected
        // Mint
        address mintToken,
        // Burn
        address burnToken,
        uint256 burnAmount,
        bytes calldata burnSendTo,
        //// 1inch
        SwapVars calldata swapVars,
        //// renvm for minting
        uint256 _amount,
        bytes32 _nHash,
        bytes calldata _sig
    ) external payable nonReentrant {
        require(msg.sender == sender, "The caller is unknown");
        require(burnToken != mintToken || mintToken == address(0), "Cannot mint and burn the same token");

        // To prevent the stack too deep error
        Vars memory vars;

        if (mintToken != address(0)) {
            vars.mintedAmount = mintRenToken(mintToken, sender, _amount, _nHash, _sig);
        }

        if (swapVars.data.length > 0) {
            vars.swappedAmount = _swap(mintToken, swapVars, vars.mintedAmount);
        }

        if (burnToken == address(0)) {
            transferTokenOrETH(vars.swappedAmount, swapVars, vars.mintedAmount, mintToken);
        } else {
            burnRenToken(vars.swappedAmount, BurnVars(burnAmount, burnToken, burnSendTo, mintToken == address(0)));
        }
    }

    function mintRenToken(
        address mintToken,
        address sender,
        uint256 _amount,
        bytes32 _nHash,
        bytes calldata _sig
    ) private returns (uint256 mintedAmount) {
        // Minting ren token
        uint256 currentMintTokenBalance = currentBalance(mintToken);
        bytes32 pHash = keccak256(abi.encode(sender));
        registry.getGatewayByToken(mintToken).mint(pHash, _amount, _nHash, _sig);
        mintedAmount = currentBalance(mintToken) - currentMintTokenBalance;
        uint256 fee = (mintedAmount * FEE) / PERCENTAGE_DIVIDER;
        mintedAmount = mintedAmount - fee;
        IERC20(mintToken).transfer(devWallet, fee);
        emit Mint(sender, mintedAmount);
    }

    function _swap(
        address mintToken,
        SwapVars memory swapVars,
        uint256 mintedAmount
    ) private returns (uint256 swappedAmount) {
        if (mintToken == address(0)) {
            // The token that need to be swapped is not on the contract right now
            // We either need to use ETH or we need to transfer the token to the contract
            if (swapVars.srcToken != ETH_REPRESENTING_ADDRESS) {
                // The source is ERC20 token, need to transfer it to the contract
                // Assuming UI already asked the user to approve the token
                IERC20(swapVars.srcToken).safeTransferFrom(msg.sender, address(this), swapVars.srcAmount);
            }
        }
        // else token is in the contract because of the minting process or the user sent ETH

        // Saving ref to current balance of destination token to know how much was swapped
        uint256 currentDestTokenBalance = swapVars.destToken != ETH_REPRESENTING_ADDRESS
            ? currentBalance(swapVars.destToken)
            : address(this).balance;

        // Executing the swap
        if (swapVars.srcToken != ETH_REPRESENTING_ADDRESS) {
            // Approving token only if needed for gas efficiency
            if (IERC20(swapVars.srcToken).allowance(address(this), router) < swapVars.srcAmount) {
                IERC20(swapVars.srcToken).approve(router, type(uint256).max);
            }
            // Swapping
            Address.functionCall(router, swapVars.data);
        } else {
            // Sending ETH
            Address.functionCallWithValue(router, swapVars.data, msg.value);
        }

        // How much was swapped
        swappedAmount = swapVars.destToken != ETH_REPRESENTING_ADDRESS
            ? currentBalance(swapVars.destToken) - currentDestTokenBalance
            : address(this).balance - currentDestTokenBalance;

        if (mintedAmount > swapVars.srcAmount) {
            // Some dust may have remain, or the user sent too much funds to the external chain but decided to mint only half
            IERC20(swapVars.srcToken).safeTransfer(address(this), mintedAmount - swapVars.srcAmount);
        }
        emit Swap(msg.sender, swapVars.srcToken, swapVars.destToken, swappedAmount);
    }

    function burnRenToken(uint256 swappedAmount, BurnVars memory burnVars) private {
        // If there was a swap then sending the swapped amount since it is the most accurate number
        // (taking into account, min value, slippage and such)
        // If there wasn't a swap, then using the burnAmount
        // No need to check minted amount since can't mint and burn the same token
        uint256 amountToBurn = swappedAmount > 0 ? swappedAmount : burnVars.burnAmount;
        if (burnVars.shouldTakeFee) {
            // No mint, taking fee
            uint256 fee = (amountToBurn * FEE) / PERCENTAGE_DIVIDER;
            amountToBurn = amountToBurn - fee;
            IERC20(burnVars.burnToken).transfer(devWallet, fee);
        }
        registry.getGatewayByToken(burnVars.burnToken).burn(burnVars.burnSendTo, amountToBurn);
        emit Burn(msg.sender, amountToBurn);
    }

    function transferTokenOrETH(
        uint256 swappedAmount,
        SwapVars memory swapVars,
        uint256 mintedAmount,
        address mintToken
    ) private {
        if (swappedAmount > 0) {
            // There was a swap
            if (swapVars.destToken != ETH_REPRESENTING_ADDRESS) {
                // Transfer the destination token to the user
                IERC20(swapVars.destToken).safeTransfer(msg.sender, swappedAmount);
            } else {
                // Transfer the ETH to the user
                safeTransferETH(msg.sender, swappedAmount);
            }
        } else if (mintedAmount > 0) {
            // Transfer the minted token to the user
            IERC20(mintToken).safeTransfer(msg.sender, mintedAmount);
        }
    }

    function safeTransferETH(address to, uint256 value) private {
        payable(to).transfer(value);
    }

    function currentBalance(address _token) public view returns (uint256 balance) {
        balance = IERC20(_token).balanceOf(address(this));
    }

    receive() external payable {}
}