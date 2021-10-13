/**
 *Submitted for verification at Etherscan.io on 2020-03-01
*/

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

pragma solidity ^0.5.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of NFTs in `owner`'s account.
     */
    function balanceOf(address owner) public view returns (uint256 balance);

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) public view returns (address owner);

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     *
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either {approve} or {setApprovalForAll}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either {approve} or {setApprovalForAll}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

pragma solidity ^0.5.0;

contract MetaGlitchLegacyFlag{
    address ethereal;
    IERC721 MetaGlitchContract;
    mapping(uint => bool) metaGlitchIdIsLegacy;
    
    event LogLegacyFlag(uint metaGlitchId, bool isLegacy);
    
    
    constructor() public{
        ethereal = msg.sender;
        MetaGlitchContract = IERC721(address(0x4c9e324fD7Df8b2a969969bCC3663D74F058D286));
    }
    
    function setIsLegacy(uint metaGlitchId, bool isLegacy) public{
        require(MetaGlitchContract.ownerOf(metaGlitchId) == msg.sender,"Sender must own metaglitch.");
        metaGlitchIdIsLegacy[metaGlitchId] = isLegacy;
        emit LogLegacyFlag(metaGlitchId,isLegacy);
    }
    
    function onlyEthereal_setIsLegacy(uint metaGlitchId, bool isLegacy) public{
        require(ethereal == msg.sender,"Sender must be Ethereal.");
        metaGlitchIdIsLegacy[metaGlitchId] = isLegacy;
        emit LogLegacyFlag(metaGlitchId,isLegacy);
    }
    
}