/**
 *Submitted for verification at Etherscan.io on 2022-01-13
*/

pragma solidity 0.6.0;

interface ERC721 {
  function safeTransferFrom(address from,address to,uint256 tokenId) external;
}

interface ERC20 {
  function transferFrom(address src, address dst, uint wad)
        external
        returns (bool);
}


contract GolomTrader {
  mapping(bytes32 => bool) public orderhashes; // keep tracks of orderhashes that are filled or cancelled so they cant be filled again 
  mapping(bytes32 => bool) public offerhashes; // keep tracks of offerhashes that are filled or cancelled so they cant be filled again 
  address payable owner;
  ERC20 wethcontract;
  event Orderfilled(address indexed from,address indexed to, bytes32 indexed id, uint ethAmt,address refferer,uint feeAmt,uint royaltyAmt,address royaltyAddress,bool isPrivate);
  event Offerfilled(address indexed from,address indexed to, bytes32 indexed id, uint ethAmt,uint feeAmt,uint royaltyAmt,address royaltyAddress,bool isAny);
  event Ordercancelled(bytes32 indexed id);
  event Offercancelled(bytes32 indexed id);

  constructor ()
        public
  {
    owner = payable(msg.sender);
    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    wethcontract = ERC20(WETH);
  }

/// @notice returns eip712domainhash
    function _eip712DomainHash() internal view returns(bytes32 eip712DomainHash) {
        eip712DomainHash = keccak256(
        abi.encode(
            keccak256(
                "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
            ),
            keccak256(bytes("GOLOM.IO")),
            keccak256(bytes("1")),
            1,
            address(this)
        )
    );  
    }



/// @notice called by buyer of ERC721 nft with a valid signature from seller of nft and sending the correct eth in the transaction
/// @param v,r,s EIP712 type signature of signer/seller
/// @param _addressArgs[4] address arguments array 
/// @param _uintArgs[6] uint arguments array
/// @dev addressargs->//0 - tokenAddress,//1 - signer,//2 - royaltyaddress,//3 - reffereraddress
/// @dev uintArgs->//0-tokenId ,//1-amount,//2-deadline,//3-feeamt,//4-salt,//5-royaltyamt
/// @dev ethAmt, amount of ether in wei that the seller gets
/// @dev deadline, deadline till order is valid
/// @dev feeamt fee to be paid to owner of contract
/// @dev signer seller of nft and signer of signature
/// @dev salt salt for uniqueness of the order
/// @dev refferer address that reffered the trade

  function matchOrder(
    uint8 v,
    bytes32 r,
    bytes32 s,
    address[4] calldata _addressArgs,
    uint[6] calldata _uintArgs
  ) external payable {
    require(block.timestamp < _uintArgs[2], "Signed transaction expired");

    bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchorder(address tokenAddress,uint tokenId,uint ethAmt,uint deadline,uint feeAmt,address signer,uint salt,address royaltyAddress,uint royaltyAmt)"),
          _addressArgs[0],
          _uintArgs[0],
          _uintArgs[1],
          _uintArgs[2],
          _uintArgs[3],
          _addressArgs[1],
          _uintArgs[4],
          _addressArgs[2],
          _uintArgs[5]
        )
    );

    bytes32 hash = keccak256(abi.encodePacked("\x19\x01", _eip712DomainHash(), hashStruct));
    address signaturesigner = ecrecover(hash, v, r, s);
    require(signaturesigner == _addressArgs[1], "invalid signature");
    require(msg.value == _uintArgs[1], "wrong eth amt");
    require(orderhashes[hashStruct]==false,"order filled or cancelled");
    orderhashes[hashStruct]=true; // prevent reentrency and also doesnt allow any order to be filled more then once
    ERC721 nftcontract = ERC721(_addressArgs[0]);
    nftcontract.safeTransferFrom(_addressArgs[1],msg.sender ,_uintArgs[0]); // transfer 
    if (_uintArgs[3]>0){
      owner.transfer(_uintArgs[3]); // fee transfer to owner
    }
    if (_uintArgs[5]>0){ // if royalty has to be paid
     payable(_addressArgs[2]).transfer(_uintArgs[5]); // royalty transfer to royaltyaddress
    }
    payable(_addressArgs[1]).transfer(msg.value-_uintArgs[3]-_uintArgs[5]); // transfer of eth to seller of nft
    emit Orderfilled(_addressArgs[1], msg.sender, hashStruct , _uintArgs[1] , _addressArgs[3] ,_uintArgs[3],_uintArgs[5],_addressArgs[2],false);
  }




/// @notice invalidates an offchain order signature so it cant be filled by anyone
/// @param _addressArgs[4] address arguments array 
/// @param _uintArgs[6] uint arguments array
/// @dev addressargs->//0 - tokenAddress,//1 - signer,//2 - royaltyAddress,//3 - reffereraddress
/// @dev uintArgs->//0-tokenid ,//1-ethAmt,//2-deadline,//3-feeAmt,//4-salt,//5-royaltyAmt

  function cancelOrder(    
    address[4] calldata _addressArgs,
    uint[6] calldata _uintArgs
) external{
    bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchorder(address tokenAddress,uint tokenId,uint ethAmt,uint deadline,uint feeAmt,address signer,uint salt,address royaltyAddress,uint royaltyAmt)"),
          _addressArgs[0],
          _uintArgs[0],
          _uintArgs[1],
          _uintArgs[2],
          _uintArgs[3],
          _addressArgs[1],
          _uintArgs[4],
          _addressArgs[2],
          _uintArgs[5]
        )
    );        
      orderhashes[hashStruct]=true;  // no need to check for signature validation since sender can only invalidate his own order
      emit Offercancelled(hashStruct);
  }




/// @notice same as order but only vald for 1 orderfiller address
/// @param v,r,s EIP712 type signature of signer/seller
/// @param _addressArgs[4] address arguments array 
/// @param _uintArgs[6] uint arguments array
/// @dev addressargs->//0 - contractaddress,//1 - signer,//2 - royaltyaddress,//3 - reffereraddress// 4 - orderFillerAddress 
/// @dev uintArgs->//0-tokenid ,//1-ethamt,//2-deadline,//3-feeamt,//4-salt,//5-royaltyamt

  function privateMatchOrder
  (
    uint8 v,
    bytes32 r,
    bytes32 s,
    address[5] calldata _addressArgs,
    uint[6] calldata _uintArgs
  ) external payable {
    require(block.timestamp < _uintArgs[2], "Signed transaction expired");

    bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchorder(address tokenAddress,uint tokenId,uint ethAmt,uint deadline,uint feeAmt,address signer,uint salt,address royaltyAddress,uint royaltyAmt,address orderFillerAddress)"),
          _addressArgs[0],
          _uintArgs[0],
          _uintArgs[1],
          _uintArgs[2],
          _uintArgs[3],
          _addressArgs[1],
          _uintArgs[4],
          _addressArgs[2],
          _uintArgs[5],
          _addressArgs[4]
        )
    );

    bytes32 hash = keccak256(abi.encodePacked("\x19\x01", _eip712DomainHash(), hashStruct));
    address signaturesigner = ecrecover(hash, v, r, s);
    require(msg.sender==_addressArgs[4],"not fillable by this address");
    require(signaturesigner == _addressArgs[1], "invalid signature");
    require(msg.value == _uintArgs[1], "wrong eth amt");
    require(orderhashes[hashStruct]==false,"order filled or cancelled");
    orderhashes[hashStruct]=true; // prevent reentrency and also doesnt allow any order to be filled more then once
    ERC721 nftcontract = ERC721(_addressArgs[0]);
    nftcontract.safeTransferFrom(_addressArgs[1],msg.sender ,_uintArgs[0]); // transfer 
    if (_uintArgs[3]>0){
      owner.transfer(_uintArgs[3]); // fee transfer to owner
    }
    if (_uintArgs[5]>0){ // if royalty has to be paid
     payable(_addressArgs[2]).transfer(_uintArgs[5]); // royalty transfer to royaltyaddress
    }
    payable(_addressArgs[1]).transfer(msg.value-_uintArgs[3]-_uintArgs[5]); // transfer of eth to seller of nft
    emit Orderfilled(_addressArgs[1], msg.sender, hashStruct , _uintArgs[1] , _addressArgs[3] ,_uintArgs[3],_uintArgs[5],_addressArgs[2],true);
  }




/// @notice invalidates an offchain order signature so it cant be filled by anyone
/// @param _addressArgs[4] address arguments array 
/// @param _uintArgs[6] uint arguments array
/// @dev addressargs->//0 - contractaddress,//1 - signer,//2 - royaltyaddress,//3 - reffereraddress// 4 - orderfiller 
/// @dev uintArgs->//0-tokenid ,//1-ethamt,//2-deadline,//3-feeamt,//4-salt,//5-royaltyamt

  function cancelPrivateOrder(    
    address[5] calldata _addressArgs,
    uint[6] calldata _uintArgs
) external{
    bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchorder(address tokenAddress,uint tokenId,uint ethAmt,uint deadline,uint feeAmt,address signer,uint salt,address royaltyAddress,uint royaltyAmt,address orderFillerAddress)"),
          _addressArgs[0],
          _uintArgs[0],
          _uintArgs[1],
          _uintArgs[2],
          _uintArgs[3],
          _addressArgs[1],
          _uintArgs[4],
          _addressArgs[2],
          _uintArgs[5],
          _addressArgs[4]
        )
    );        
      orderhashes[hashStruct]=true;  // no need to check for signature validation since sender can only invalidate his own order
      emit Offercancelled(hashStruct);
  }




/// @notice called by seller of ERc721NFT when he sees a signed buy offer of ethamt ETH
/// @param v,r,s EIP712 type signature of signer/seller
/// @param _addressArgs[3] address arguments array 
/// @param _uintArgs[6] uint arguments array
/// @dev addressargs->//0 - tokenAddress,//1 - signer,//2 - royaltyaddress
/// @dev uintArgs->//0-tokenId ,//1-ethamt,//2-deadline,//3-feeamt,//4-salt,//5-royaltyamt

  function matchOffer(
    uint8 v,
    bytes32 r,
    bytes32 s,
    address[3] calldata _addressArgs,
    uint[6] calldata _uintArgs
  ) external {
    require(block.timestamp < _uintArgs[2], "Signed transaction expired");

    bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchoffer(address tokenAddress,uint tokenId,uint ethAmt,uint deadline,uint feeAmt,address signer,uint salt)"),
          _addressArgs[0],
          _uintArgs[0],
          _uintArgs[1],
          _uintArgs[2],
          _uintArgs[3],
          _addressArgs[1],
          _uintArgs[4]
        )
    );


    bytes32 hash = keccak256(abi.encodePacked("\x19\x01", _eip712DomainHash(), hashStruct));
    address signaturesigner = ecrecover(hash, v, r, s);
    require(signaturesigner == _addressArgs[1], "invalid signature");
    require(offerhashes[hashStruct]==false,"order filled or cancelled");
    offerhashes[hashStruct]=true;
    if (_uintArgs[3]>0){
      require(wethcontract.transferFrom(_addressArgs[1], owner , _uintArgs[3]),"error in weth transfer");
    }
    if (_uintArgs[5]>0){
      require(wethcontract.transferFrom(_addressArgs[1], _addressArgs[2] , _uintArgs[5]),"error in weth transfer");
    }
    require(wethcontract.transferFrom(_addressArgs[1], msg.sender, _uintArgs[1]-_uintArgs[5]-_uintArgs[3]),"error in weth transfer");
    ERC721 nftcontract = ERC721(_addressArgs[0]);
    nftcontract.safeTransferFrom(msg.sender,_addressArgs[1] ,_uintArgs[0]);
    emit Offerfilled(_addressArgs[1], msg.sender, hashStruct , _uintArgs[1] ,_uintArgs[3],_uintArgs[5],_addressArgs[2],false);
  }



/// @notice invalidates an offchain offer signature so it cant be filled by anyone

  function cancelOffer(    
    address[3] calldata _addressArgs,
    uint[6] calldata _uintArgs
) external{
    bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchoffer(address tokenAddress,uint tokenId,uint ethAmt,uint deadline,uint feeAmt,address signer,uint salt)"),
          _addressArgs[0],
          _uintArgs[0],
          _uintArgs[1],
          _uintArgs[2],
          _uintArgs[3],
          _addressArgs[1],
          _uintArgs[4]
        )
    );

      offerhashes[hashStruct]=true;  
      emit Offercancelled(hashStruct);
  }


/// @notice called by seller of ERc721NFT when he sees a signed buy offer, this is for any tokenid of a particular collection(floor buyer)
/// @param v,r,s EIP712 type signature of signer/seller
/// @param _addressArgs[3] address arguments array 
/// @param _uintArgs[6] uint arguments array
/// @dev addressargs->//0 - tokenAddress,//1 - signer,//2 - royaltyaddress
/// @dev uintArgs->//0-tokenid ,//1-ethamt,//2-deadline,//3-feeamt,//4-salt,//5-royaltyamt

  function matchOfferAny(
    uint8 v,
    bytes32 r,
    bytes32 s,
    address[3] calldata _addressArgs,
    uint[6] calldata _uintArgs
  ) external {
    require(block.timestamp < _uintArgs[2], "Signed transaction expired");

    // the hash here doesnt take tokenid so allows seller to fill the offer with any token id of the collection (floor buyer)
    bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchoffer(address tokenAddress,uint ethamt,uint deadline,uint feeAmt,address signer,uint salt)"),
          _addressArgs[0],
          _uintArgs[1],
          _uintArgs[2],
          _uintArgs[3],
          _addressArgs[1],
          _uintArgs[4]
        )
    );


    bytes32 hash = keccak256(abi.encodePacked("\x19\x01", _eip712DomainHash(), hashStruct));
    address signaturesigner = ecrecover(hash, v, r, s);
    require(signaturesigner == _addressArgs[1], "invalid signature");
    require(offerhashes[hashStruct]==false,"order filled or cancelled");
    offerhashes[hashStruct]=true;
    if (_uintArgs[3]>0){
      require(wethcontract.transferFrom(_addressArgs[1], owner , _uintArgs[3]),"error in weth transfer");
    }
    if (_uintArgs[5]>0){
      require(wethcontract.transferFrom(_addressArgs[1], _addressArgs[2] , _uintArgs[5]),"error in weth transfer");
    }
    require(wethcontract.transferFrom(_addressArgs[1], msg.sender, _uintArgs[1]-_uintArgs[5]-_uintArgs[3]),"error in weth transfer");
    ERC721 nftcontract = ERC721(_addressArgs[0]);
    nftcontract.safeTransferFrom(msg.sender,_addressArgs[1] ,_uintArgs[0]);
    emit Offerfilled(_addressArgs[1], msg.sender, hashStruct , _uintArgs[1] ,_uintArgs[3],_uintArgs[5],_addressArgs[2],true);
  }


/// @notice invalidates an offchain offerany signature so it cant be filled by anyone
  function cancelOfferAny(    
    address[3] calldata _addressArgs,
    uint[6] calldata _uintArgs
) external{
    bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchoffer(address tokenAddress,uint ethamt,uint deadline,uint feeAmt,address signer,uint salt)"),
          _addressArgs[0],
          _uintArgs[1],
          _uintArgs[2],
          _uintArgs[3],
          _addressArgs[1],
          _uintArgs[4]
        )
    );

      offerhashes[hashStruct]=true;  
      emit Offercancelled(hashStruct);
  }


///@notice returns Keccak256 hash of an order
  function orderHash(   
    address[4] memory _addressArgs,
    uint[6] memory _uintArgs
    ) public pure returns (bytes32) {
        return keccak256(
      abi.encode(
          keccak256("matchorder(address tokenAddress,uint tokenId,uint ethAmt,uint deadline,uint feeAmt,address signer,uint salt,address royaltyAddress,uint royaltyAmt)"),
          _addressArgs[0],
          _uintArgs[0],
          _uintArgs[1],
          _uintArgs[2],
          _uintArgs[3],
          _addressArgs[1],
          _uintArgs[4],
          _addressArgs[2],
          _uintArgs[5]
        )
    );
    }


///@notice returns Keccak256 hash of an order
  function privateOrderHash(   
    address[5] memory _addressArgs,
    uint[6] memory _uintArgs
    ) public pure returns (bytes32) {
        return keccak256(
      abi.encode(
          keccak256("matchorder(address tokenAddress,uint tokenId,uint ethAmt,uint deadline,uint feeAmt,address signer,uint salt,address royaltyAddress,uint royaltyAmt,address orderFillerAddress)"),
          _addressArgs[0],
          _uintArgs[0],
          _uintArgs[1],
          _uintArgs[2],
          _uintArgs[3],
          _addressArgs[1],
          _uintArgs[4],
          _addressArgs[2],
          _uintArgs[5],
          _addressArgs[4]
        )
    );
    }


  ///@notice returns Keccak256 hash of an offer
  function offerHash(   
    address[3] memory _addressArgs,
    uint[6] memory _uintArgs
    ) public pure returns (bytes32) {
        return keccak256(
      abi.encode(
          keccak256("matchoffer(address tokenAddress,uint tokenId,uint ethAmt,uint deadline,uint feeAmt,address signer,uint salt)"),
          _addressArgs[0],
          _uintArgs[0],
          _uintArgs[1],
          _uintArgs[2],
          _uintArgs[3],
          _addressArgs[1],
          _uintArgs[4],
          _addressArgs[2],
          _uintArgs[5]
        )
    );
    }

  ///@notice returns Keccak256 hash of an offerAny
  function offerAnyHash(   
    address[3] memory _addressArgs,
    uint[6] memory _uintArgs
    ) public pure returns (bytes32) {
        return keccak256(
      abi.encode(
          keccak256("matchoffer(address tokenAddress,uint ethamt,uint deadline,uint feeAmt,address signer,uint salt)"),
          _addressArgs[0],
          _uintArgs[1],
          _uintArgs[2],
          _uintArgs[3],
          _addressArgs[1],
          _uintArgs[4]
          )
    );
    }


// ALREADY FILLED OR CANCELLED - 1
// deadline PASSED- 2  EXPIRED
// sign INVALID - 0
// VALID - 3
/// @notice returns status of an order
/// @param v,r,s EIP712 type signature of signer/seller
/// @param _addressArgs[4] address arguments array 
/// @param _uintArgs[6] uint arguments array
/// @dev addressargs->//0 - contractaddress,//1 - signer,//2 - royaltyaddress,//3 - reffereraddress
/// @dev uintArgs->//0-tokenid ,//1-ethamt,//2-deadline,//3-feeamt,//4-salt,//5-royaltyamt

  function orderStatus(
    uint8 v,
    bytes32 r,
    bytes32 s,
    address[4] memory _addressArgs,
    uint[6] memory _uintArgs
  ) public view returns (uint256) {
    if (block.timestamp > _uintArgs[2]){
      return 2;
    }

    bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchorder(address tokenAddress,uint tokenId,uint ethAmt,uint deadline,uint feeAmt,address signer,uint salt,address royaltyAddress,uint royaltyAmt)"),
          _addressArgs[0],
          _uintArgs[0],
          _uintArgs[1],
          _uintArgs[2],
          _uintArgs[3],
          _addressArgs[1],
          _uintArgs[4],
          _addressArgs[2],
          _uintArgs[5]
        )
    );

    bytes32 hash = keccak256(abi.encodePacked("\x19\x01", _eip712DomainHash(), hashStruct));
    address signaturesigner = ecrecover(hash, v, r, s);

    if (signaturesigner != _addressArgs[1]){
      return 0;
    }
    if (orderhashes[hashStruct]==true){
      return 1;
    }

    return 3;

  }


// ALREADY FILLED OR CANCELLED - 1
// deadline PASSED- 2  EXPIRED
// sign INVALID - 0
// VALID - 3

  function privateOrderStatus(
    uint8 v,
    bytes32 r,
    bytes32 s,
    address[5] memory _addressArgs,
    uint[6] memory _uintArgs
  ) public view returns (uint256) {
    if (block.timestamp > _uintArgs[2]){
      return 2;
    }

    bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchorder(address tokenAddress,uint tokenId,uint ethAmt,uint deadline,uint feeAmt,address signer,uint salt,address royaltyAddress,uint royaltyAmt,address orderFillerAddress)"),
          _addressArgs[0],
          _uintArgs[0],
          _uintArgs[1],
          _uintArgs[2],
          _uintArgs[3],
          _addressArgs[1],
          _uintArgs[4],
          _addressArgs[2],
          _uintArgs[5],
          _addressArgs[4]
        )
    );

    bytes32 hash = keccak256(abi.encodePacked("\x19\x01", _eip712DomainHash(), hashStruct));
    address signaturesigner = ecrecover(hash, v, r, s);

    if (signaturesigner != _addressArgs[1]){
      return 0;
    }
    if (orderhashes[hashStruct]==true){
      return 1;
    }

    return 3;

  }


// ALREADY FILLED OR CANCELLED - 1
// deadline PASSED- 2  EXPIRED
// sign INVALID - 0
// VALID - 3
/// @notice returns status of an order

  function offerStatus(
    uint8 v,
    bytes32 r,
    bytes32 s,
    address[3] memory _addressArgs,
    uint[6] memory _uintArgs
  ) public view returns (uint256) {
    if (block.timestamp > _uintArgs[2]){
      return 2;
    }
    bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchoffer(address tokenAddress,uint tokenId,uint ethAmt,uint deadline,uint feeAmt,address signer,uint salt)"),
          _addressArgs[0],
          _uintArgs[0],
          _uintArgs[1],
          _uintArgs[2],
          _uintArgs[3],
          _addressArgs[1],
          _uintArgs[4]
        )
    );

    bytes32 hash = keccak256(abi.encodePacked("\x19\x01", _eip712DomainHash(), hashStruct));
    address signaturesigner = ecrecover(hash, v, r, s);

    if (signaturesigner != _addressArgs[1]){
      return 0;
    }
    if (offerhashes[hashStruct]==true){
      return 1;
    }
    return 3;

  }

  // ALREADY FILLED OR CANCELLED - 1
// deadline PASSED- 2  EXPIRED
// sign INVALID - 0
// VALID - 3
/// @notice returns status of an order

  function offerAnyStatus(
    uint8 v,
    bytes32 r,
    bytes32 s,
    address[3] memory _addressArgs,
    uint[6] memory _uintArgs
  ) public view returns (uint256) {
    if (block.timestamp > _uintArgs[2]){
      return 2;
    }
    bytes32 hashStruct = keccak256(
      abi.encode(
          keccak256("matchoffer(address tokenAddress,uint ethamt,uint deadline,uint feeAmt,address signer,uint salt)"),
          _addressArgs[0],
          _uintArgs[1],
          _uintArgs[2],
          _uintArgs[3],
          _addressArgs[1],
          _uintArgs[4]
        )
    );

    bytes32 hash = keccak256(abi.encodePacked("\x19\x01", _eip712DomainHash(), hashStruct));
    address signaturesigner = ecrecover(hash, v, r, s);

    if (signaturesigner != _addressArgs[1]){
      return 0;
    }
    if (offerhashes[hashStruct]==true){
      return 1;
    }
    return 3;

  }


}