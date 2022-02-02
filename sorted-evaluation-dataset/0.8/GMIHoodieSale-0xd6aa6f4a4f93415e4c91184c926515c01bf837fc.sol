// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import '@openzeppelin/contracts/access/AccessControl.sol';

contract GMIHoodieSale is AccessControl {
  bytes32 public constant IYK_MANAGER_ROLE = keccak256('IYK_MANAGER_ROLE');
  bytes32 public constant INDEXCOOP_MINTER_ROLE = keccak256('INDEXCOOP_MINTER_ROLE');

  enum Size {
    XS,
    S,
    M,
    L,
    XL,
    XXL
  }

  mapping(Size => uint256) public soldAmount; // amount of each size sold already
  mapping(Size => uint256) public maxAmount; // max amount for each size

  // Sale parameters
  uint256 public price;
  bool public isSaleActive;
  uint256 public remainingFreeClaims;

  event Purchase(address recipient, Size size, uint256 quantity);

  constructor(
    uint256 _price,
    uint256 indexInitialClaims,
    uint256[] memory inventory
  ) {
    isSaleActive = false;
    price = _price;
    remainingFreeClaims = indexInitialClaims;

    maxAmount[Size.XS] = inventory[0];
    maxAmount[Size.S] = inventory[1];
    maxAmount[Size.M] = inventory[2];
    maxAmount[Size.L] = inventory[3];
    maxAmount[Size.XL] = inventory[4];
    maxAmount[Size.XXL] = inventory[5];

    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(IYK_MANAGER_ROLE, msg.sender);
  }

  // Public functions
  function buy(uint256 quantity, Size size) public payable {
    require(isSaleActive, 'Sale is not active');
    require(soldAmount[size] + quantity <= maxAmount[size], 'Not enough quantity left of selected size');
    require(msg.value == price * quantity, 'Incorrect amount of ether sent');

    soldAmount[size] += quantity;

    emit Purchase(msg.sender, size, quantity);
  }

  // Indexcoop Minter Functions
  function mintBatch(uint256[] memory quantities) public onlyRole(INDEXCOOP_MINTER_ROLE) {
    require(quantities.length == 6, 'Quantities must list all items.');
    for (uint256 i = 0; i < 6; ++i) {
      if (quantities[i] > 0) {
        require(soldAmount[Size(i)] + quantities[i] < maxAmount[Size(i)], 'Not enough quantity left of selected size');
        require(remainingFreeClaims >= quantities[i], 'Not enough remaining free claims to cover mint');

        remainingFreeClaims -= quantities[i];
        soldAmount[Size(i)] += quantities[i];

        emit Purchase(msg.sender, Size(i), quantities[i]);
      }
    }
  }

  // IYK Management Functions
  function flipSaleState() external onlyRole(IYK_MANAGER_ROLE) {
    isSaleActive = !isSaleActive;
  }

  function setSalePrice(uint256 _price) external onlyRole(IYK_MANAGER_ROLE) {
    price = _price;
  }

  function updateInventoryForSize(Size size, uint256 quantity) external onlyRole(IYK_MANAGER_ROLE) {
    require(soldAmount[size] <= quantity, 'Quantity is less than already sold amount');
    maxAmount[size] = quantity;
  }

  function increaseFreeClaims(uint256 additionalFreeClaims) external onlyRole(IYK_MANAGER_ROLE) {
    remainingFreeClaims += additionalFreeClaims;
  }

  function withdraw() external onlyRole(IYK_MANAGER_ROLE) {
    uint256 balance = address(this).balance;
    payable(msg.sender).transfer(balance);
  }

  // Views
  function getBalance() public view returns (uint256) {
    return address(this).balance;
  }

  function getRemainingStock(Size size) public view returns (uint256) {
    return maxAmount[size] - soldAmount[size];
  }

  // Fallback Functions
  receive() external payable {
    require(false, 'Purchases must be made via the buy function');
  }
}