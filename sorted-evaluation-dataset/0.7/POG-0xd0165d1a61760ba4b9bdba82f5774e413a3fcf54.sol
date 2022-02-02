// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract POG is ERC20, Ownable {
    address private _communityWallet;
    address private _marketingWallet;
    
    constructor(uint256 initialSupply) ERC20("Pot Of Gold", "POG") {
        _mint(msg.sender, initialSupply);
        _setCommunityWallet(_msgSender());
        _setMarketingWallet(_msgSender());
    }

    struct Transaction {
        address sender;
        address recipient;
        address marketingWallet;
        address communityWallet;
    }
    Transaction private transaction;

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override { //overrides the inherited ERC20 _transfer
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
        //load transaction Struct (gets info from external contracts)
        updateTxStruct(sender, recipient);

        // Cuts are 0.0X% ie base 10000 -> "10" = 0.1%
        uint _toMarketing = SafeMath.div(SafeMath.mul(amount,200),10000); 
        uint _toCommunity = SafeMath.div(SafeMath.mul(amount,300),10000); 
        uint _amount = SafeMath.sub(amount, SafeMath.add(_toMarketing,_toCommunity)); //calculates the remaning amount to be sent

    
        if(_toMarketing > 0) {
        ERC20._transfer(sender, transaction.marketingWallet, _toMarketing); //native _transfer + emit
        } 

        if(_toCommunity > 0) {
        ERC20._transfer(sender, transaction.communityWallet, _toCommunity); //native _transfer + emit
        } 

        //transfer remaining amount. + emit
        ERC20._transfer(sender, recipient, _amount); //native _transfer + emit
    }

    function updateTxStruct(address sender, address recipient) internal returns(bool){
        transaction.sender = sender;
        transaction.recipient = recipient;
        transaction.marketingWallet = marketingWallet();
        transaction.communityWallet = communityWallet();
        return true;
    } // struct used to prevent "stack too deep" error

    function setCommunityWallet(address newWallet) public virtual onlyOwner {
        require(newWallet != address(0), "New wallet can't be the zero address");
        _setCommunityWallet(newWallet);
    }
    
    function setMarketingWallet(address newWallet) public virtual onlyOwner {
        require(newWallet != address(0), "New wallet can't be the zero address");
        _setMarketingWallet(newWallet);
    }

    function _setCommunityWallet(address newComW) private {
        _communityWallet = newComW;
    }
    function _setMarketingWallet(address newMarW) private {
        _marketingWallet = newMarW;
    }

  
    function communityWallet() public view virtual returns (address) {
        return _communityWallet;
    }
  
    function marketingWallet() public view virtual returns (address) {
        return _marketingWallet;
    }
}