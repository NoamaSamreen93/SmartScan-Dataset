// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "../BaseContracts/BaseVesting.sol";

contract LunrCrush  is BaseVesting{
    constructor(
        address signer_,
        address token_,
        uint256 startDate_,
        uint256 vestingDuration_,
        uint256 totalAllocatedAmount_
    )
        BaseVesting(
            signer_,
            token_,
            startDate_,
            vestingDuration_,
            totalAllocatedAmount_
        )
    {}
}