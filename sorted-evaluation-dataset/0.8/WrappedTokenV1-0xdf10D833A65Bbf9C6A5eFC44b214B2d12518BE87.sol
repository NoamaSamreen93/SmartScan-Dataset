// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "./ERC1404.sol";

import "./roles/OwnerRole.sol";

import "./capabilities/Proxiable.sol";

import "./capabilities/Burnable.sol";
import "./capabilities/Mintable.sol";
import "./capabilities/Pausable.sol";
import "./capabilities/Revocable.sol";

import "./capabilities/Blacklistable.sol";
import "./capabilities/Whitelistable.sol";

import "./capabilities/RevocableToAddress.sol";

/// @title Wrapped Token V1 Contract
/// @notice The role based access controls allow the Owner accounts to determine which permissions are granted to admin
/// accounts. Admin accounts can enable, disable, and configure the token restrictions built into the contract.
/// @dev This contract implements the ERC1404 Interface to add transfer restrictions to a standard ERC20 token.
contract WrappedTokenV1 is
    Proxiable,
    ERC20Upgradeable,
    ERC1404,
    OwnerRole,
    Whitelistable,
    Mintable,
    Burnable,
    Revocable,
    Pausable,
    Blacklistable,
    RevocableToAddress
{
    AggregatorV3Interface public reserveFeed;

    // ERC1404 Error codes and messages
    uint8 public constant SUCCESS_CODE = 0;
    uint8 public constant FAILURE_NON_WHITELIST = 1;
    uint8 public constant FAILURE_PAUSED = 2;
    string public constant SUCCESS_MESSAGE = "SUCCESS";
    string public constant FAILURE_NON_WHITELIST_MESSAGE =
        "The transfer was restricted due to white list configuration.";
    string public constant FAILURE_PAUSED_MESSAGE =
        "The transfer was restricted due to the contract being paused.";
    string public constant UNKNOWN_ERROR = "Unknown Error Code";

    /// @notice The from/to account has been explicitly denied the ability to send/receive
    uint8 public constant FAILURE_BLACKLIST = 3;
    string public constant FAILURE_BLACKLIST_MESSAGE =
        "Restricted due to blacklist";

    event OracleAddressUpdated(address newAddress);

    constructor(
        string memory name,
        string memory symbol,
        AggregatorV3Interface resFeed
    ) {
        initialize(msg.sender, name, symbol, 0, resFeed, true, false);
    }

    /// @notice This method can only be called once for a unique contract address
    /// @dev Initialization for the token to set readable details and mint all tokens to the specified owner
    /// @param owner Owner address for the contract
    /// @param name Token name identifier
    /// @param symbol Token symbol identifier
    /// @param initialSupply Amount minted to the owner
    /// @param resFeed oracle contract address
    /// @param whitelistEnabled A boolean flag that enables token transfers to be white listed
    /// @param flashMintEnabled A boolean flag that enables tokens to be flash minted
    function initialize(
        address owner,
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        AggregatorV3Interface resFeed,
        bool whitelistEnabled,
        bool flashMintEnabled
    ) public initializer {
        reserveFeed = resFeed;

        ERC20Upgradeable.__ERC20_init(name, symbol);
        Mintable._mint(msg.sender, owner, initialSupply);
        OwnerRole._addOwner(owner);

        Mintable._setFlashMintEnabled(flashMintEnabled);
        Whitelistable._setWhitelistEnabled(whitelistEnabled);

        Mintable._setFlashMintFeeReceiver(owner);
    }

    /// @dev Public function to update the address of the code contract
    /// @param newAddress new implementation contract address
    function updateCodeAddress(address newAddress) external onlyOwner {
        Proxiable._updateCodeAddress(newAddress);
    }

    /// @dev Public function to update the address of the code oracle, retricted to owner
    /// @param resFeed oracle contract address
    function updateOracleAddress(AggregatorV3Interface resFeed)
        external
        onlyOwner
    {
        reserveFeed = resFeed;

        mint(msg.sender, 0);
        emit OracleAddressUpdated(address(reserveFeed));
    }

    /// @notice If the function returns SUCCESS_CODE (0) then it should be allowed
    /// @dev Public function detects whether a transfer should be restricted and not allowed
    /// @param from The sender of a token transfer
    /// @param to The receiver of a token transfer
    ///
    function detectTransferRestriction(
        address from,
        address to,
        uint256
    ) public view override returns (uint8) {
        // Restrictions are enabled, so verify the whitelist config allows the transfer.
        // Logic defined in Blacklistable parent class
        if (!checkBlacklistAllowed(from, to)) {
            return FAILURE_BLACKLIST;
        }

        // Check the paused status of the contract
        if (Pausable.paused()) {
            return FAILURE_PAUSED;
        }

        // If an owner transferring, then ignore whitelist restrictions
        if (OwnerRole.isOwner(from)) {
            return SUCCESS_CODE;
        }

        // Restrictions are enabled, so verify the whitelist config allows the transfer.
        // Logic defined in Whitelistable parent class
        if (!checkWhitelistAllowed(from, to)) {
            return FAILURE_NON_WHITELIST;
        }

        // If no restrictions were triggered return success
        return SUCCESS_CODE;
    }

    /// @notice It should return enough information for the user to know why it failed.
    /// @dev Public function allows a wallet or other client to get a human readable string to show a user if a transfer
    /// was restricted.
    /// @param restrictionCode The sender of a token transfer
    function messageForTransferRestriction(uint8 restrictionCode)
        public
        pure
        override
        returns (string memory)
    {
        if (restrictionCode == FAILURE_BLACKLIST) {
            return FAILURE_BLACKLIST_MESSAGE;
        }

        if (restrictionCode == SUCCESS_CODE) {
            return SUCCESS_MESSAGE;
        }

        if (restrictionCode == FAILURE_NON_WHITELIST) {
            return FAILURE_NON_WHITELIST_MESSAGE;
        }

        if (restrictionCode == FAILURE_PAUSED) {
            return FAILURE_PAUSED_MESSAGE;
        }

        // An unknown error code was passed in.
        return UNKNOWN_ERROR;
    }

    /// @dev Modifier that evaluates whether a transfer should be allowed or not
    /// @param from The sender of a token transfer
    /// @param to The receiver of a token transfer
    /// @param value Quantity of tokens being exchanged between the sender and receiver
    modifier notRestricted(
        address from,
        address to,
        uint256 value
    ) {
        uint8 restrictionCode = detectTransferRestriction(from, to, value);
        require(
            restrictionCode == SUCCESS_CODE,
            messageForTransferRestriction(restrictionCode)
        );
        _;
    }

    /// @dev Public function that overrides the parent class token transfer function to enforce restrictions
    /// @param to Receiver of the token transfer
    /// @param value Amount of tokens to transfer
    /// @return success Status of the transfer
    function transfer(address to, uint256 value)
        public
        override
        notRestricted(msg.sender, to, value)
        returns (bool success)
    {
        success = ERC20Upgradeable.transfer(to, value);
    }

    /// @dev Public function that overrides the parent class token transferFrom function to enforce restrictions
    /// @param from Sender of the token transfer
    /// @param to Receiver of the token transfer
    /// @param value Amount of tokens to transfer
    /// @return success Status of the transfer
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override notRestricted(from, to, value) returns (bool success) {
        success = ERC20Upgradeable.transferFrom(from, to, value);
    }

    /// @dev Public function to recover all ether sent to this contract to an owner address
    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    /// @dev Public function to recover all tokens sent to this contract to an owner address
    /// @param token ERC20 that has a balance for this contract address
    /// @return success Status of the transfer
    function recover(IERC20Upgradeable token)
        external
        onlyOwner
        returns (bool success)
    {
        success = token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    /// @dev Allow Owners to mint tokens to valid addresses
    /// @param account The account tokens will be added to
    /// @param amount The number of tokens to add to a balance
    function mint(address account, uint256 amount)
        public
        override
        onlyMinter
        returns (bool)
    {
        uint256 total = amount + ERC20Upgradeable.totalSupply();
        (, int256 answer, , , ) = reserveFeed.latestRoundData();

        uint256 decimals = ERC20Upgradeable.decimals();
        uint256 reserveFeedDecimals = reserveFeed.decimals();

        require(decimals >= reserveFeedDecimals, "invalid price feed decimals");

        require(
            (answer > 0) &&
                (uint256(answer) * 10**uint256(decimals - reserveFeedDecimals) >
                    total),
            "reserve must exceed the total supply"
        );

        return Mintable.mint(account, amount);
    }

    /// @dev Overrides the parent hook which is called ahead of `transfer` every time that method is called
    /// @param from Sender of the token transfer
    /// @param amount Amount of token being transferred
    function _beforeTokenTransfer(
        address from,
        address,
        uint256 amount
    ) internal view override {
        if (from != address(0)) {
            return;
        }

        require(
            ERC20FlashMintUpgradeable.maxFlashLoan(address(this)) > amount,
            "mint exceeds max allowed"
        );
    }

    uint256[49] private __gap;
}