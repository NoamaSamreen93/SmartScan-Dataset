// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract IreneDAO is ERC721Enumerable, ReentrancyGuard, Ownable {
    constructor() ERC721("IreneDAO", "IRENEDAO") Ownable() {}

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function mint() public payable nonReentrant {
        uint256 latestId = totalSupply();
        _safeMint(_msgSender(), latestId);

        // Magic number :)
        require(totalSupply() < 1107, "Max mint amount");
    }

    function tokenURI(uint256 tokenId)
        public
        pure
        override
        returns (string memory)
    {
        // Deterministic yet random enough id
        uint256 pictureId = random(
            string(abi.encodePacked("TG STICKER PACK", Utils.toString(tokenId)))
        );
        pictureId = pictureId % 25;

        string memory name = string(
            abi.encodePacked("IreneDAO Pass #", Utils.toString(tokenId))
        );

        string[11] memory parts;
        parts[
            0
        ] = '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="512px" height="512px" viewBox="0 0 512 512"> <clipPath id="corners"> <rect width="512" height="512" rx="42" ry="42" /> </clipPath> <path id="text-path-a" fill="sandybrown" d="M40 12 H472 A28 28 0 0 1 500 40 V472 A28 28 0 0 1 472 500 H40 A28 28 0 0 1 12 472 V40 A28 28 0 0 1 40 12 z" /> <image href="https://gateway.pinata.cloud/ipfs/QmbRj3Qe2cNqisgaqZxd4xGEfpfbfrNUsQDEpFM57EarXE/';
        parts[1] = Utils.toString(pictureId);
        parts[
            2
        ] = '.png" width="500" height="500" /> <text text-rendering="optimizeSpeed" stroke="black"> <textPath startOffset="-100%" fill="white" font-family="\'Courier New\', monospace" font-size="12px" xlink:href="#text-path-a">';
        parts[3] = name;
        parts[
            4
        ] = '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" /> </textPath> <textPath startOffset="0%" fill="white" font-family="\'Courier New\', monospace" font-size="12px" xlink:href="#text-path-a">';
        parts[5] = name;
        parts[
            6
        ] = '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" /> </textPath> <textPath startOffset="50%" fill="white" font-family="\'Courier New\', monospace" font-size="12px" xlink:href="#text-path-a">';
        parts[7] = name;
        parts[
            8
        ] = '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" /> </textPath> <textPath startOffset="-50%" fill="white" font-family="\'Courier New\', monospace" font-size="12px" xlink:href="#text-path-a">';
        parts[9] = name;
        parts[
            10
        ] = '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" /> </textPath> </text> </svg>';

        string memory output = string(
            abi.encodePacked(
                parts[0],
                parts[1],
                parts[2],
                parts[3],
                parts[4],
                parts[5],
                parts[6],
                parts[7],
                parts[8]
            )
        );

        output = string(abi.encodePacked(output, parts[9], parts[10]));

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "IreneDAO Pass #',
                        Utils.toString(tokenId),
                        '", "description": "IreneDAO is a global grassroots movement aimed at disrupting the creator economy. IreneDAO is for the people, by the people. Our core values are: Sincerity, Integrity, Meaning, and Purpose.", "image_data": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)),
                        '"}'
                    )
                )
            )
        );

        output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }
}

library Utils {
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

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
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(input, 0x3F))), 0xFF)
                )
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