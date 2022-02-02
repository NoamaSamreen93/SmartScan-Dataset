//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";


//     /$$$$$$$  /$$$$$$$$  /$$$$$$        /$$$$$$$   /$$$$$$   /$$$$$$
//    | $$____/ |_____ $$/ /$$__  $$      | $$__  $$ /$$__  $$ /$$__  $$
//    | $$           /$$/ | $$  \__/      | $$  \ $$| $$  \ $$| $$  \ $$
//    | $$$$$$$     /$$/  | $$$$$$$       | $$  | $$| $$$$$$$$| $$  | $$
//    |_____  $$   /$$/   | $$__  $$      | $$  | $$| $$__  $$| $$  | $$
//     /$$  \ $$  /$$/    | $$  \ $$      | $$  | $$| $$  | $$| $$  | $$
//    |  $$$$$$/ /$$/     |  $$$$$$/      | $$$$$$$/| $$  | $$|  $$$$$$/
//     \______/ |__/       \______/       |_______/ |__/  |__/ \______/
//
//    576DAO.com
//    Jan 2022


contract Dao576Token is Ownable, ERC20Permit, ERC20Votes {
    bool public saleActive;
    bool public teamClaimed;
    uint16 public constant TOKENS_PER_ETH = 1000;
    uint256 public constant MAX_SUPPLY = 12500000;

    mapping(address => uint256) public whitelist;

    constructor() ERC20("576DAO", "$576") ERC20Permit("Dao576Token") {}

    function toggleActive() external onlyOwner {
        saleActive = !saleActive;
    }

    function setWhitelist(address[] calldata accounts, uint256[] calldata amount) external onlyOwner {
        require(accounts.length == amount.length, "Data mismatch.");
        for (uint256 i = 0; i < accounts.length; i++) {
            whitelist[accounts[i]] = amount[i];
        }
    }

    function mint(uint256 amount) external payable {
        require(saleActive, "Sale is not active.");
        require(whitelist[msg.sender] >= amount, "Exceed whitelist tokens.");
        require(amount >= 1000, "Minimum purchase is 1000.");
        require(amount * (1 ether / TOKENS_PER_ETH) <= msg.value, "Ether value is incorrect.");
        require(totalSupply() + amount <= (MAX_SUPPLY * 60 / 100), "Tokens are sold out.");

        whitelist[msg.sender] -= amount;

        _mint(msg.sender, amount);
    }

    function teamClaim() external onlyOwner {
        require(!teamClaimed, "Can not claim, that many.");
        uint256 amount = MAX_SUPPLY * 40 / 100;
        _mint(msg.sender, amount);
        teamClaimed = true;
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }
}