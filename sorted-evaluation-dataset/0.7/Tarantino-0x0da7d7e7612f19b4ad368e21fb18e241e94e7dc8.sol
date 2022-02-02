// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Tarantino is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    uint256 public saleTime = 12 hours;
    uint256 public maxSaleTime = 24 hours;
    bool public isOpen = true;

    struct Sale {
        uint256 minPrice;
        uint256 targetPrice;
        uint256 startTime;
        uint256 highestBidAmount;
        uint256 highestBidTime;
        address highestBidAccount;
        bool exists;
    }

    mapping(address => bool) private signers;

    Sale[] public sales;

    event SaleAdded(uint256 minPrice, uint256 targetPrice, uint256 startTime, uint256 saleIndex);
    event SaleUpdated(uint256 minPrice, uint256 targetPrice, uint256 startTime, uint256 saleIndex);
    event SaleExistanceUpdated(uint256 saleIndex, bool exists);
    event BidPlaced(address indexed account, uint256 amount, uint256 time, uint256 saleIndex);

    modifier contractIsOpen() {
        require(isOpen, "Contract is closed");
        _;
    }

    modifier saleExists(uint256 saleIndex) {
        require(sales[saleIndex].exists, "Sale index does not exists");
        _;
    }

    /// @dev Check if caller is a wallet
    modifier isEOA() {
        /* require(!(Address.isContract(msg.sender)) && tx.origin == _msgSender(), "Only EOA"); */
        require(!(Address.isContract(msg.sender)), "No Contracts");
        _;
    }

    /// ADMIN

    /// @dev // add list of addresses that can sign
    /// @param accounts list of addresses
    function addSigners(address[] memory accounts) external onlyOwner {
        for (uint i = 0; i < accounts.length; i++) {
            if (accounts[i] != address(0)) {
                signers[accounts[i]] = true;
            }
        }
    }

    /// @dev // remove address that can sign
    /// @param account address to remove from signers
    function removeSigner(address account) external onlyOwner {
        signers[account] = false;
    }

    /// @dev add new sale to sales array
    /// @param minPrice minimum price for the sale
    /// @param targetPrice price to start 30 min countdown
    /// @param startTime time to start the sale
    function addSale(uint256 minPrice, uint256 targetPrice, uint256 startTime) external onlyOwner {
        sales.push(Sale(
            minPrice,
            targetPrice,
            startTime,
            0,
            0,
            address(0),
            true
        ));
        emit SaleAdded(minPrice, targetPrice, startTime, sales.length - 1);
    }

    /// @dev edit sale
    /// @param saleIndex sale index
    /// @param minPrice minimum price for the sale
    /// @param targetPrice price to start 30 min countdown
    /// @param startTime time to start the sale
    function editSale(uint256 saleIndex, uint256 minPrice, uint256 targetPrice, uint256 startTime)
        external
        saleExists(saleIndex)
        onlyOwner
    {
        sales[saleIndex].minPrice = minPrice;
        sales[saleIndex].targetPrice = targetPrice;
        sales[saleIndex].startTime = startTime;
        
        emit SaleUpdated(minPrice, targetPrice, startTime, saleIndex);
    }

    /// @dev toggle sale existance
    /// @param saleIndex sale index
    function toggleSaleExistance(uint256 saleIndex)
        external
        onlyOwner
    {
        sales[saleIndex].exists = !sales[saleIndex].exists;
        
        emit SaleExistanceUpdated(saleIndex, sales[saleIndex].exists);
    }

    /// @dev toggle contract validity
    function toggleIsOpen() external onlyOwner {
        isOpen = !isOpen;
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    /// VIEWS

    /// @dev get the status of the sale
    /// @return totalTime sale total time
    function saleTotalTime(uint256 saleIndex)
        public
        view
        contractIsOpen
        saleExists(saleIndex)
        returns(uint256 totalTime)
    {
        Sale memory sale = sales[saleIndex];
        uint256 saleFinishTime = sale.startTime.add(saleTime);
        
        // bid is higher than target price + 30 min
        // highest bid after 12 hours - already extended + 30 min
        if (sale.highestBidAmount >= sale.targetPrice || sale.highestBidTime > saleFinishTime) {
            saleFinishTime = sale.highestBidTime.add(30 minutes);
        }
        // highest bid on last 30 min + 30 min to original time
        else if (saleFinishTime.sub(sale.highestBidTime) < 30 minutes) {
            saleFinishTime = saleFinishTime.add(30 minutes);
        }

        uint256 _saleTotalTime = saleFinishTime.sub(sale.startTime);

        // up to 24 hours sale
        if (_saleTotalTime > maxSaleTime) {
            _saleTotalTime = maxSaleTime;
        }
        return _saleTotalTime;
    }

    /// @dev get the status of the sale
    /// @return active sale is live
    function isSaleLive(uint256 saleIndex)
        public
        view
        contractIsOpen
        saleExists(saleIndex)
        returns(bool active)
    {
        Sale memory sale = sales[saleIndex];
        uint256 _saleTotalTime = saleTotalTime(saleIndex);
        return block.timestamp >= sale.startTime && block.timestamp <= sale.startTime.add(_saleTotalTime);
    }

    /// @dev get the highest bidder of a sale
    /// @return amount
    /// @return time
    /// @return account
    function highestOffer(uint256 saleIndex)
        external
        view
        saleExists(saleIndex)
        returns(uint256 amount, uint256 time, address account)
    {
        Sale memory sale = sales[saleIndex];
        return (sale.highestBidAmount, sale.highestBidTime, sale.highestBidAccount);
    }

    /// @dev get the signature hash of an address
    /// @param account the address to get the hash for
    /// @return bytes32 hash
    function getSignedMessageHash(address account)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n20", account));
    }

    /// @dev check if an address was off chain whitelisted
    /// @param account the address to check
    /// @return isValid boolean
    function isWhitelisted(uint8 v, bytes32 r, bytes32 s, address account) public view returns (bool isValid) {
        bytes32 sigHash = getSignedMessageHash(account);
        address _signer = ecrecover(sigHash, v, r, s);
        return signers[_signer];
    }

    /// ACTIONS

    /// @dev place new bid
    /// @param saleIndex the index of the current sale
    function bid(uint256 saleIndex, uint8 v, bytes32 r, bytes32 s)
        external
        payable
        isEOA
        nonReentrant
        contractIsOpen
        saleExists(saleIndex)
    {
        require(isSaleLive(saleIndex), "Sale is not live");
        require(isWhitelisted(v, r, s, msg.sender), "Address is not whitelisted");
        Sale memory sale = sales[saleIndex];
        require(msg.value >= sale.minPrice, "Bid must be higher than min price");
        require(msg.value > sale.highestBidAmount, "Bid must be higher than current highest offer");
        require(msg.sender != sale.highestBidAccount, "Your are already the highest bidder");
        // current highest bid
        uint256 currentHighestBidAmount = sale.highestBidAmount;
        address currentHighestBidAccount = sale.highestBidAccount;
        // update highest bid info
        sales[saleIndex].highestBidAmount = msg.value;
        sales[saleIndex].highestBidTime = block.timestamp;
        sales[saleIndex].highestBidAccount = msg.sender;
        // returns previous bidder money
        if (currentHighestBidAccount != address(0)) {
            payable(currentHighestBidAccount).transfer(currentHighestBidAmount);
        }
        emit BidPlaced(msg.sender, msg.value, block.timestamp, saleIndex);
    }
    
}