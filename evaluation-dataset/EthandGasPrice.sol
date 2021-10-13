/**
 *Submitted for verification at Etherscan.io on 2020-02-19
*/

pragma solidity ^0.5.16;

interface USDContract{
    function primary() external view returns (address payable);
    function pricerAddress() external view returns (address);
}

contract Updateable{
    
    address payable private USDcontractAddress = 0xD2d01dd6Aa7a2F5228c7c17298905A7C7E1dfE81;
      
    modifier onlyUpdater() {
        require(msg.sender == USDContract(USDcontractAddress).pricerAddress() || msg.sender == primary(), "Only Admin can call this");
        _;
    }
     
    function updateUSDcontractAddress(address payable _USDcontractAddress) public {
        require(msg.sender == primary(), "Secondary: caller is not the primary account");
        require(msg.sender == USDContract(_USDcontractAddress).primary(), "Input's primary account wasn't you");
         
        require(_USDcontractAddress != address(this), "Input was this contracts address");
        require(_USDcontractAddress != msg.sender, "Input was your address");
        require(_USDcontractAddress != address(0), "Input was zero");
        
        USDcontractAddress = _USDcontractAddress;
    }
    
    function primary() internal view returns (address payable) {
        return USDContract(USDcontractAddress).primary();
    }
    
    modifier onlyPrimary() {
        require(msg.sender == primary(), "Secondary: caller is not the primary account");
        _;
    }
    
}

interface token {
    function balanceOf(address input) external returns (uint256);
    function transfer(address input, uint amount) external;
}

contract EthandGasPrice is Updateable {
    
    uint private _ethPrice;
    uint private _safeLow;
    uint private _standard;
    uint private _fast;
    uint private _fastest;
    uint private _time;
    
    function ethPrice() public view returns (uint){return _ethPrice;}
    function safeLow() public view returns (uint){return _safeLow;}
    function standard() public view returns (uint){return _standard;}
    function fast() public view returns (uint){return _fast;}
    function fastest() public view returns (uint){return _fastest;}
    function time() public view returns (uint){return _time;}
    
    function update(uint ethPriceInput, uint safeLowInput, uint standardInput, uint fastInput, uint fastestInput, uint timeInput) public onlyUpdater{
        
        _ethPrice = ethPriceInput;
        _safeLow = safeLowInput;
        _standard = standardInput;
        _fast = fastInput;
        _fastest = fastestInput;
        _time = timeInput;
    }
    
    function () external payable {
        primary().transfer(address(this).balance);
    }
    
    function getStuckTokens(address _tokenAddress) public {
        token(_tokenAddress).transfer(primary(), token(_tokenAddress).balanceOf(address(this)));
    }

}