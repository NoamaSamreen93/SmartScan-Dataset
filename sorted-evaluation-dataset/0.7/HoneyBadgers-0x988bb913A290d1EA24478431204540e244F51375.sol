// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract HoneyBadgers is ERC721Enumerable, Ownable, PaymentSplitter {
    using Address for address;
    using Strings for uint256;
    using Counters for Counters.Counter;

    string public _contractBaseURI =
        "https://metadata-live.realitics.info/v1/metadata/";
    string public _contractURI =
        "https://ipfs.io/ipfs/QmRCvbVG2X2waXszFiWS3TkHCKJcMg76G7EPJkmZJJ5Mdw";
    address private devWallet;
    bool public locked; //metadata lock
    uint256 public maxSupply = 10000;
    uint256 public saleStartTime = 1639980000;
    uint256[3] public genesis = [1000, 5, .035 ether];
    uint256[3] public pioneer = [3000, 10, .05 ether];
    uint256[3] public builder = [8000, 10, .06 ether];
    uint256[3] public dao = [10000, 10, .07 ether];
    uint256 public maxDaoSupply = 2000;
    bool public daoSaleOpen = false;
    address[] private addressList = [
        0xecf86Cf8689394ED484c5B62f8Dd78ccCc750d41, //h
        0x75Ca74CF7238a8D8337ED8c45F584c220b176d55 //d
        //0x33519535356F8877dA7a90bF522FCACA5B01a2A2 //n remove
    ];
    uint256[] private shareList = [50, 50];
    Counters.Counter private _tokenIds;
    //----------- Reward System ----------- //only used in case of emergency
    uint256 public rewardEndingTime = 0; //unix time
    uint256 public maxRewardTokenID = 2000; //can claim if you have < this tokenID
    uint256 public maxFreeNFTperID = 1;
    mapping(uint256 => uint256) public claimedPerID;

    modifier onlyDev() {
        require(msg.sender == devWallet, "only dev");
        _;
    }
	constructor() ERC721("Honey Badger Clan", "HBCD") PaymentSplitter(addressList, shareList) {
        devWallet = msg.sender;
    }
    function buyGenesis(uint256 qty) external payable {
        require(block.timestamp >= saleStartTime, "not live");
        require(
            _tokenIds.current() + qty <= genesis[0], "genesis sale not live"
        );
        require(qty <= genesis[1], "genesis qty not correct");
        require(genesis[2] * qty == msg.value, "genesis price not correct");
        _mintTokens(qty, msg.sender);
    }
    function buyPioneer(uint256 qty) external payable {
        require(block.timestamp >= saleStartTime, "not live");
        require(
            _tokenIds.current() + qty > genesis[0] &&
                _tokenIds.current() + qty <= pioneer[0], "pioneer sale not live"
        );
        require(qty <= pioneer[1], "pioneer qty <=10");
        require(pioneer[2] * qty == msg.value, "pioneer price not correct");
        _mintTokens(qty, msg.sender);
    }
    function buyBuilder(uint256 qty) external payable {
        require(block.timestamp >= saleStartTime, "not live");
        require(
            _tokenIds.current() + qty > pioneer[0] &&
                _tokenIds.current() + qty <= builder[0], "builder sale not live"
        );
        require(qty <= builder[1], "builder qty <=10");
        require(builder[2] * qty == msg.value, "builder price not correct");
        _mintTokens(qty, msg.sender);
    }
    function buyDao(uint256 qty) external payable {
        require(block.timestamp >= saleStartTime, "not live");
        require(
            _tokenIds.current() + qty > builder[0] &&
                _tokenIds.current() + qty <= dao[0], "dao sale not live"
        );
        require(daoSaleOpen, "dao sale not open");
        require(qty <= dao[1], "quantity not correct");
        require(dao[2] * qty <= msg.value, "dao price not correct");
        require(
            (_tokenIds.current() - builder[0]) + qty <= maxDaoSupply,"public sale out of stock"
        );
        _mintTokens(qty, msg.sender);
    }
    function _mintTokens(uint256 qty, address to) private {
        for (uint256 i = 0; i < qty; i++) {
            _tokenIds.increment();
            _safeMint(to, _tokenIds.current());
        }
    }
    // if reward system is active
    function claimReward(uint256 nftID) external {
        require(rewardEndingTime >= block.timestamp, "reward period not active");
        require(rewardEndingTime != 0, "reward period not set");
        require(claimedPerID[nftID] < maxFreeNFTperID, "you already claimed");
        require(block.timestamp >= saleStartTime, "sale not live");
        require(ownerOf(nftID) == msg.sender, "ownership required");
        require(nftID <= maxRewardTokenID, "nftID not in range");
        claimedPerID[nftID] = claimedPerID[nftID] + 1; //increase the claimedPerID
        _tokenIds.increment();
        _safeMint(msg.sender, _tokenIds.current());
    }
	// admin can mint them for giveaways, airdrops,use from web2  etc
    function eCommerceMint(uint256 qty, address to) external onlyOwner {
        require(qty <= 10, "no more than 10");
        require(_tokenIds.current() + qty <= maxSupply, "out of stock");
        _mintTokens(qty, to);
    }    
    function adminMint(uint256 qty, address to) external onlyOwner {
        require(qty <= 10, "no more than 10");
        require(_tokenIds.current() + qty <= maxSupply, "out of stock");
        _mintTokens(qty, to);
    }
	function tokensOfOwner(address _owner) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 index;
            for (index = 0; index < tokenCount; index++) {
                result[index] = tokenOfOwnerByIndex(_owner, index);
            }
            return result;
        }
    }
    function exists(uint256 _tokenId) external view returns (bool) {
        return _exists(_tokenId);
    }
	function isApprovedOrOwner(address _spender, uint256 _tokenId) external view returns (bool) {
		return _isApprovedOrOwner(_spender, _tokenId);
	}
	function tokenURI(uint256 _tokenId) public view override returns (string memory) {
		require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
		return string(abi.encodePacked(_contractBaseURI, _tokenId.toString(), ".json"));
	}
    function setBaseURI(string memory newBaseURI) external onlyDev {
        require(!locked, "locked functions");
        _contractBaseURI = newBaseURI;
    }
    function setContractURI(string memory newuri) external onlyDev {
        require(!locked, "locked functions");
        _contractURI = newuri;
    }
    function contractURI() public view returns (string memory) {
        return _contractURI;
    }
    function reclaimERC20(IERC20 erc20Token) external onlyOwner {
        erc20Token.transfer(msg.sender, erc20Token.balanceOf(address(this)));
    }
    function reclaimERC721(IERC721 erc721Token, uint256 id) external onlyOwner {
        erc721Token.safeTransferFrom(address(this), msg.sender, id);
    }
	function reclaimERC1155(IERC1155 erc1155Token, uint256 id, uint256 amount) external onlyOwner {
		erc1155Token.safeTransferFrom(address(this), msg.sender, id, amount, "");
	}
    //in unix
    function setSaleStartTime(uint256 _saleStartTime) external onlyOwner {
        saleStartTime = _saleStartTime;
    }
    function decreaseMaxSupply(uint256 newMaxSupply) external onlyOwner {
        require(newMaxSupply < maxSupply, "decrease only");
        maxSupply = newMaxSupply;
    }
    // and for the eternity!
    function lockBaseURIandContractURI() external onlyDev {
        locked = true;
    }
    //if newTime is in the future, start the reward system [only owner]
    function setRewardEndingTime(uint256 newTime) external onlyOwner {
        rewardEndingTime = newTime;
    }
    //can claim if < maxRewardTokenID
    function setMaxRewardTokenID(uint256 newMax) external onlyOwner {
        maxRewardTokenID = newMax;
    }
    //after voting chage price [10000,10,.07 ether];
    function setDaoPrice(uint256 price) external onlyOwner {
        dao[2] = price;
    }
    //max qty / tran
    function setDaoTranQty(uint256 newQty) external onlyOwner {
		require(newQty <= maxDaoSupply, "Invalid Per Tran Qty");
        dao[1] = newQty;
    }
    //how many tokens are available for dao sale
    function setDaoMaxSupply(uint256 newMaxSupply) external onlyOwner {
		require(newMaxSupply <= maxDaoSupply, "max supply should be 2000");
        maxDaoSupply = newMaxSupply;
    }
    function setAllowDaoSale(bool allowDaoSale) external onlyOwner {
        daoSaleOpen = allowDaoSale;
    }
}