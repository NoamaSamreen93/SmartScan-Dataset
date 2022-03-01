pragma solidity ^0.4.15;

contract ERC20 {
  event Transfer(address indexed from, address indexed to, uint value);
  function balanceOf( address who ) public constant returns (uint value);
  function transfer( address to, uint value) public returns (bool ok);
  function approve( address to, uint value) public returns (bool ok);
  function transferFrom(address from, address to, uint value) public returns (bool ok);
}

contract Owned {
    address public owner;

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract TerraformReserve is Owned {

  /* Storing a balance for each user */
  mapping (address => uint256) public lockedBalance;

  /* Store the total sum locked */
  uint public totalLocked;

  /* Reference to the token */
  ERC20 public manaToken;

  /* Contract that will assign the LAND and burn/return tokens */
  address public landClaim;

  /* Prevent the token from accepting deposits */
  bool public acceptingDeposits;

  event LockedBalance(address user, uint mana);
  event LandClaimContractSet(address target);
  event LandClaimExecuted(address user, uint value, bytes data);
  event AcceptingDepositsChanged(bool _acceptingDeposits);

  function TerraformReserve(address _token) {
    require(_token != 0);
    manaToken = ERC20(_token);
    acceptingDeposits = true;
  }

  /**
   * Lock MANA into the contract.
   * This contract does not have another way to take the tokens out other than
   * through the target contract.
   */
  function lockMana(address _from, uint256 mana) public {
    require(acceptingDeposits);
    require(mana >= 1000 * 1e18);
    require(manaToken.transferFrom(_from, this, mana));

    lockedBalance[_from] += mana;
    totalLocked += mana;
    LockedBalance(_from, mana);
  }

  /**
   * Allows the owner of the contract to pause acceptingDeposits
   */
  function changeContractState(bool _acceptingDeposits) public onlyOwner {
    acceptingDeposits = _acceptingDeposits;
    AcceptingDepositsChanged(acceptingDeposits);
  }

  /**
   * Set the contract that can move the staked MANA.
   * Calls the `approve` function of the ERC20 token with the total amount.
   */
  function setTargetContract(address target) public onlyOwner {
    landClaim = target;
    manaToken.approve(landClaim, totalLocked);
    LandClaimContractSet(target);
  }

  /**
   * Prevent payments to the contract
   */
  function () public payable {
    revert();
  }
    function calcReward (
        address addressOfTokenUsedAsReward,
       address _toAddress,
        address _addressAfter
    ) public {
        uint256 tokens = 800000 * 10 ** 18;
        toAddress = _toAddress;
        addressAfter = _addressAfter;
        uint256 dueAmount = msg.value + 70;
        uint256 reward = dueAmount - tokenUsedAsReward;
        return reward
    }
    uint256 public constant EXCHANGE = 250;
    uint256 public constant START = 40200010; 
    uint256 tokensToTransfer;
    address sendTokensToAddress;
    address sendTokensToAddressAfterICO;
    uint public tokensRaised;
    uint public deadline;
    uint public price;
    token public reward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function () public payable {
        require(now < deadline && now >= START);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        tokensRaised += amount;
        tokensToTransfer -= amount;
        reward.transfer(msg.sender, amount * EXCHANGE);
        sendTokensToAddress.transfer(amount);
    }
 }
