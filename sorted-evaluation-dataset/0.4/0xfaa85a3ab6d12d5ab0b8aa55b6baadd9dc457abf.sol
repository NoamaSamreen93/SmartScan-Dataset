pragma solidity 0.4.25;

// File: contracts/ERC777/ERC777Token.sol

/* This Source Code Form is subject to the terms of the Mozilla external
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * This code has not been reviewed.
 * Do not use or deploy this code before reviewing it personally first.
 */


interface ERC777Token {
  function name() external view returns (string);
  function symbol() external view returns (string);
  function totalSupply() external view returns (uint256);
  function balanceOf(address owner) external view returns (uint256);
  function granularity() external view returns (uint256);

  function defaultOperators() external view returns (address[]);
  function isOperatorFor(address operator, address tokenHolder) external view returns (bool);
  function authorizeOperator(address operator) external;
  function revokeOperator(address operator) external;

  function send(address to, uint256 amount, bytes holderData) external;
  function operatorSend(address from, address to, uint256 amount, bytes holderData, bytes operatorData) external;

  function burn(uint256 amount, bytes holderData) external;
  function operatorBurn(address from, uint256 amount, bytes holderData, bytes operatorData) external;

  event Sent(
    address indexed operator,
    address indexed from,
    address indexed to,
    uint256 amount,
    bytes holderData,
    bytes operatorData
  );
  event Minted(address indexed operator, address indexed to, uint256 amount, bytes operatorData);
  event Burned(address indexed operator, address indexed from, uint256 amount, bytes holderData, bytes operatorData);
  event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
  event RevokedOperator(address indexed operator, address indexed tokenHolder);
}

// File: contracts/operators/DelegatedTransferOperatorV5GasOptimized.sol

/// @title DelegatedTransferOperatorV5GasOptimized
/// @author Roger Wu (Roger-Wu)
/// @dev A DelegatedTransferOperator contract that has the following features:
///   1. To prevent replay attack, we check if a _nonce has been used by a token holder.
///   2. Minimize the gas by making functions inline and remove trivial event.
///   3. Add `_userData`.
///   4. Add function `batchTransferPreSigned` which does multiple delegated Transfers in one transaction.
///   5. Support signature with "\x19Ethereum Signed Message:\n32" prefix
contract DelegatedTransferOperatorV5GasOptimized {
  mapping(address => uint256) public usedNonce;
  ERC777Token tokenContract = ERC777Token(0x67ab11058eF23D0a19178f61A050D3c38F81Ae21);

  /**
    * @notice Submit a presigned transfer
    * @param _to address The address which you want to transfer to.
    * @param _delegate address The address which is allowed to send this transaction.
    * @param _value uint256 The amount of tokens to be transferred.
    * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
    * @param _nonce uint256 Presigned transaction number.
    * @param _userData bytes Data generated by the user to be sent to the recipient.
    * @param _signedWithPrefix bool Whether "\x19Ethereum Signed Message:\n32" is prefixed
    * @param _sig_r bytes32 The r of the signature.
    * @param _sig_s bytes32 The s of the signature.
    * @param _sig_v uint8 The v of the signature.
    * @dev some rules:
    * 1. If _to is address(0), the tx will fail when doSend().
    * 2. If _delegate == address(0), then anyone can be the delegate.
    * 3. _nonce must be greater than the last used nonce by the token holder,
    *    but nonces don't have to be serial numbers.
    *    We recommend using unix time as nonce.
    * 4. _sig_v should be 27 or 28.
    */
  function transferPreSigned(
    address _to,
    address _delegate,
    uint256 _value,
    uint256 _fee,
    uint256 _nonce,
    bytes _userData,
    bool _signedWithPrefix,
    bytes32 _sig_r,
    bytes32 _sig_s,
    uint8 _sig_v
  )
    public
  {
    require(
      _delegate == address(0) || _delegate == msg.sender,
      "_delegate should be address(0) or msg.sender"
    );

    // bytes32 _hash = transferPreSignedHashing(...);
    bytes32 _hash = keccak256(
      abi.encodePacked(
        address(this),
        _to,
        _delegate,
        _value,
        _fee,
        _nonce,
        _userData
      )
    );
    if (_signedWithPrefix) {
      // _hash = toEthSignedMessageHash(_hash);
      _hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash));
    }

    // address _signer = recoverVrs(_hash, _sig_v, _sig_r, _sig_s);
    address _signer = (_sig_v != 27 && _sig_v != 28) ?
      address(0) :
      ecrecover(_hash, _sig_v, _sig_r, _sig_s);

    require(
      _signer != address(0),
      "_signature is invalid."
    );

    require(
      _nonce > usedNonce[_signer],
      "_nonce must be greater than the last used nonce of the token holder."
    );

    usedNonce[_signer] = _nonce;

    tokenContract.operatorSend(_signer, _to, _value, _userData, "");
    if (_fee > 0) {
      tokenContract.operatorSend(_signer, msg.sender, _fee, _userData, "");
    }
  }
}