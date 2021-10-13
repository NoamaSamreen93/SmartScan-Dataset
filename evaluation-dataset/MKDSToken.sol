/*
 * MKDS Token Smart Contract.
 * Copyright (c) 2020 by owner.
 */
pragma solidity ^0.4.20;

//import "../STASIS-EURS-token-smart-contract/src/sol/EURSToken.sol";
import "./SafeMath.sol";
import "./Token.sol";

/**
 * MKDS Token Smart Contract: EIP-20 compatible token smart contract that
 * manages MKDS tokens.
 */
contract MKDSToken is Token, SafeMath {
  string constant public contact = "cryp10grapher@protonmail.com";
  Token constant targetToken = Token(address(0xdB25f211AB05b1c97D595516F45794528a807ad8));
  address public owner;
  address public oracle;
  address public beneficiary;
  uint256 conversionRateNumerator = 6160000; // MKDS/EURS
  uint256 constant denominator = 100000;
  uint256 transferFeeMin = 100; // transfer fee minimum in 1/100's of a MKDS, since MKDS token has 2 decimals
  uint256 transferFeeMax = 100; // transfer fee maximum in 1/100's of a MKDS, since MKDS token has 2 decimals
  uint256 transferFeeFactorNumerator = 100; // transfer fee factor; (initialized for 0.1%); actual factor is obtained by dividing this by denominator

  /**
   * Create MKDS Token smart contract with message sender as an owner. 
   */
  function MKDSToken() public {
    owner = msg.sender;
    oracle = owner;
    beneficiary = owner;
  }

  /**
   * Make sure the modified function can be executed only by the owner.
   */
   modifier onlyOwner() {
    require(0 != owner);
    require(msg.sender == owner);
    _;
  }

  /**
   * Make sure the modified function can be executed only by the oracle.
   */
   modifier onlyOracle() {
    require(0 != oracle);
    require(msg.sender == oracle);
    _;
  }

  /**
   * Transfer ownership of this smart contract to a new address.
   *
   * @param _owner address of the new owner. If set to 0, the owner loses control of the contract.
   */
  function setOwner(address _owner) external onlyOwner() {
    owner = _owner; // If set to 0, owner loses control of the contract
  }

  /**
   * Set new oracle.
   *
   * @param _oracle address of the new oracle. If set to 0, there can be no oracle.
   */
  function setOracle(address _oracle) external onlyOwner() {
    oracle = _oracle; // If set to 0, there is no oracle
  }

  /**
   * Set new beneficiary.
   *
   * @param _beneficiary address of the new beneficiary.
   */
  function setBeneficiary(address _beneficiary) external onlyOwner() {
    beneficiary = _beneficiary; // If set to 0, there is no oracle
  }

  /**
   * Set a new conversion rate for MKDS/EURS. 
   *
   * @param _conversionRateNumerator the new conversion rate multiplied by the denominator.
   */
  function setConversionRateNumerator(uint256 _conversionRateNumerator) external onlyOracle() {
    conversionRateNumerator = _conversionRateNumerator;
  }

  /**
   * Convert from EURS to MKDS.
   *
   * @param value amount of EURS
   * @return countervalue in MKDS
   */
  function toMKDS(uint256 value) public view returns(uint256) {
    return safeMul(value, conversionRateNumerator) / denominator; // round down to make sure it's spendable
  }

  /**
   * Convert from MKDS to EURS.
   *
   * @param value amount of MKDS
   * @return countervalue in EURS
   */
  function toEURS(uint256 value) public view returns(uint256) {
    uint256 v = safeMul(value, denominator);
    uint256 r = v/conversionRateNumerator;
    if (v%conversionRateNumerator > uint256(0)) return safeAdd(r, uint256(1)); // round up to cover the value in EURS
    else return r;
  }

  /**
   * Set new transfer fee parameters.
   * 
   * @param _transferFeeMin // new transfer fee minimum in 1/100's of a MKDS, since MKDS token has 2 decimals
   * @param _transferFeeMax // new transfer fee maximum in 1/100's of a MKDS, since MKDS token has 2 decimals
   * @param _transferFeeFactorNumerator // new transfer fee factor numerator - actual factor is derived by dividing this by denominator
   */
  function setTranactionFeeParameters(
    uint256 _transferFeeMin, 
    uint256 _transferFeeMax, 
    uint256 _transferFeeFactorNumerator) external onlyOwner() {
    transferFeeMin = _transferFeeMin;
    transferFeeMax = _transferFeeMax;
    transferFeeFactorNumerator = _transferFeeFactorNumerator;
  }

  /** Calculates the transaction fee for transfers.
   *
   * @param value the transfer amount
   * @return fee in MKDS
   */
  function transferFee(uint256 value) public view returns(uint256) {
    uint256 fee = safeMul(value, transferFeeFactorNumerator) / denominator; // round down
    if (fee < transferFeeMin) return transferFeeMin;
    else if (fee > transferFeeMax) return transferFeeMax;
    else return fee;
  }

  /**
   * Delegate unrecognized functions.
   */
  function() public payable {
    // address(targetToken).transfer(msg.value); // assuming that the fallback function has no other functionality in EURS but to receive ETH
    address(targetToken).call.value(msg.value)(msg.data);
  }

  /**
   * Get name of the token.
   *
   * @return name of the token
   */
  function name() public pure returns (string) {
    return "MKDS Token - Стабилизиран Со Македонски Денар";
  }

  /**
   * Get symbol of the token.
   *
   * @return symbol of the token
   */
  function symbol() public pure returns (string) {
    return "MKDS";
  }

  /**
   * Get number of decimals for the token.
   *
   * @return number of decimals for the token
   */
  function decimals() public pure returns (uint8) {
    return 2;
  }

  /**
   * Get total number of tokens in circulation.
   *
   * @return total number of tokens in circulation
   */
  function totalSupply() public view returns (uint256) {
    return toMKDS(targetToken.totalSupply());
  }

  /**
   * Get number of tokens currently belonging to given owner.
   *
   * @param _owner address to get number of tokens currently belonging to the
   *        owner of
   * @return number of tokens currently belonging to the owner of given address
   */
  function balanceOf(address _owner)
    public view returns (uint256 balance) {
    return toMKDS(targetToken.balanceOf(_owner));
  }

  /**
   * Transfer given number of tokens from message sender to given recipient.
   * @dev Permissioning is delegated to the targetToken.
   *
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer to the owner of given address
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transfer(address _to, uint256 _value)
  public payable returns (bool) {
    uint256 fee = transferFee(_value);
    // return targetToken.transfer.value(msg.value)(_to, toEURS(safeSub(_value, fee)); // does not work - Solidity issue. Thus following line
    // With ETH: require(address(targetToken).call.value(msg.value)(abi.encodeWithSignature("transfer(address,uint256)", _to, toEURS(safeSub(_value, fee)))));
    require(targetToken.transfer(_to, toEURS(safeSub(_value, fee))));
    require(targetToken.transfer(beneficiary, toEURS(fee))); // Fee charged in EURS only @todo improve to allow ETH fee payments
    //emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
   * Transfer given number of tokens from given owner to given recipient.
   * @dev Permissioning is delegated to the targetToken.
   *
   * @param _from address to transfer tokens from the owner of
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer from given owner to given
   *        recipient
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transferFrom(address _from, address _to, uint256 _value)
  public payable returns (bool) {
    uint256 fee = transferFee(_value);
    require(targetToken.transferFrom.value(msg.value)(_from, _to, toEURS(safeSub(_value, fee))));
    require(targetToken.transferFrom(_from, beneficiary, toEURS(fee))); // Fee charged in EURS only @todo improve to allow ETH fee payments
    //emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * Allow given spender to transfer given number of tokens from message sender.
   * @dev Permissioning is delegated to the targetToken.
   *
   * @param _spender address to allow the owner of to transfer tokens from
   *        message sender
   * @param _value number of tokens to allow to transfer
   * @return true if token transfer was successfully approved, false otherwise
   */
  function approve (address _spender, uint256 _value)
  public payable returns (bool success) {
    if (targetToken.approve.value(msg.value)(_spender, toEURS(_value))) {
      //emit Approval(msg.sender, _spender, _value);
      return true;
    } else return false;
  }

  /**
   * Tell how many tokens given spender is currently allowed to transfer from
   * given owner.
   *
   * @param _owner address to get number of tokens allowed to be transferred
   *        from the owner of
   * @param _spender address to get number of tokens allowed to be transferred
   *        by the owner of
   * @return number of tokens given spender is currently allowed to transfer
   *         from given owner
   */
  function allowance (address _owner, address _spender)
  public view returns (uint256 remaining) {
    return toMKDS(targetToken.allowance(_owner, _spender));
  }
}
