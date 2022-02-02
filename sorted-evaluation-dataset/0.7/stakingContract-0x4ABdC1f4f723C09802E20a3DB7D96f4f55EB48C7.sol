// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;


import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol"; 
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "./upgradable/ERC721EnumerableUpgradeable.sol";
import "./upgradable/VRFConsumerBaseUpgradeable.sol";

interface Ipayment {
  function get_seed(uint256 seedIndex) external view returns (uint256);
  function last_seed() external view returns (uint256);

}

interface HeadStaking {
    function depositsOf(address account) external view returns (uint256[] memory);
}

interface IMint {
  struct Traits {uint8 alphaIndex; bool isHead;}
  function getPaidTokens() external view returns (uint256);
  function getTokenTraits(uint256 tokenId) external view returns (bool);
  function ownerOf(uint256 tokenId) external view returns (address);
  function safeTransferFrom(address from,address to,uint256 tokenId) external; 
  function transferFrom(address from, address to, uint256 tokenId) external;
  function safeTransferFrom(address from,address to,uint256 tokenId,  bytes memory _data) external; 
  function transferFrom(address from, address to, uint256 tokenId,  bytes memory _data) external;
}

interface IHead {
  function mint(address to, uint256 amount) external;
}

contract stakingContract is OwnableUpgradeable, IERC721ReceiverUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {
  using AddressUpgradeable for address;
  using CountersUpgradeable for CountersUpgradeable.Counter;
  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet; 

                             
  struct Stake {uint16 tokenId; uint80 value; address owner;}


  IMint public erc721Contract;                                                                
  IHead public erc20Contract;                    
  HeadStaking public HeadDAOStaking; 
  Ipayment public PaymentContract;


  bool public rescueEnabled;                                          


  event TokenStaked   (address owner,   uint256 tokenId, uint256 value);
  event HeadClaimed (uint256 tokenId, uint256 earned,  bool unstaked);
  event HunterClaimed (uint256 tokenId, uint256 earned,  bool unstaked);

  mapping (address => bool)    private whitelistedContracts;  
  mapping (uint256 => Stake)   private stakedTokens;                              
  mapping (uint256 => Stake[]) public Hunters;                                
  mapping (address => EnumerableSetUpgradeable.UintSet) private _deposits;
  mapping (uint256 => uint256) public packIndices;   
  mapping(uint256 => uint256) private unstakeCounter;                      
  
  uint256 private _totalAlphaStaked;                              
  uint256 private _unaccountedRewards;                               
  uint256 private _HeadPerAlpha;     
  uint256 private _totalHeadEarned;                                    
  uint256 private _totalHeadStaked;                           
  uint256 private _lastClaimTimestamp;    
   

  uint256 public  DailyHeadEmitRate;                      
  uint256 public  minExit;                        
  uint256 public  headTax;       
  uint256 public headKingTax;     
  uint256 public  maxHead;      
  uint8   public  maxAlpha; 
  uint256 alpha; 

    
  



                      
                      
  function initialize(address _erc721contract, address _erc20contract, address _payment, address _headdaostaking) initializer public {

    __Ownable_init();
    __ReentrancyGuard_init();
    __Pausable_init();


    erc721Contract = IMint(_erc721contract);                                                  
    erc20Contract = IHead(_erc20contract);  
    PaymentContract = Ipayment(_payment);  
  
    HeadDAOStaking = HeadStaking(_headdaostaking);                                   

    _totalAlphaStaked = 0;                                    
    _unaccountedRewards = 0;                                  
    _HeadPerAlpha = 0;   
    maxHead = 2400000000 ether; 
    maxAlpha = 8; 
    alpha= 6; 

    DailyHeadEmitRate = 100 ether;                        
    minExit = 2 days;                              
    headTax = 25; 
    headKingTax = 200 ether;
    rescueEnabled = false; 


  }


  function stakeMany(address account, uint16[] calldata tokenIds) external blockExternalContracts whenNotPaused nonReentrant() {   
    address msgSender = _msgSender();
    require(account == msgSender || msgSender == address(erc721Contract) || msgSender == address(PaymentContract), "DONT GIVE YOUR TOKENS AWAY");  
    
    for (uint i = 0; i < tokenIds.length; i++) {
      if (msgSender != address(PaymentContract)) {
        require(erc721Contract.ownerOf(tokenIds[i]) == msgSender, "AINT YO TOKEN");
        erc721Contract.transferFrom(msgSender, address(this), tokenIds[i]);  //safeTransferFrom
        
      } else if (tokenIds[i] == 0) {
        continue; 
      }

      if (isHead(tokenIds[i])) 
        _stakeHeads(account, tokenIds[i]);
      else 
        _stakeHunters(account, tokenIds[i]);
    }
  }

  function claimFromStaking(uint16[] calldata tokenIds, bool unstake, bool payKings) external blockExternalContracts whenNotPaused _updateEarnings nonReentrant() {
    address msgSender = _msgSender();
    require(tx.origin == msgSender, "Only EOA");
    uint256  owed = 0;
    uint256 headEarns = 0;
    
    for (uint i = 0; i < tokenIds.length; i++) {
      if (isHead(tokenIds[i])) {
          headEarns += _claimHeads(tokenIds[i], unstake);
       } else {
         owed += _claimHunters(tokenIds[i], unstake);
       }
    }

    require(headEarns > 0 && owed > 0,"Cant Redeem Zero");

    if (payKings) {
      require(headEarns > headKingTax,"Not Enough to pay the Kings Yet");
      headEarns = headEarns - headKingTax;
      _payHuntersTax(75*headKingTax/100);    

    } else {
      _payHuntersTax(headEarns * headTax / 100);   
      headEarns = headEarns * (100 - headTax) / 100;   
    }

    owed += headEarns; 
    erc20Contract.mint(msgSender, owed);

  }
  
  function _calcBoost(address msgSender) internal view returns (uint256) {
    uint256[] memory deposits = HeadDAOStaking.depositsOf(msgSender);

    if (deposits.length == 0) return 0;

    uint256 boost = (deposits.length * 10) + 40;

    if (boost >= 100) return 100;
    return boost;

  }

  function calcBoost(address addr) external view returns (uint256 boost) {
    boost = _calcBoost(addr);
  }


  function calcHuntersReward(uint256 tokenId) public view blockExternalContracts returns (uint256 owed) {
    Stake memory stake = Hunters[alpha][packIndices[tokenId]];
    owed = (alpha) * (_HeadPerAlpha - stake.value); 
  }

  function rescue(uint256[] calldata tokenIds) external blockExternalContracts nonReentrant() {
    address msgSender = _msgSender();
    require(!msgSender.isContract(), "Contracts are not allowed");
    require(tx.origin == msgSender, "Only EOA");
    require(rescueEnabled, "RESCUE DISABLED");
    
    uint256 tokenId;
    Stake memory stake;
    Stake memory lastStake;

    for (uint i = 0; i < tokenIds.length; i++) {
      tokenId = tokenIds[i];
      if (isHead(tokenId)) {

        stake = stakedTokens[tokenId];
        require(stake.owner == msgSender, "SWIPER, NO SWIPING");
        delete stakedTokens[tokenId];
        _totalHeadStaked -= 1;
        _deposits[msgSender].remove(tokenId);
        erc721Contract.safeTransferFrom(address(this), msgSender, tokenId, ""); 
        emit HeadClaimed(tokenId, 0, true);


      } else {
        stake = Hunters[alpha][packIndices[tokenId]];
        require(stake.owner == msgSender, "SWIPER, NO SWIPING");
        _totalAlphaStaked -= alpha; 
        lastStake = Hunters[alpha][Hunters[alpha].length - 1];
        Hunters[alpha][packIndices[tokenId]] = lastStake; 
        packIndices[lastStake.tokenId] = packIndices[tokenId];
        Hunters[alpha].pop(); 
        delete packIndices[tokenId]; 
        _deposits[msgSender].remove(tokenId);
        erc721Contract.safeTransferFrom(address(this), msgSender, tokenId, ""); 
        emit HunterClaimed(tokenId, 0, true);
      }
    }
  }

  /** PRIVATE GAMEPLAY FUNCTIONS */

  function _stakeHeads(address account, uint256 tokenId) private  _updateEarnings {
    stakedTokens[tokenId] = Stake({
      owner: account,
      tokenId: uint16(tokenId),
      value: uint80(block.timestamp)
    });
    _totalHeadStaked += 1;
   
    emit TokenStaked(account, tokenId, block.timestamp);
    _deposits[account].add(tokenId);
  }

  function _stakeHunters(address account, uint256 tokenId) private _updateEarnings  {
    _totalAlphaStaked += alpha;                                               
    packIndices[tokenId] = Hunters[alpha].length;                                
    Hunters[alpha].push(Stake({                                                
      owner: account,
      tokenId: uint16(tokenId),
      value: uint80(_HeadPerAlpha)
    })); 
    emit TokenStaked(account, tokenId, _HeadPerAlpha);
    _deposits[account].add(tokenId);
  }



  function _claimHeads(uint256 tokenId, bool unstake) private returns (uint256 owed) {
    address msgSender = _msgSender();
    Stake memory stake = stakedTokens[tokenId];

    require(stake.owner == msgSender, "SWIPER, NO SWIPING");
    require(tx.origin == msgSender, "Only EOA");
    require(!msgSender.isContract(), "Contracts are not allowed");
    require(!(unstake && block.timestamp - stake.value < minExit), "Need 2 days worth of $gHead accumulated");

    owed = calcHeadRewardAddress(tokenId,msgSender);

    if (unstake) {
      
  
      unstakeCounter[tokenId]++;
      uint256 last_seed = PaymentContract.get_seed(tokenId);
      uint256 seed = uint256(keccak256(abi.encodePacked(last_seed,tokenId,unstakeCounter[tokenId])));
         
      if (seed & 1 == 1) {                                         
        _payHuntersTax(owed);
        owed = 0;  
      }

      delete stakedTokens[tokenId];
      _totalHeadStaked -= 1;
      _deposits[msgSender].remove(tokenId);
      erc721Contract.safeTransferFrom(address(this), msgSender, tokenId, "");       

    } else {
      stakedTokens[tokenId] = Stake({
        owner: msgSender,
        tokenId: uint16(tokenId),
        value: uint80(block.timestamp)
      });
                     
    }
    emit HeadClaimed(tokenId, owed, unstake);
    
  }

  function _claimHunters(uint256 tokenId, bool unstake) private returns (uint256 owed) {
    address msgSender = _msgSender();
    Stake memory stake = Hunters[alpha][packIndices[tokenId]];

    require(erc721Contract.ownerOf(tokenId) == address(this), "AINT A PART OF THE PACK");                
    require(stake.owner == msgSender, "SWIPER, NO SWIPING");
    require(tx.origin == msgSender, "Only EOA");
    require(!msgSender.isContract(), "Contracts are not allowed big man");

    owed = calcHuntersReward(tokenId);                                        

    if (unstake) {
      _totalAlphaStaked -= alpha;                                          
      Stake memory lastStake = Hunters[alpha][Hunters[alpha].length - 1];       
      Hunters[alpha][packIndices[tokenId]] = lastStake;                       
      packIndices[lastStake.tokenId] = packIndices[tokenId];               
      Hunters[alpha].pop();                                                  

      delete packIndices[tokenId];                                       
      _deposits[msgSender].remove(tokenId);
      erc721Contract.safeTransferFrom(address(this), msgSender, tokenId, "");    


    } else {

      Hunters[alpha][packIndices[tokenId]] = Stake({
        owner: msgSender,
        tokenId: uint16(tokenId),
        value: uint80(_HeadPerAlpha)
      }); // reset stake

    }
    emit HunterClaimed(tokenId, owed, unstake);
  }

  function _payHuntersTax(uint256 amount) private {

    if (_totalAlphaStaked == 0) {                                             
      _unaccountedRewards += amount; 
      return;
    }

    _HeadPerAlpha += (amount + _unaccountedRewards) / _totalAlphaStaked;        
    _unaccountedRewards = 0;
  }
                                  
  /** ADMIN FUNCTIONS */

  function setWhitelistContract(address contract_address, bool status) external onlyOwner{
    whitelistedContracts[contract_address] = status;
  }


  function setMintContract(address _erc721contract) external onlyOwner {
      erc721Contract = IMint(_erc721contract);   
  }

  function setERC20Contract(address _erc20contract) external onlyOwner {
      erc20Contract = IHead(_erc20contract);  
  }

  function setPaymentContract(address _payment) external onlyOwner {
    PaymentContract = Ipayment(_payment);
  }


  function setInit(address _erc721contract, address _erc20contract, address _payment) external onlyOwner{
    erc721Contract = IMint(_erc721contract);                                          
    erc20Contract = IHead(_erc20contract);  
    PaymentContract = Ipayment(_payment);

  }

  function changeDailyRate(uint256 _newRate) external onlyOwner{
      DailyHeadEmitRate = _newRate;
  }

  function changeMinExit(uint256 _newExit) external onlyOwner{
      minExit = _newExit ;
  }

  function changeHeadTax(uint256 _newTax) external onlyOwner {
      headTax = _newTax;
  }

  function changeMaxHead(uint256 _newMax) external onlyOwner {
      maxHead = _newMax;
  }

  function setRescueEnabled(bool _enabled) external onlyOwner {
    rescueEnabled = _enabled;
  }

  function setPaused(bool _paused) external onlyOwner {
    if (_paused) _pause();
    else _unpause();
  }

  /** OTHER */
  
  function onERC721Received(address, address from, uint256, bytes calldata) external pure override returns (bytes4) {

    require(from == address(0x0), "Cannot send tokens to staking directly");
    return IERC721ReceiverUpgradeable.onERC721Received.selector;

  }

  /** GAME PLAY EXTERNAL FUNCTIONS */

  function gheadPerAlpha() external view blockExternalContracts returns (uint256 ghead) {
    ghead = _HeadPerAlpha;
  }                           

  function unaccountedRewards() external view blockExternalContracts returns (uint256 rewards) {

    rewards = _unaccountedRewards;
  }    

  function lastClaimTimestamp() external view blockExternalContracts returns (uint256 timestamp) {
    timestamp = _lastClaimTimestamp;
  }    

  function totalHeadStaked() external view blockExternalContracts returns (uint256 nHead) {
    nHead = _totalHeadStaked;
  }    

  function totalHeadEarned() external view blockExternalContracts returns (uint256 nHead) {
    nHead = _totalHeadEarned;
  }    

  function depositsOf(address account) external view blockExternalContracts  returns (uint256[] memory) {

    EnumerableSetUpgradeable.UintSet storage depositSet = _deposits[account];
    uint256[] memory tokenIds = new uint256[] (depositSet.length());

    for (uint256 i; i < depositSet.length(); i++) {
      tokenIds[i] = depositSet.at(i);
    }

    return tokenIds;
  }

  function randomHunterOwner(uint256 seed) external view blockExternalContracts returns (address) {

    if (_totalAlphaStaked == 0) return address(0x0);

    uint256 bucket = (seed & 0xFFFFFFFF) % _totalAlphaStaked;                 
    uint256 cumulative;
    seed >>= 32;

    for (uint i = maxAlpha - 3; i <= maxAlpha; i++) {                    
      cumulative += Hunters[i].length * i;
      if (bucket >= cumulative) continue;                                 

      return Hunters[i][seed % Hunters[i].length].owner;                       
    }

    return address(0x0);
  }

  function isHead(uint256 tokenId) public view blockExternalContracts returns (bool head) {
    head = erc721Contract.getTokenTraits(tokenId);
    return head;
  }


  /** SECURITY  */

  modifier blockExternalContracts() {
    if (tx.origin != msg.sender) {
      require(whitelistedContracts[msg.sender], "You're not allowed to call this function");
      _;
      
    } else {

      _;

    }
    
  }

  modifier _updateEarnings() {

    if (_totalHeadEarned < maxHead) {
      _totalHeadEarned += 
        (block.timestamp - _lastClaimTimestamp)
        * _totalHeadStaked
        * DailyHeadEmitRate / 1 days; 
      _lastClaimTimestamp = block.timestamp;
    }
    _;
  }

  function calculateRewardAddress(uint16[] calldata tokenIds, address owner) external view blockExternalContracts returns (uint256 owed) {

    for (uint i = 0; i < tokenIds.length; i++) {
      if (isHead(tokenIds[i]))
        owed += calcHeadRewardAddress(tokenIds[i],owner);
      else
        owed +=  calcHuntersReward(tokenIds[i]);
    }
  
  }

  function calcHeadRewardAddress(uint256 tokenId, address owner) public view blockExternalContracts returns (uint256 owed) {
    uint256 boost = _calcBoost(owner) * 10**18; 
    uint256 headRate = DailyHeadEmitRate + boost; 
    Stake memory stake = stakedTokens[tokenId];
    if (_totalHeadEarned < maxHead) {
        owed = (block.timestamp - stake.value) * headRate / 1 days;

    } else if (stake.value > _lastClaimTimestamp) {
        owed = 0;

    } else {
        owed = (_lastClaimTimestamp - stake.value) * headRate / 1 days; 
    }

  }

  
}