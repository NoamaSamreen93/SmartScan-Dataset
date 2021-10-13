/**
 *Submitted for verification at Etherscan.io on 2020-02-19
*/

pragma solidity ^0.4.18;
// ----------------------------------------------------------------------------
// 'MyBasket' token contract
//
// Deployed to : 0x8fF28A4cB40aCaDe2077443b565E96FF485e867F
// Symbol      : MBT
// Name        : MyBasketToke
// Total supply: 246000000
// Decimals    : 2
//
// Enjoy.
//
// (c) by Blackmore Toporowski/ SMOM Inc Toronto Canada
/* REAL ASSET TOKEN CONTRACT
Description Reference information
Basket of 6 properties https:lldrive.google.pom/drive/folders/1Xj206SYw90QdCVY5H3zNsaMlf3Mep8QA
Address of property https:lldrive.google.~om/drive/folders/1Xj206SYw90QdCVY5H3zNsaMlf3Mep8QA
Net Annual Income i 80,000 USD ____________________________________________________________________________________________________________________________ ---..1-------------------------------------------------- _____________________________ .
Proof of Title https:lldrive.google.pom/drive/folders/1 Xj206SYw90QdCVY5H3zNsaMlf3Mep8QA
Insurance certificate ! not applicable
Owner(s) Klaus peter Kripgans, Legienstr. 16, 65929 Frankfurt, Germany
Purchase price 2,015,000 USD
---------------- ----------------------------------------------------------------------------------------------------------------:-----------------------------------------------------------------------------_.
Date of purchase 2018 - 2019
Current Value i . 2.460.000 USD
Property appraisal certificate https:lldrive.google.~om/drive/folders/1 Xj206SYw90QdCVY5H3zNsaMlf3Mep8QA
Owners social media profile ! Linkedln
---------------- ---------------------------------------------------------------------------------------------------------------.,-----------------------------------------------------------------------------_.
Notarization certificate https:lldrive.google.pom/drive/folders/1 Xj206SYw90QdCVY5H3zNsaMlf3Mep8QA
Token name i MyBasketToken
Token value i each token represents 0.000041 % of the value
---------------- ---------------------------------------------------------------------------------------------------------------~-----------------------------------------------------------------------------_.
Initial token price ! 200 token = 1 ETH
Total token distribution ! 246000000
Dividends i Not applicable
_______________________________________________________________________________________________________________________________ .J _______________________________________________________________________________ .
Voting Rights ! Not applicable
...................D..a..t.e.. ..................................................................................· ·········:i· ·F·e·b·r·u·a·ry· ·5·th· ·2·0·2t0[ .J·7 ·.. ......................... .
Owne"s) s;gnatuce : ~ ~ y T
*/

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract MyBasketToken is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function Constructor() public {
        symbol = "MBT";
        name = "MyBasketToken";
        decimals = 2;
        _totalSupply = 246000000;
        balances[0x8fF28A4cB40aCaDe2077443b565E96FF485e867F] = _totalSupply;
        Transfer(address(0), 0x8fF28A4cB40aCaDe2077443b565E96FF485e867F , _totalSupply);
    }


    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply  - balances[address(0)];
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account tokenOwner
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to to account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces 
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer tokens from the from account to the to account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the from account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account. The spender contract function
    // receiveApproval(...) is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}