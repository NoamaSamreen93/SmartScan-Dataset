// contracts/Fantasy3k1155.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC1155.sol";
import "./access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract Fantasy3K1155 is ERC1155, Ownable, Pausable {
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint256 private _nextTokenId = 1;

    event MintBlindBox(address to, uint256 amountToMint);

    constructor(string memory _url) ERC1155(_url) {
        name = "Fantasy3K Box";
        symbol = "F3KBOX";
    }
    
    struct BoxIdx {
        uint256 _start;
        uint256 _end;
        uint256 _height;
    }
    mapping (uint256 => BoxIdx) boxIdxs;

    // Mint function
    function mint(address to, uint256 amountToMint) public onlyAdmin {

        uint256 amount = amountToMint;
        require(amount > 0, "Fantasy3k: invalid count");
        _mint(to, _nextTokenId, amount, "");
        _nextTokenId++;
        emit MintBlindBox(to, amountToMint);
    }
    
    function burnToken(address account, uint256 id, uint256 value) public {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()) || msg.sender == admin(),
            "ERC1155: caller is not owner nor approved"
        );
        _burn(account, id, value);
    }

    function nextTokenId() public view returns (uint256) {
        return _nextTokenId;
    }

    function pauseContract() external onlyOwner {
        _pause();
    }

    function unpauseContract() external onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        require(!paused(), "ERC1155Pausable: token transfer while paused");
    }

    function setURI(string memory newuri) external onlyOwner {
        _setURI(newuri);
    }
}