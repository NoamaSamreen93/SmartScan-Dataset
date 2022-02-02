// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@1001-digital/erc721-extensions/contracts/WithContractMetaData.sol";
import "@1001-digital/erc721-extensions/contracts/WithIPFSMetaData.sol";
import "@1001-digital/erc721-extensions/contracts/WithWithdrawals.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@%#*++===--===++*#%@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@%*+------===++===------=*%@@@@@@@@@@@@
// @@@@@@@@@@*=---=+*#%@@@@@@@@@@%#*+=---=*@@@@@@@@@@
// @@@@@@@@*---=*%@@@@@@@@@@@@@@@@@@@@#+=---*@@@@@@@@
// @@@@@@#--==#@@@@@@@@@@@@@@@@@@@@@@@@@@#==--#@@@@@@
// @@@@@+-==*@@%%############*********++++=-==-+@@@@@
// @@@@===+#@#+++================----:::::-*#===+@@@@
// @@@+=++%@@#==============--------------=@@#===*@@@
// @@#-++#@@@@@@@@@@@@@@++***#@@@@@@@@@@@@@@@@*+++%@@
// @@==++@@@@@@@@@@@@@@%:****#@@@@@@@@@@@@@@@@@=++*@@
// @@-+**@@@@@@@@@@@@@@-:****@@@@@@@@@@@@@@@@@@+++*@@
// @@-+*#@@@@@@@@@@@@@% -***%@@@@@@@@@@@@@@@@@@++**@@
// @@-+**@@@@@@@@@@@@@- -***@@@@@@@@@@@@@@@@@@@++**@@
// @@=+**@@@@@@@@@@@@%  -**%@@@@@@@@@@@@@@@@@@@=**#@@
// @@#=***@@@@@@@@@@@-  =*#@@@@@@@@@@@@@@@@@@@++**@@@
// @@@++**#@@@@@@@@@%   =*%@@@@@@@@@@@@@@@@@@#+**#@@@
// @@@@=+**#@@@@@@@@=   =#@@@@@@@@@@@@@@@@@@*+**#@@@@
// @@@@@++***%@@@@@%.   =%@@@@@@@@@@@@@@@@%++**#@@@@@
// @@@@@@#=+**#%@@@#:   +@@@@@@@@@@@@@@@%*+***%@@@@@@
// @@@@@@@@*=+***#@@#=-:#@@@@@@@@@@@@%#*++++*@@@@@@@@
// @@@@@@@@@@*=++***##%%@@@@@@@@%%#*++++++#@@@@@@@@@@
// @@@@@@@@@@@@%*+=+++**++++++++++++==+*%@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@%#*+==========+*#%@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//
//      _____  ____    ___   _   _  ___  ____
//      |_   _||  _ \  / _ \ | \ | ||_ _|/ ___|
//       | |  | |_) || | | ||  \| | | || |
//       | |  |  _ < | |_| || |\  | | || |___
//       |_|  |_| \_\ \___/ |_| \_||___|\____|
//       ____      _    ____ ___ _   _  ____
//       |  _ \    / \  / ___|_ _| \ | |/ ___|
//       | |_) |  / _ \| |    | ||  \| | |  _
//       |  _ <  / ___ \ |___ | || |\  | |_| |
//       |_| \_\/_/   \_\____|___|_| \_|\____|
//
// ================================================
//          5,555 3D toy cars ready to race!
//    Race with us! https://discord.gg/A4sFesmFUq
// ================================================

// @author c0

// @dev shoutouts:
// - Jonathan Snow and Tom Hirst: https://shiny.mirror.xyz/OUampBbIz9ebEicfGnQf5At_ReMHlZy0tB4glb9xQ0E
// - Chance: https://nftchance.medium.com/the-gas-efficient-way-of-building-and-launching-an-erc721-nft-project-for-2022-b3b1dac5f2e1

contract TronicRacer is ERC721, Ownable, WithIPFSMetaData, WithContractMetaData, WithWithdrawals {
    using Counters for Counters.Counter;
    Counters.Counter private _nextTokenId;

    uint256 public constant MAX_SUPPLY = 5555;
    uint256 public constant MAX_PER_MINT = 5;
    uint256 public constant PRICE = 0.05 ether;

    uint256 public constant RESERVES = 55;
    bool public reservesCollected = false;

    string public constant PROVENANCE = "32a2edee8d3fb4a1e2f606504bc39a9ee03e0379aba7a420c5a48281911ad423";

    // In seconds. Note: subtract 1 second to reduce gas when comparing
    uint256 public miniRacerSaleStartTimestamp = 0;
    uint256 public whitelistSaleStartTimestamp = 0;
    uint256 public saleStartTimestamp = 0;

    address public miniRacerContractAddress;
    mapping(uint256 => uint256) private redeemedMiniRacers;

    address public proxyRegistryAddress;
    mapping(address => bool) public projectProxy;

    bytes32 public whitelistMerkleRoot;

    constructor(
        string memory _cid,
        string memory _contractMetaDataURI,
        address _miniRacerContractAddress,
        address _proxyRegistryAddress,
        uint256 _miniRacerSaleStartTimestamp,
        uint256 _whitelistSaleStartTimestamp,
        uint256 _saleStartTimestamp
    ) ERC721("TronicRacer", "TRONICRACER") WithIPFSMetaData(_cid) WithContractMetaData(_contractMetaDataURI) {
        miniRacerContractAddress = _miniRacerContractAddress;
        proxyRegistryAddress = _proxyRegistryAddress;
        miniRacerSaleStartTimestamp = _miniRacerSaleStartTimestamp;
        whitelistSaleStartTimestamp = _whitelistSaleStartTimestamp;
        saleStartTimestamp = _saleStartTimestamp;
        _nextTokenId.increment(); // Start IDs at 1
    }

    function mint(uint256 amount) external payable {
        require(saleStarted(), "Sale has not started");

        require(totalSupply() + amount <= MAX_SUPPLY, "Racers are sold out!");
        require(amount > 0, "You must mint at least one.");

        require(msg.value == PRICE * amount, "Too little or too much ETH sent");
        require(amount <= MAX_PER_MINT, "Maximum of 5 per transaction");

        for (uint256 index = 0; index < amount; index++) {
            _mintAndIncrement();
        }
    }

    // Mint and redeem Mini Racer tokens for Tronic Racer tokens
    function mintWithMiniRacer(uint256 amount, uint256[] memory tokensToRedeem) external payable {
        require(miniRacerSaleStarted(), "Mini Racer MOGO has not started");

        require(amount > 0, "You must mint at least one.");
        require(amount >= tokensToRedeem.length, "You can only redeem as many as you purchase.");

        // Ensure that the tokens paid for PLUS the number of redeemed mini racer tokens are available
        // Prevents accidentally over minting beyond 5,555
        require(totalSupply() + amount + tokensToRedeem.length <= MAX_SUPPLY, "Racers are sold out!");

        require(msg.value == PRICE * amount, "Too little or too much ETH sent");
        require(amount <= MAX_PER_MINT, "Maximum of 5 per transaction");

        // MOGO: mint one, get one
        for (uint256 t = 0; t < tokensToRedeem.length; t++) {
            require(_ownsMiniRacer(tokensToRedeem[t]) == true, "You must own the mini racer token to redeem it.");
            require(
                miniRacerAvailableToRedeem(tokensToRedeem[t]) == true,
                "One of the mini racers was already redeemed."
            );
            redeemedMiniRacers[tokensToRedeem[t]] = 1;
            _mintAndIncrement();
        }

        // Mint what was paid for
        for (uint256 index = 0; index < amount; index++) {
            _mintAndIncrement();
        }
    }

    function mintFromWhitelist(uint256 amount, bytes32[] calldata proof) external payable {
        require(whitelistSaleStarted(), "Whitelist sale has not started");

        string memory payload = string(abi.encodePacked(_msgSender()));
        require(_verify(_leaf(payload), proof), "Invalid Merkle Tree proof given.");

        require(totalSupply() + amount <= MAX_SUPPLY, "Racers are sold out!");
        require(amount > 0, "You must mint at least one.");

        require(msg.value == PRICE * amount, "Too little or too much ETH sent");
        require(amount <= MAX_PER_MINT, "Maximum of 5 per transaction");

        for (uint256 index = 0; index < amount; index++) {
            _mintAndIncrement();
        }
    }

    function remainingSupply() public view returns (uint256) {
        return MAX_SUPPLY - totalSupply();
    }

    function totalSupply() public view returns (uint256) {
        return _nextTokenId.current() - 1;
    }

    function miniRacerSaleStarted() public view returns (bool) {
        return block.timestamp > miniRacerSaleStartTimestamp;
    }

    function whitelistSaleStarted() public view returns (bool) {
        return block.timestamp > whitelistSaleStartTimestamp;
    }

    function saleStarted() public view returns (bool) {
        return block.timestamp > saleStartTimestamp;
    }

    function setMiniRacerSaleStart(uint256 _miniRacerSaleStartTimestamp) external onlyOwner {
        miniRacerSaleStartTimestamp = _miniRacerSaleStartTimestamp;
    }

    function setWhitelistSaleStart(uint256 _whitelistSaleStartTimestamp) external onlyOwner {
        whitelistSaleStartTimestamp = _whitelistSaleStartTimestamp;
    }

    function setSaleStart(uint256 _saleStartTimestamp) external onlyOwner {
        saleStartTimestamp = _saleStartTimestamp;
    }

    function setWhitelistMerkleRoot(bytes32 _whitelistMerkleRoot) external onlyOwner {
        whitelistMerkleRoot = _whitelistMerkleRoot;
    }

    function collectReserves() external onlyOwner {
        require(reservesCollected == false, "Reserves have already been collected");
        for (uint256 index = 0; index < RESERVES; index++) {
            _mintAndIncrement();
        }
        reservesCollected = true;
    }

    function miniRacerAvailableToRedeem(uint256 tokenId) public view returns (bool) {
        if (tokenId > 100 || tokenId < 1) {
            return false;
        }
        return redeemedMiniRacers[tokenId] != 1;
    }

    function _ownsMiniRacer(uint256 tokenId) private view returns (bool) {
        return ITronicMiniRacer(miniRacerContractAddress).ownerOf(tokenId) == msg.sender;
    }

    function tokenURI(uint256 tokenId) public view override(WithIPFSMetaData, ERC721) returns (string memory) {
        return WithIPFSMetaData.tokenURI(tokenId);
    }

    function setCID(string memory _cid) external onlyOwner {
        cid = _cid;
    }

    function _mintAndIncrement() private {
        _safeMint(_msgSender(), _nextTokenId.current());
        _nextTokenId.increment();
    }

    function _leaf(string memory payload) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(payload));
    }

    function _verify(bytes32 leaf, bytes32[] memory proof) private view returns (bool) {
        return MerkleProof.verify(proof, whitelistMerkleRoot, leaf);
    }

    function _baseURI() internal view override(WithIPFSMetaData, ERC721) returns (string memory) {
        return WithIPFSMetaData._baseURI();
    }

    function setProxyRegistryAddress(address _proxyRegistryAddress) external onlyOwner {
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    function flipProxyState(address proxyAddress) public onlyOwner {
        projectProxy[proxyAddress] = !projectProxy[proxyAddress];
    }

    function isApprovedForAll(address _owner, address operator) public view override returns (bool) {
        OpenSeaProxyRegistry proxyRegistry = OpenSeaProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(_owner)) == operator || projectProxy[operator]) return true;
        return super.isApprovedForAll(_owner, operator);
    }
}

interface ITronicMiniRacer {
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

contract OwnableDelegateProxy {}

contract OpenSeaProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}