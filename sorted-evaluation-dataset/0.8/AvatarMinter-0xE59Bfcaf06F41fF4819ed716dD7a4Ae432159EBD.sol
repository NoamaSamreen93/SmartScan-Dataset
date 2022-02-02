// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ContextMixin} from "../common/ContextMixin.sol";
import {IMintableERC721} from "../common/IMintableERC721.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract AvatarMinter is Ownable, ContextMixin {
    using MerkleProof for bytes32[];

    mapping(uint256 => bool) public isMinted;

    IMintableERC721 public netvrkAvatar;

    bytes32 merkleRoot;

    event AvatarMinted(
        address indexed minter,
        uint256 tokenId
    );

    constructor(address avatarAddress) {
        netvrkAvatar = IMintableERC721(avatarAddress);
    }

    function setMerkleRoot(bytes32 root) onlyOwner external {
        merkleRoot = root;
    }

    function redeemAvatar(uint256 tokenId, bytes32[] memory proof) public {
        require(merkleRoot != 0, "AvatarMinter: no MerkleRoot yet");
        require(isMinted[tokenId] == false, "AvatarMinter: Already Minted");
        require(proof.verify(merkleRoot, keccak256(abi.encodePacked(msg.sender, tokenId))), "AvatarMinter: Not Allocated");

        address minter = msg.sender;

        isMinted[tokenId] = true;

        netvrkAvatar.mint(minter, tokenId);
        emit AvatarMinted(minter, tokenId);
    }

    function batchRedeemAvatars(uint256[] calldata tokenIds, bytes32[][] memory proofs) public {
        uint256 tokenId;        
        address minter = msg.sender;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            require(proofs[i].verify(merkleRoot, keccak256(abi.encodePacked(minter,tokenId))), "AvatarMinter: Not Allocated");
            require(isMinted[tokenId] == false, "AvatarMinter: Already Minted");
            isMinted[tokenId] = true;
            netvrkAvatar.mint(minter, tokenId);
            emit AvatarMinted(minter, tokenId);
        }
    }

    function _updateAddresses(address avatarAddress)
        external
        onlyOwner
    {
        netvrkAvatar = IMintableERC721(avatarAddress);
    }
}