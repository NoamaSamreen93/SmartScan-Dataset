// SPDX-License-Identifier: UNLICENSE

pragma solidity >=0.8.0;

import "./base64.sol";
import "./DynamicBuffer.sol";
import '@openzeppelin/contracts/utils/Strings.sol';


contract Renderer{
    
    
    function render(address addressToRender) public view returns (string memory renderedContract) {
        // initialize all variables
        bytes memory bytecode; // bytes to contain the contract's bytecode
        (, bytes memory uri) = DynamicBuffer.allocate(2**16); // allocate the full size of the bytes URI
        // for efficiency purposes we force the BMP size to 56 and thus exclude part of the contract code.

        bytes18 header = bytes18(0x424D7C000000000000001A0000000C000000); // standard BMP header

        bytecode = _getContractBytecode(addressToRender); // get the code running on the blockchain

        // prepare the BMP and embed it inside an SVG (so that marketplaces can render it)
        DynamicBuffer.appendBytes(
            uri,
            abi.encodePacked(
                "<?xml version='1.0' encoding='UTF-8'?><svg version='1.1' viewBox='0 0 56 56' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'><image style='image-rendering:crisp-edges;image-rendering:pixelated' xlink:href='data:image/bmp;base64,",
                Base64.encode(bytes.concat(header,bytes2(uint16(56))<<8,bytes2(uint16(56))<<8,bytes4(0x01001800),bytecode,bytes2(0))),"'/></svg>")
            );

        return string(Base64.encode(uri));
    }

      function _getContractBytecode(address _addr) public view returns (bytes memory o_code) {
        assembly {
            // allocate output byte array - this could also be done without assembly
            // by using o_code = new bytes(size)
            o_code := mload(0x40)
            // new "memory end" including padding
            mstore(0x40, add(o_code, and(add(add(9408, 0x20), 0x1f), not(0x1f))))
            // store length in memory
            mstore(o_code, 9408)
            // actually retrieve the code, this needs assembly
            extcodecopy(_addr, add(o_code, 0x20), 0, 9408)
        }
    }


    function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

}