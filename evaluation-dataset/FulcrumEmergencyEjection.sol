/**
 *Submitted for verification at Etherscan.io on 2020-02-18
*/

pragma solidity ^0.5.16;

contract Erc20 {
    function balanceOf(address owner) view external returns(uint256);
    function transferFrom(address from, address to, uint256 value) external returns(bool);
}

contract iErc20 is Erc20 {
    function tokenPrice() view external returns(uint256);
    function burnToEther(address receiver, uint256 burnAmount) external returns(uint256); 
}

contract FulcrumEmergencyEjection {
    Erc20 constant wEth = Erc20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    iErc20 constant iEth = iErc20(0x77f973FCaF871459aa58cd81881Ce453759281bC);

    function corona(uint256 dustAmount, uint256 userBalance) external returns(uint256 outAmount) {
        uint256 wEthAmount = wEth.balanceOf(0x77f973FCaF871459aa58cd81881Ce453759281bC);
        if (wEthAmount > dustAmount) {
            uint256 iEthTokenPrice = iEth.tokenPrice();
            uint256 availableBurnAmount = wEthAmount / iEthTokenPrice;
            availableBurnAmount = userBalance < availableBurnAmount ? userBalance : availableBurnAmount;
            iEth.transferFrom(msg.sender, address(this), availableBurnAmount);
            return iEth.burnToEther(msg.sender, availableBurnAmount);
        }
        return 0;
    }
}