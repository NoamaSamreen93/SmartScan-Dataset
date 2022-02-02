// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

/**
 * The NFT Worlds Server Router contract provides
 * a decentralized layer to set a JSON blob stored
 * on IPFS that conforms to the NFT Worlds routing
 * standards.
 *
 * This provides a decentralized way for
 * NFT World server connection details and other
 * relevant world information to be set, queried
 * and distributed.
 *
 */

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract NFT_Worlds_Server_Router is AccessControl {
  using EnumerableSet for EnumerableSet.UintSet;

  event WorldRoutingDataSet(uint256 worldTokenId, string ipfsHash);
  event WorldRoutingDataRemoved(uint256 worldTokenId);

  IERC721 immutable NFTW_ERC721;
  EnumerableSet.UintSet private routedWorldsSet;
  mapping(uint => string) public routedWorldIPFSHash;
  string public convenienceGateway;
  bytes32 private constant OWNER_ROLE = keccak256("OWNER_ROLE");
  bytes32 private constant RENTAL_MANAGER_ROLE = keccak256("RENTAL_MANAGER_ROLE");

  constructor(address _nftWorldsErc721, string memory _convenienceGateway) {
    require(_nftWorldsErc721 != address(0), "Addr 0");
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(OWNER_ROLE, msg.sender);
    convenienceGateway = _convenienceGateway;
    NFTW_ERC721 = IERC721(_nftWorldsErc721);
  }

  function getRoutingDataURI(uint _worldTokenId, bool includeGateway) public view returns (string memory) {
    require(routedWorldsSet.contains(_worldTokenId), "No routing data");

    if (includeGateway) {
      return string(abi.encodePacked(convenienceGateway, routedWorldIPFSHash[_worldTokenId]));
    }

    return string(abi.encodePacked("ipfs://", routedWorldIPFSHash[_worldTokenId]));
  }

  function getAllRoutings(bool includeGateway) external view returns (uint[] memory, string[] memory) {
    uint totalRoutedWorlds = routedWorldsSet.length();
    uint[] memory routingWorldIds = new uint[](totalRoutedWorlds);
    string[] memory routingDataURIs = new string[](totalRoutedWorlds);

    for (uint i = 0; i < totalRoutedWorlds; i++) {
      uint worldId = routedWorldsSet.at(i);
      routingWorldIds[i] = worldId;
      routingDataURIs[i] = getRoutingDataURI(worldId, includeGateway);
    }

    return (routingWorldIds, routingDataURIs);
  }

  function setRoutingDataIPFSHash(uint _worldTokenId, string calldata _ipfsHash) onlyWorldController(_worldTokenId) external {
    require(bytes(_ipfsHash).length == 46, "Invalid IPFS hash");

    routedWorldsSet.add(_worldTokenId);
    routedWorldIPFSHash[_worldTokenId] = _ipfsHash;

    emit WorldRoutingDataSet(_worldTokenId, _ipfsHash);
  }

  function removeRoutingDataIPFSHash(uint _worldTokenId) onlyWorldController(_worldTokenId) external {
    routedWorldsSet.remove(_worldTokenId);
    routedWorldIPFSHash[_worldTokenId] = "";

    emit WorldRoutingDataRemoved(_worldTokenId);
  }

  function setConvenienceGateway(string calldata _convenienceGateway) external onlyRole(OWNER_ROLE) {
    convenienceGateway = _convenienceGateway;
  }

  /**
   * Modifiers
   */

  modifier onlyWorldController(uint _worldTokenId) {
    if (!hasRole(RENTAL_MANAGER_ROLE, msg.sender)) {
      require(NFTW_ERC721.ownerOf(_worldTokenId) == msg.sender, "Not world owner");
    }

    _;
  }
}