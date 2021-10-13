pragma solidity ^0.4.24;

/* Required code start */
contract MarketplaceProxy {
    function calculatePlatformCommission(uint256 weiAmount) public view returns (uint256);
    function payPlatformIncomingTransactionCommission(address clientAddress) public payable;
    function payPlatformOutgoingTransactionCommission() public payable;
    function isUserBlockedByContract(address contractAddress) public view returns (bool);
}
/* Required code end */

/// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.
/// @author Stefan George - <stefan.george@consensys.net>
contract Fund {

    /*
     *  Events
     */
    event Confirmation(address sender, uint256 transactionId);
    event Revocation(address sender, uint256 transactionId);
    event Submission(uint256 transactionId);
    event Execution(uint256 transactionId);
    event ExecutionFailure(uint256 transactionId);
    event OwnerAddition(address owner);
    event OwnerRemoval(address owner);
    event RequirementChange(uint256 required);
    event MemberAdded(address member);
    event MemberBlocked(address member);
    event MemberUnblocked(address member);
    event FeeAmountChanged(uint256 feeAmount);
    event NextMemberPaymentAdded(address member, uint256 expectingAmount, uint256 platformCommission);
    event NextMemberPaymentUpdated(address member, uint256 expectingAmount, uint256 platformCommission);
    event IncomingPayment(address sender, uint256 value);
    event Claim(address to, uint256 value);
    event Transfer(address to, uint256 value);

    /*
     *  Constants
     */
    uint256 constant public MAX_OWNER_COUNT = 50;

    /*
     *  Storage
     */
    mapping (uint256 => Transaction) public transactions;
    mapping (uint256 => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    mapping (address => Member) public members;
    mapping (address => NextMemberPayment) public nextMemberPayments;
    address[] public owners;
    address public creator;
    uint256 public required;
    uint256 public transactionCount;
    uint256 public feeAmount;   // amount in wei
    struct Transaction {
        address destination;
        uint256 value;
        bytes data;
        bool executed;
    }
    struct Member {
        bool exists;
        bool blocked;
    }
    struct NextMemberPayment {
        bool exists;
        uint256 expectingValue;       // wei, value that we wait in member incoiming transaction
        uint256 platformCommission;   // wei, value that we send to Marketplace contract
    }

    /* Required code start */
    MarketplaceProxy public mp;
    event PlatformIncomingTransactionCommission(uint256 amount, address clientAddress);
    event PlatformOutgoingTransactionCommission(uint256 amount);
    event Blocked();
    /* Required code end */

    /*
     *  Modifiers
     */
    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner]);
        _;
    }

    modifier ownerExists(address owner) {
        require(isOwner[owner]);
        _;
    }

    modifier transactionExists(uint256 transactionId) {
        require(transactions[transactionId].destination != 0);
        _;
    }

    modifier confirmed(uint256 transactionId, address owner) {
        require(confirmations[transactionId][owner]);
        _;
    }

    modifier notConfirmed(uint256 transactionId, address owner) {
        require(!confirmations[transactionId][owner]);
        _;
    }

    modifier notExecuted(uint256 transactionId) {
        require(!transactions[transactionId].executed);
        _;
    }

    modifier notNull(address _address) {
        require(_address != 0);
        _;
    }

    modifier validRequirement(uint256 ownerCount, uint256 _required) {
        require(ownerCount <= MAX_OWNER_COUNT
            && _required <= ownerCount
            && _required != 0
            && ownerCount != 0);
        _;
    }

    /**
     * @dev Throws if called by any account other than the creator.
     */
    modifier onlyCreator() {
        require(msg.sender == creator);
        _;
    }

    /**
     * @dev Throws if member does not exist.
     */
    modifier memberExists(address member) {
        require(members[member].exists);
        _;
    }

    /**
     * @dev Throws if member exists.
     */
    modifier memberDoesNotExist(address member) {
        require(!members[member].exists);
        _;
    }

    /**
     * @dev Throws if does not exist.
     */
    modifier nextMemberPaymentExists(address member) {
        require(nextMemberPayments[member].exists);
        _;
    }

    /**
     * @dev Throws if exists.
     */
    modifier nextMemberPaymentDoesNotExist(address member) {
        require(!nextMemberPayments[member].exists);
        _;
    }

    /// @dev Fallback function allows to deposit ether.
    function()
        public
        payable
    {
        handleIncomingPayment(msg.sender);
    }

    /**
     * @dev Handles payment gateway transactions
     * @param member when payment method is fiat money
     */
    function fromPaymentGateway(address member)
        public
        memberExists(member)
        nextMemberPaymentExists(member)
        payable
    {
        handleIncomingPayment(member);
    }

    /**
     * @dev Send commission to marketplace
     * @param member address
     */
    function handleIncomingPayment(address member)
        private
    {
        if (nextMemberPayments[member].exists) {
            NextMemberPayment storage nextMemberPayment = nextMemberPayments[member];

            require(nextMemberPayment.expectingValue == msg.value);

            /* Required code start */
            // Send all incoming eth if user blocked
            if (mp.isUserBlockedByContract(address(this))) {
                mp.payPlatformIncomingTransactionCommission.value(msg.value)(member);
                emit Blocked();
            } else {
                mp.payPlatformIncomingTransactionCommission.value(nextMemberPayment.platformCommission)(member);
                emit PlatformIncomingTransactionCommission(nextMemberPayment.platformCommission, member);
            }
            /* Required code end */
        }

        emit IncomingPayment(member, msg.value);
    }

    /**
     * @dev Creator can add ETH to contract without commission
     */
    function addEth()
        public
        onlyCreator
        payable
    {

    }

    /*
     * Public functions
     */
    /// @dev Contract constructor sets initial owners and required number of confirmations.
    constructor()
        public
    {
        required = 1;           // Initial value
        creator = msg.sender;

        /* Required code start */
        // NOTE: CHANGE ADDRESS ON PRODUCTION
        mp = MarketplaceProxy(0x7b71342582610452641989D599a684501922Cb57);
        /* Required code end */

    }

    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of new owner.
    function addOwner(address owner)
        public
        onlyCreator
        ownerDoesNotExist(owner)
        notNull(owner)
        validRequirement(owners.length + 1, required)
    {
        isOwner[owner] = true;
        owners.push(owner);
        emit OwnerAddition(owner);
    }

    /// @dev Allows to remove an owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner.
    function removeOwner(address owner)
        public
        onlyCreator
        ownerExists(owner)
    {
        isOwner[owner] = false;
        for (uint256 i=0; i<owners.length - 1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        owners.length -= 1;
        if (required > owners.length)
            changeRequirement(owners.length);
        emit OwnerRemoval(owner);
    }

    /// @dev Allows to replace an owner with a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner to be replaced.
    /// @param newOwner Address of new owner.
    function replaceOwner(address owner, address newOwner)
        public
        onlyCreator
        ownerExists(owner)
        ownerDoesNotExist(newOwner)
    {
        for (uint256 i=0; i<owners.length; i++)
            if (owners[i] == owner) {
                owners[i] = newOwner;
                break;
            }
        isOwner[owner] = false;
        isOwner[newOwner] = true;
        emit OwnerRemoval(owner);
        emit OwnerAddition(newOwner);
    }

    /// @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet.
    /// @param _required Number of required confirmations.
    function changeRequirement(uint256 _required)
        public
        onlyCreator
        validRequirement(owners.length, _required)
    {
        required = _required;
        emit RequirementChange(_required);
    }

    /// @dev Allows a creator to init a transaction.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @return Returns transaction ID.
    function initTransaction(address destination, uint256 value)
        public
        onlyCreator
        returns (uint256 transactionId)
    {
        transactionId = addTransaction(destination, value);
    }

    /// @dev Allows an owner to confirm a transaction.
    /// @param transactionId Transaction ID.
    function confirmTransaction(uint256 transactionId)
        public
        ownerExists(msg.sender)
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    /// @dev Allows an owner to revoke a confirmation for a transaction.
    /// @param transactionId Transaction ID.
    function revokeConfirmation(uint256 transactionId)
        public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId);
    }

    /// @dev Allows anyone to execute a confirmed transaction.
    /// @param transactionId Transaction ID.
    function executeTransaction(uint256 transactionId)
        public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;
            if (external_call(txn.destination, txn.value, txn.data.length, txn.data))
                emit Execution(transactionId);
            else {
                emit ExecutionFailure(transactionId);
                txn.executed = false;
            }
        }
    }

    // call has been separated into its own function in order to take advantage
    // of the Solidity's code generator to produce a loop that copies tx.data into memory.
    function external_call(address destination, uint256 value, uint256 dataLength, bytes data) private returns (bool) {
        bool result;
        assembly {
            let x := mload(0x40)   // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)
            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that
            result := call(
                sub(gas, 34710),   // 34710 is the value that solidity is currently emitting
                                   // It includes callGas (700) + callVeryLow (3, to pay for SUB) + callValueTransferGas (9000) +
                                   // callNewAccountGas (25000, in case the destination address does not exist and needs creating)
                destination,
                value,
                d,
                dataLength,        // Size of the input (in bytes) - this is what fixes the padding problem
                x,
                0                  // Output is ignored, therefore the output size is zero
            )
        }
        return result;
    }

    /// @dev Returns the confirmation status of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Confirmation status.
    function isConfirmed(uint256 transactionId)
        public
        view
        returns (bool)
    {
        uint256 count = 0;
        for (uint256 i=0; i<owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }

    /**
     * @dev Block existing member.
     * @param member address
     */
    function blockMember(address member)
        public
        onlyCreator
        memberExists(member)
    {
        members[member].blocked = true;
        emit MemberBlocked(member);
    }

    /**
     * @dev Unblock existing member.
     * @param member address
     */
    function unblockMember(address member)
        public
        onlyCreator
        memberExists(member)
    {
        members[member].blocked = false;
        emit MemberUnblocked(member);
    }

    /**
     * @param member address
     * @return bool
     */
    function isMemberBlocked(address member)
        public
        view
        memberExists(member)
        returns (bool)
    {
        return members[member].blocked;
    }

    /**
     * @dev Add a new member to structure.
     * @param member address
     */
    function addMember(address member)
        public
        onlyCreator
        notNull(member)
        memberDoesNotExist(member)
    {
        members[member] = Member(
            true,   // exists
            false   // blocked
        );
        emit MemberAdded(member);
    }

    /**
     * @param _feeAmount new amount in wei
     */
    function setFeeAmount(uint256 _feeAmount)
        public
        onlyCreator
    {
        feeAmount = _feeAmount;
        emit FeeAmountChanged(_feeAmount);
    }

    /**
     * @param member address
     * @return bool
     */
    function addNextMemberPayment(address member, uint256 expectingValue, uint256 platformCommission)
        public
        onlyCreator
        memberExists(member)
        nextMemberPaymentDoesNotExist(member)
    {
        nextMemberPayments[member] = NextMemberPayment(
            true,
            expectingValue,
            platformCommission
        );
        emit NextMemberPaymentAdded(member, expectingValue, platformCommission);
    }

    /**
     * @param member address
     * @return bool
     */
    function updateNextMemberPayment(address member, uint256 _expectingValue, uint256 _platformCommission)
        public
        onlyCreator
        memberExists(member)
        nextMemberPaymentExists(member)
    {
        nextMemberPayments[member].expectingValue = _expectingValue;
        nextMemberPayments[member].platformCommission = _platformCommission;
        emit NextMemberPaymentUpdated(member, _expectingValue, _platformCommission);
    }

    /**
     * @param to send ETH on this address
     * @param amount 18 decimals (wei)
     */
    function claim(address to, uint256 amount)
        public
        onlyCreator
        memberExists(to)
    {
        /* Required code start */
        // Get commission amount from marketplace
        uint256 commission = mp.calculatePlatformCommission(amount);
        require(address(this).balance > (amount + commission));

        // Send commission to marketplace
        mp.payPlatformOutgoingTransactionCommission.value(commission)();
        emit PlatformOutgoingTransactionCommission(commission);
        /* Required code end */

        to.transfer(amount);

        emit Claim(to, amount);
    }

    /**
     * @param to send ETH on this address
     * @param amount 18 decimals (wei)
     */
    function transfer(address to, uint256 amount)
        public
        onlyCreator
        ownerExists(to)
    {
        /* Required code start */
        require(address(this).balance > amount);
        /* Required code end */

        to.transfer(amount);

        emit Transfer(to, amount);
    }

    /*
     * Internal functions
     */
    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @return Returns transaction ID.
    function addTransaction(address destination, uint256 value)
        internal
        notNull(destination)
        returns (uint256 transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: "",
            executed: false
        });
        transactionCount += 1;
        emit Submission(transactionId);
    }

    /*
     * Web3 call functions
     */
    /// @dev Returns number of confirmations of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Number of confirmations.
    function getConfirmationCount(uint256 transactionId)
        public
        view
        returns (uint256 count)
    {
        for (uint256 i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]])
                count += 1;
    }

    /// @dev Returns total number of transactions after filers are applied.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Total number of transactions after filters are applied.
    function getTransactionCount(bool pending, bool executed)
        public
        view
        returns (uint256 count)
    {
        for (uint256 i=0; i<transactionCount; i++)
            if (   pending && !transactions[i].executed
                || executed && transactions[i].executed)
                count += 1;
    }

    /// @dev Returns list of owners.
    /// @return List of owner addresses.
    function getOwners()
        public
        view
        returns (address[])
    {
        return owners;
    }

    /// @dev Returns array with owner addresses, which confirmed transaction.
    /// @param transactionId Transaction ID.
    /// @return Returns array of owner addresses.
    function getConfirmations(uint256 transactionId)
        public
        view
        returns (address[] _confirmations)
    {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint256 count = 0;
        uint256 i;
        for (i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i=0; i<count; i++)
            _confirmations[i] = confirmationsTemp[i];
    }

    /// @dev Returns list of transaction IDs in defined range.
    /// @param from Index start position of transaction array.
    /// @param to Index end position of transaction array.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Returns array of transaction IDs.
    function getTransactionIds(uint256 from, uint256 to, bool pending, bool executed)
        public
        view
        returns (uint[] _transactionIds)
    {
        uint[] memory transactionIdsTemp = new uint[](transactionCount);
        uint256 count = 0;
        uint256 i;
        for (i=0; i<transactionCount; i++)
            if (   pending && !transactions[i].executed
                || executed && transactions[i].executed)
            {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint[](to - from);
        for (i=from; i<to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
    }
}