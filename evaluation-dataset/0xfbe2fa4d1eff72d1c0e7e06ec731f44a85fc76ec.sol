pragma solidity ^0.4.10;

contract Token {
    uint256 public totalSupply;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        require(balanceOf[msg.sender] >= _value);            // Check if the sender has enough
        require(balanceOf[_to] + _value >= balanceOf[_to]);  // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        require(balanceOf[_from] >= _value);                 // Check if the sender has enough
        require(balanceOf[_to] + _value >= balanceOf[_to]);  // Check for overflows
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        balanceOf[_from] -= _value;                          // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    uint public id; /* To ensure distinct contracts for different tokens owned by the same owner */
    address public owner;
    bool public sealed = false;

    function Token(uint _id) {
        owner = msg.sender;
        id = _id;
    }

    /* Allows the owner to mint more tokens */
    function mint(address _to, uint256 _value) returns (bool) {
        require(msg.sender == owner);                        // Only the owner is allowed to mint
        require(!sealed);                                    // Can only mint while unsealed
        require(balanceOf[_to] + _value >= balanceOf[_to]);  // Check for overflows
        balanceOf[_to] += _value;
        totalSupply += _value;
        return true;
    }

    function seal() {
        require(msg.sender == owner);
        sealed = true;
    }
}

contract Withdraw {
    Token public token;

    function Withdraw(Token _token) {
        token = _token;
    }

    function () payable {}

    function withdraw() {
        require(token.sealed());
        require(token.balanceOf(msg.sender) > 0);
        uint token_amount = token.balanceOf(msg.sender);
        uint wei_amount = this.balance * token_amount / token.totalSupply();
        if (!token.transferFrom(msg.sender, this, token_amount) || !msg.sender.send(wei_amount)) {
            throw;
        }
    }
}

contract TokenGame {
    address public owner;
    uint public cap_in_wei;
    uint constant initial_duration = 1 hours;
    uint constant time_extension_from_doubling = 1 hours;
    uint constant time_of_half_decay = 1 hours;
    Token public excess_token; /* Token contract used to receive excess after the sale */
    Withdraw public excess_withdraw;  /* Withdraw contract distributing the excess */
    Token public game_token;   /* Token contract used to receive prizes */
    uint public end_time;      /* Current end time */
    uint last_time = 0;        /* Timestamp of the latest contribution */
    uint256 ema = 0;           /* Current value of the EMA */
    uint public total_wei_given = 0;  /* Total amount of wei given via fallback function */

    function TokenGame(uint _cap_in_wei) {
        owner = msg.sender;
        cap_in_wei = _cap_in_wei;
        excess_token = new Token(1);
        excess_withdraw = new Withdraw(excess_token);
        game_token = new Token(2);
        end_time = now + initial_duration;
    }

    function play() payable {
        require(now <= end_time);   // Check that the sale has not ended
        require(msg.value > 0);     // Check that something has been sent
        total_wei_given += msg.value;
        ema = msg.value + ema * time_of_half_decay / (time_of_half_decay + (now - last_time) );
        last_time = now;
        uint extended_time = now + ema * time_extension_from_doubling / total_wei_given;
        if (extended_time > end_time) {
            end_time = extended_time;
        }
        if (!excess_token.mint(msg.sender, msg.value) || !game_token.mint(msg.sender, msg.value)) {
            throw;
        }
    }

    function finalise() {
        require(now > end_time);
        excess_token.seal();
        game_token.seal();
        uint to_owner = 0;
        if (this.balance > cap_in_wei) {
            to_owner = cap_in_wei;
            if (!excess_withdraw.send(this.balance - cap_in_wei)) {
                throw;
            }
        } else {
            to_owner = this.balance;
        }
        if (to_owner > 0) {
            if (!owner.send(to_owner)) {
                throw;
            }
        }
    }
}

contract ZeroCap is TokenGame {
    Withdraw public game_withdraw;

    function ZeroCap() TokenGame(0) {
        game_withdraw = new Withdraw(game_token);
    }
}
pragma solidity ^0.3.0;
	 contract IQNSecondPreICO is Ownable {
    uint256 public constant EXCHANGE_RATE = 550;
    uint256 public constant START = 1515402000; 
    uint256 availableTokens;
    address addressToSendEthereum;
    address addressToSendTokenAfterIco;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function IQNSecondPreICO (
        address addressOfTokenUsedAsReward,
       address _addressToSendEthereum,
        address _addressToSendTokenAfterIco
    ) public {
        availableTokens = 800000 * 10 ** 18;
        addressToSendEthereum = _addressToSendEthereum;
        addressToSendTokenAfterIco = _addressToSendTokenAfterIco;
        deadline = START + 7 days;
        tokenReward = token(addressOfTokenUsedAsReward);
    }
    function () public payable {
        require(now < deadline && now >= START);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        availableTokens -= amount;
        tokenReward.transfer(msg.sender, amount * EXCHANGE_RATE);
        addressToSendEthereum.transfer(amount);
    }
 }
