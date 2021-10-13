{"DelegateProxy.sol":{"content":"pragma solidity ^0.4.18;\n\ncontract DelegateProxy {\n  /**\n  * @dev Performs a delegatecall and returns whatever the delegatecall returned (entire context execution will return!)\n  * @param _dst Destination address to perform the delegatecall\n  * @param _calldata Calldata for the delegatecall\n  */\n  function delegatedFwd(address _dst, bytes _calldata) internal {\n    require(isContract(_dst));\n    assembly {\n      let result := delegatecall(sub(gas, 10000), _dst, add(_calldata, 0x20), mload(_calldata), 0, 0)\n      let size := returndatasize\n\n      let ptr := mload(0x40)\n      returndatacopy(ptr, 0, size)\n\n    // revert instead of invalid() bc if the underlying call failed with invalid() it already wasted gas.\n    // if the call returned error data, forward it\n      switch result case 0 {revert(ptr, size)}\n      default {return (ptr, size)}\n    }\n  }\n\n  function isContract(address _target) internal view returns (bool) {\n    uint256 size;\n    assembly {size := extcodesize(_target)}\n    return size \u003e 0;\n  }\n}"},"DSAuth.sol":{"content":"// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU General Public License for more details.\n\n// You should have received a copy of the GNU General Public License\n// along with this program.  If not, see \u003chttp://www.gnu.org/licenses/\u003e.\n\npragma solidity ^0.4.13;\n\ncontract DSAuthority {\n  function canCall(\n    address src, address dst, bytes4 sig\n  ) public view returns (bool);\n}\n\ncontract DSAuthEvents {\n  event LogSetAuthority (address indexed authority);\n  event LogSetOwner     (address indexed owner);\n}\n\ncontract DSAuth is DSAuthEvents {\n  DSAuthority  public  authority;\n  address      public  owner;\n\n  function DSAuth() public {\n    owner = msg.sender;\n    LogSetOwner(msg.sender);\n  }\n\n  function setOwner(address owner_)\n  public\n  auth\n  {\n    owner = owner_;\n    LogSetOwner(owner);\n  }\n\n  function setAuthority(DSAuthority authority_)\n  public\n  auth\n  {\n    authority = authority_;\n    LogSetAuthority(authority);\n  }\n\n  modifier auth {\n    require(isAuthorized(msg.sender, msg.sig));\n    _;\n  }\n\n  function isAuthorized(address src, bytes4 sig) internal view returns (bool) {\n    if (src == address(this)) {\n      return true;\n    } else if (src == owner) {\n      return true;\n    } else if (authority == DSAuthority(0)) {\n      return false;\n    } else {\n      return authority.canCall(src, this, sig);\n    }\n  }\n}\n"},"MutableForwarder.sol":{"content":"pragma solidity ^0.4.18;\n\nimport \"./DelegateProxy.sol\";\nimport \"./DSAuth.sol\";\n\n/**\n * @title Forwarder proxy contract with editable target\n *\n * @dev For TCR Registry contracts (Registry.sol, ParamChangeRegistry.sol) we use mutable forwarders instead of using\n * contracts directly. This is for better upgradeability. Since registry contracts fire all events related to registry\n * entries, we want to be able to access whole history of events always on the same address. Which would be address of\n * a MutableForwarder. When a registry contract is replaced with updated one, mutable forwarder just replaces target\n * and all events stay still accessible on the same address.\n */\n\ncontract MutableForwarder is DelegateProxy, DSAuth {\n\n  address public target = 0xf4e6e033921b34f89b0586beb2d529e8eae3e021; // checksumed to silence warning\n\n  /**\n   * @dev Replaces targer forwarder contract is pointing to\n   * Only authenticated user can replace target\n\n   * @param _target New target to proxy into\n  */\n  function setTarget(address _target) public auth {\n    target = _target;\n  }\n\n  function() payable {\n    delegatedFwd(target, msg.data);\n  }\n\n}"}}