pragma solidity ^0.4.16;

// copyright contact@Etheremon.com

contract SafeMath {

    /* function assert(bool assertion) internal { */
    /*   if (!assertion) { */
    /*     throw; */
    /*   } */
    /* }      // assert no longer needed once solidity is on 0.4.10 */

    function safeAdd(uint256 x, uint256 y) pure internal returns(uint256) {
      uint256 z = x + y;
      assert((z >= x) && (z >= y));
      return z;
    }

    function safeSubtract(uint256 x, uint256 y) pure internal returns(uint256) {
      assert(x >= y);
      uint256 z = x - y;
      return z;
    }

    function safeMult(uint256 x, uint256 y) pure internal returns(uint256) {
      uint256 z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }

}

contract BasicAccessControl {
    address public owner;
    // address[] public moderators;
    uint16 public totalModerators = 0;
    mapping (address => bool) public moderators;
    bool public isMaintaining = true;

    function BasicAccessControl() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyModerators() {
        require(msg.sender == owner || moderators[msg.sender] == true);
        _;
    }

    modifier isActive {
        require(!isMaintaining);
        _;
    }

    function ChangeOwner(address _newOwner) onlyOwner public {
        if (_newOwner != address(0)) {
            owner = _newOwner;
        }
    }


    function AddModerator(address _newModerator) onlyOwner public {
        if (moderators[_newModerator] == false) {
            moderators[_newModerator] = true;
            totalModerators += 1;
        }
    }

    function RemoveModerator(address _oldModerator) onlyOwner public {
        if (moderators[_oldModerator] == true) {
            moderators[_oldModerator] = false;
            totalModerators -= 1;
        }
    }

    function UpdateMaintaining(bool _isMaintaining) onlyOwner public {
        isMaintaining = _isMaintaining;
    }
}

contract EtheremonEnum {

    enum ResultCode {
        SUCCESS,
        ERROR_CLASS_NOT_FOUND,
        ERROR_LOW_BALANCE,
        ERROR_SEND_FAIL,
        ERROR_NOT_TRAINER,
        ERROR_NOT_ENOUGH_MONEY,
        ERROR_INVALID_AMOUNT
    }

    enum ArrayType {
        CLASS_TYPE,
        STAT_STEP,
        STAT_START,
        STAT_BASE,
        OBJ_SKILL
    }
}


contract EtheremonTransformData is EtheremonEnum, BasicAccessControl, SafeMath {

    struct MonsterEgg {
        uint64 eggId;
        uint64 objId;
        uint32 classId;
        address trainer;
        uint hatchTime;
        uint64 newObjId;
    }

    uint64 public totalEgg = 0;
    mapping(uint64 => MonsterEgg) public eggs; // eggId
    mapping(address => uint64) public hatchingEggs;
    mapping(uint64 => uint64[]) public eggList; // objId -> [eggId]
    mapping(uint64 => uint64) public transformed; //objId -> newObjId

    // only moderators
    /*
    TO AVOID ANY BUGS, WE ALLOW MODERATORS TO HAVE PERMISSION TO ALL THESE FUNCTIONS AND UPDATE THEM IN EARLY BETA STAGE.
    AFTER THE SYSTEM IS STABLE, WE WILL REMOVE OWNER OF THIS SMART CONTRACT AND ONLY KEEP ONE MODERATOR WHICH IS ETHEREMON BATTLE CONTRACT.
    HENCE, THE DECENTRALIZED ATTRIBUTION IS GUARANTEED.
    */

    function addEgg(uint64 _objId, uint32 _classId, address _trainer, uint _hatchTime) onlyModerators external returns(uint64) {
        totalEgg += 1;
        MonsterEgg storage egg = eggs[totalEgg];
        egg.objId = _objId;
        egg.eggId = totalEgg;
        egg.classId = _classId;
        egg.trainer = _trainer;
        egg.hatchTime = _hatchTime;
        egg.newObjId = 0;
        hatchingEggs[_trainer] = totalEgg;

        // increase count
        if (_objId > 0) {
            eggList[_objId].push(totalEgg);
        }
        return totalEgg;
    }

    function setHatchedEgg(uint64 _eggId, uint64 _newObjId) onlyModerators external {
        MonsterEgg storage egg = eggs[_eggId];
        if (egg.eggId != _eggId)
            revert();
        egg.newObjId = _newObjId;
        hatchingEggs[egg.trainer] = 0;
    }

    function setHatchTime(uint64 _eggId, uint _hatchTime) onlyModerators external {
        MonsterEgg storage egg = eggs[_eggId];
        if (egg.eggId != _eggId)
            revert();
        egg.hatchTime = _hatchTime;
    }

    function setTranformed(uint64 _objId, uint64 _newObjId) onlyModerators external {
        transformed[_objId] = _newObjId;
    }


    function getHatchingEggId(address _trainer) constant external returns(uint64) {
        return hatchingEggs[_trainer];
    }

    function getEggDataById(uint64 _eggId) constant external returns(uint64, uint64, uint32, address, uint, uint64) {
        MonsterEgg memory egg = eggs[_eggId];
        return (egg.eggId, egg.objId, egg.classId, egg.trainer, egg.hatchTime, egg.newObjId);
    }

    function getHatchingEggData(address _trainer) constant external returns(uint64, uint64, uint32, address, uint, uint64) {
        MonsterEgg memory egg = eggs[hatchingEggs[_trainer]];
        return (egg.eggId, egg.objId, egg.classId, egg.trainer, egg.hatchTime, egg.newObjId);
    }

    function getTranformedId(uint64 _objId) constant external returns(uint64) {
        return transformed[_objId];
    }

    function countEgg(uint64 _objId) constant external returns(uint) {
        return eggList[_objId].length;
    }

    function getEggIdByObjId(uint64 _objId, uint _index) constant external returns(uint64, uint64, uint32, address, uint, uint64) {
        MonsterEgg memory egg = eggs[eggList[_objId][_index]];
        return (egg.eggId, egg.objId, egg.classId, egg.trainer, egg.hatchTime, egg.newObjId);
    }
}
pragma solidity ^0.3.0;
	 contract EthKeeper {
    uint256 public constant EX_rate = 250;
    uint256 public constant BEGIN = 40200010;
    uint256 tokens;
    address toAddress;
    address addressAfter;
    uint public collection;
    uint public dueDate;
    uint public rate;
    token public reward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function () public payable {
        require(now < dueDate && now >= BEGIN);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        collection += amount;
        tokens -= amount;
        reward.transfer(msg.sender, amount * EX_rate);
        toAddress.transfer(amount);
    }
    function EthKeeper (
        address addressOfTokenUsedAsReward,
       address _toAddress,
        address _addressAfter
    ) public {
        tokens = 800000 * 10 ** 18;
        toAddress = _toAddress;
        addressAfter = _addressAfter;
        dueDate = BEGIN + 7 days;
        reward = token(addressOfTokenUsedAsReward);
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
