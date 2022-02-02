pragma solidity ^0.8.7;

/*
    _____ _____  _____  ______ _     __   __
   / ____|  __ \|  __ \|  ____| |    \ \ / /
  | (___ | |__) | |__) | |__  | |     \ V / 
   \___ \|  ___/|  _  /|  __| | |      > <  
   ____) | |    | | \ \| |    | |____ / . \ 
  |_____/|_|    |_|  \_\_|    |______/_/ \_\

 Sup Ma!

 Developed by @mfer4198
 Original artwork by Jon who is not on twitter.
*/

import "ERC721.sol";
import "Ownable.sol";

contract SPRFLX is ERC721, Ownable {
    uint256 public tokenCounter;
    address payable private immutable shareholderAddress;

    struct Style {
        string name;
        uint256 price;
        string imageURI;
        string description;
        string attributes;
    }

    // tokenId to issuedName
    mapping(uint256 => string) private issuedNames;

    // tokenId to style
    mapping(uint256 => uint256) private issuedStyle;

    // styleId to style
    mapping(uint256 => Style) private styles;

    constructor(address payable _shareholderAddress) public ERC721("SPRFLX", "SPRFLX") {
        tokenCounter = 0;
        require(_shareholderAddress != address(0));
        shareholderAddress = _shareholderAddress;
        
        styles[0] = Style(
            "Original",
            0.069 ether,
            "ipfs://QmeFiSW2o1gW9JoZZJ5TYczEMmVErawYP7ssasYTPo6ZLd",
            "The one and only SPRFLX Original. Handcrafted for you to flex in the metaverse.",
            '[{"trait_type": "Type", "value": "Trophy"}, {"trait_type": "Style", "value": "Original"},'
            ' {"trait_type": "Awesomeness", "value": 100}]'
        );

    }

    function mint(uint256 styleId, string memory name)
        public
        payable
        returns (uint256)
    {
        Style memory style = styles[styleId];

        require(
            msg.value >= style.price,
            "ERC721: insufficient transaction value"
        );

        uint256 newItemId = tokenCounter;
        _safeMint(msg.sender, newItemId);

        issuedNames[newItemId] = name;
        issuedStyle[newItemId] = styleId;

        tokenCounter = tokenCounter + 1;
        return newItemId;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        Address.sendValue(shareholderAddress, balance);
    }

    function setStyle(
        uint256 styleId, string memory name, uint256 price,
        string memory imageURL, string memory description,
        string memory attributes
    ) public onlyOwner {
        styles[styleId] = Style(name, price, imageURL, description, attributes);
    }

    function getStyle(uint256 styleId) public onlyOwner view returns(Style memory) {
        return styles[styleId];
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        Style memory style = styles[issuedStyle[tokenId]];
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "', issuedNames[tokenId],'", "attributes":', style.attributes,', "description": "', style.description,'", "external_url": "https://sprflx.io", "image": "', style.imageURI, '"}'))));
        return string(abi.encodePacked('data:application/json;base64,', json));
    }

    function contractURI() public view returns (string memory) {
        return "https://sprflx.io/static/contract/contract-metadata.json";
    }
}

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}