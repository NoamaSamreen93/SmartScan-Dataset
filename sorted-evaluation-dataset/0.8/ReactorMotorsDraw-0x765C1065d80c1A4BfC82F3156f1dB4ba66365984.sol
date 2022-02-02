// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@divergencetech/ethier/contracts/random/PRNG.sol";
import "@divergencetech/ethier/contracts/thirdparty/chainlink/VRFConsumerHelper.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @notice Selects the winning token of the Reactor Motors draw.
contract ReactorMotorsDraw is Ownable, VRFConsumerHelper {
    using PRNG for PRNG.Source;

    /// @notice Values associated with Chainlink VRF.
    bytes32 public requestId;
    uint256 public randomness;

    /**
    @notice Total number of tokens from which to draw.
    @dev Although production is 8888, this is variable to allow for testing.
     */
    uint256 private immutable NUM_TOKENS;

    constructor(uint256 numTokens) {
        NUM_TOKENS = numTokens;
    }

    /// @notice Performs the draw, requesting verifiable entropy from Chainlink.
    function draw() external onlyOwner {
        require(uint256(requestId) == 0, "Already drawn");
        requestId = VRFConsumerHelper.requestRandomness();
    }

    /// @notice Accepts entropy from Chainlink VRF.
    function fulfillRandomness(bytes32 _requestId, uint256 _randomness)
        internal
        override
    {
        require(requestId == _requestId, "Incorrect request ID");
        randomness = _randomness;
    }

    /**
    @notice Returns the winning tokenId.
    @dev Deliberately does NOT return the winning address as this can change
    with time.
     */
    function winningTokenId() external view returns (uint256) {
        require(uint256(requestId) > 0 && randomness > 0, "Not drawn yet");

        PRNG.Source src = PRNG.newSource(
            keccak256(abi.encodePacked(randomness))
        );
        // Tokens are 1-indexed.
        return src.readLessThan(NUM_TOKENS) + 1;
    }

    /// @notice Transfers LINK held by the contract.
    function withdrawLINK(address recipient, uint256 amount)
        external
        onlyOwner
    {
        _withdrawLINK(recipient, amount);
    }
}