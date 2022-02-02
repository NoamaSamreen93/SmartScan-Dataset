// SPDX-License-Identifier: MIT
/*
 * TODO: before deploy:
 *  1. Check Checks-Effects-Interaction Pattern. (first checks, then calls to state variables, then external functions
 *  2. Small and modular
 *  3. Check Overflow possibilities
 *  4. Check tx.origin is not used
 *  5. Avoid variable loops
 *  6. avoid calling methods on msg.sender (Reentrancy issues)
 *  7. check result of methods before proceeding (call-stack-depth-errors may not fail, but return false)
 */
pragma solidity ^0.8.9;


import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract OwnableDelegateProxy { }


contract ProxyRegistry {
  mapping(address => OwnableDelegateProxy) public proxies;
}


contract FurryHeadContract is ERC1155Supply, AccessControl, Pausable, PaymentSplitter {

    uint256 public constant furryHeadPrice =         70000000000000000; //0.07 ETH
    uint256 public constant presaleFurryHeadPrice =  35000000000000000; //0.05 ETH
    uint256 public constant MINT_LIMIT = 5;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant WHITELIST_MEMBER_ROLE = keccak256("WHITELIST_MEMBER_ROLE");

    uint public constant NOSALE_STAGE = 0;
    uint public constant PRESALE_STAGE = 1;
    uint public constant SALE_STAGE = 2;

    uint private _stage;
    uint256 private maxMints;
    uint256 currentMint;
    address proxyRegistryAddress;
    address[] private walletKeys;
    mapping(address => uint) private mintsPerWallet;

    constructor(
                address[] memory _payees, /* walletadresses for project-wallet, marketing-wallet, marco-wallet, rndeep-wallet */
                uint256[] memory _shares,
                uint256 _maxMints,
                uint256 _authorMint,
                string memory tokenUri,
                address[] memory _whitelist,
                address _proxyRegistryAddress
    ) ERC1155(tokenUri) PaymentSplitter(_payees, _shares)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _stage = NOSALE_STAGE;
        proxyRegistryAddress = _proxyRegistryAddress;
        currentMint = 0;
        addAddressesToRole(_whitelist, WHITELIST_MEMBER_ROLE);

        maxMints = _maxMints;

        _mintTokens(msg.sender, _authorMint);
    }

    function doRelease(address payable account) public{
        release(account);
    }

    function _mintTokens(address account, uint256 amount) private {
        uint256[] memory amounts = new uint256[](amount);
        uint256[] memory ids = new uint256[](amount);
        uint256 startIdx = currentMint;

        if (mintsPerWallet[account] == 0)
        {
            walletKeys.push(account);
        }

        for (uint256 i=0; i<amount; i++)
        {
            ids[i] = startIdx + i;
            amounts[i] = 1;
        }
        currentMint += amount;
        mintsPerWallet[account] += amount;

        _mintBatch(account, ids, amounts, "0x00");
    }

    function getStage() public view returns (uint){
        return _stage;
    }

    function setStage(uint stage) public onlyRole(ADMIN_ROLE) {
        require((stage == NOSALE_STAGE || stage == PRESALE_STAGE || stage == SALE_STAGE), "Invalid Stage-ID");
        _stage = stage;
    }

    function setURI(string memory newuri) public onlyRole(ADMIN_ROLE) {
        _setURI(newuri);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function pause() public onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    function addAddressesToRole(address[] memory membershipCandidates, bytes32 role) public onlyRole(ADMIN_ROLE) {
        require((
                role == ADMIN_ROLE ||
                role == WHITELIST_MEMBER_ROLE
            ), "Unable To Set Role"); // can only be ADMIN, WHITELIST_MEMBER, MINTER or BURN2GET1.
        for (uint i; i< membershipCandidates.length; i++){
            grantRole(WHITELIST_MEMBER_ROLE, membershipCandidates[i]);
        }
    }

    function removeAddressFromRole(address whitelistMember, bytes32 role) public onlyRole(ADMIN_ROLE) {
        require((!hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || role != ADMIN_ROLE), "Owner Cant Be Removed");
        require((
                role == ADMIN_ROLE ||
                role == WHITELIST_MEMBER_ROLE
            ), "Unable To Set Role"); // can  only be ADMIN, WHITELIST_MEMBER, MINTER or BURN2GET1.
        revokeRole(WHITELIST_MEMBER_ROLE, whitelistMember);
    }

    function mint(address account, uint256 amount)
        public payable
    {
        _checkMintable(account, amount);
        _mintTokens(account, amount);
    }

    function _checkMintable(address receiver, uint256 amount) internal
    {
        require(_stage != NOSALE_STAGE, "No Mint Before Sale");
        bool isWhitelist = hasRole(WHITELIST_MEMBER_ROLE, msg.sender);
        bool isAdmin = hasRole(ADMIN_ROLE, msg.sender);
        if (isAdmin) {
        } else{
            if (_stage == PRESALE_STAGE) {
                require(isWhitelist, "Not Whitelisted");
                require(msg.value >= presaleFurryHeadPrice * amount, "Insufficient Payment");
            } else {
                require(_stage == SALE_STAGE, "Sale Not Open");
                require(msg.value >= furryHeadPrice * amount, "Insufficient Payment");
            }
            require(amount <= MINT_LIMIT && amount > 0, "Must Mint 5 Or Less");
            require(mintsPerWallet[receiver] + amount <= MINT_LIMIT, "Max Mints For Wallet Reached");
        }
        require(currentMint + amount <= maxMints, "Purchase Exceeds Max Supply");
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function getMintsPerWallet() public view returns (string memory)
    {
        string memory outStr = "{";
        for (uint256 i=0; i<walletKeys.length; i++)
        {
            if (i!=0){
                outStr = string(abi.encodePacked(outStr, ","));
            }
            outStr = string(abi.encodePacked(
                outStr, "\"",
                Strings.toHexString(uint256(uint160(walletKeys[i]))),
                "\":", Strings.toString(mintsPerWallet[walletKeys[i]])
            ));
        }
        outStr = string(abi.encodePacked(outStr, "}"));
        return outStr;
    }

    function uri(uint256 _tokenId) override public view returns (string memory)
    {
        return string(
            abi.encodePacked(
                super.uri(_tokenId),
                Strings.toString(_tokenId)
            )
        );
    }

    function isApprovedForAll(
            address _owner,
            address _operator
    ) override public view returns (bool isOperator)
    {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(_owner)) == _operator) {
          return true;
        }
        return ERC1155.isApprovedForAll(_owner, _operator);
    }

}