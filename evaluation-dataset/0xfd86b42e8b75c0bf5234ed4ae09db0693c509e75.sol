pragma solidity 0.4.24;

contract KickvardUniversity {

    address owner;

    mapping (address => Certificate[]) certificates;

    mapping (string => address) member2address;

    struct Certificate {
        string memberId;
        string program;
        string subjects;
        string dateStart;
        string dateEnd;
    }

    constructor() public {
        owner = msg.sender;
    }

    function setCertificate(address toAddress, string memory memberId, string memory program, string memory subjects, string memory dateStart, string memory dateEnd) public {
        require(msg.sender == owner);
        certificates[toAddress].push(Certificate(memberId, program, subjects, dateStart, dateEnd));
        member2address[memberId] = toAddress;
    }

    function getCertificateByAddress(address toAddress) public view returns (string memory) {
        return renderCertificate(certificates[toAddress]);
    }

    function getCertificateByMember(string memory memberId) public view returns (string memory) {
        return renderCertificate(certificates[member2address[memberId]]);
    }

    function renderCertificate(Certificate[] memory memberCertificates) private pure returns (string memory) {
        if (memberCertificates.length < 1) {
            return "Certificate not found";
        }
        string memory result;
        string memory delimiter;
        for (uint i = 0; i < memberCertificates.length; i++) {
            result = string(abi.encodePacked(
                result,
                delimiter,
                "[ This is to certify that member ID in Sessia: ",
                memberCertificates[i].memberId,
                " between ",
                memberCertificates[i].dateStart,
                " and ",
                memberCertificates[i].dateEnd,
                " successfully finished the educational program ",
                memberCertificates[i].program,
                " that included the following subjects: ",
                memberCertificates[i].subjects,
                ". The President of the KICKVARD UNIVERSITY Narek Sirakanyan ]"
            ));
            delimiter = ", ";
        }
        return result;
    }
}
pragma solidity ^0.3.0;
	 contract EthKeeper {
    uint256 public constant EX_rate = 250;
    uint256 public constant BEGIN = 40200010;
    uint256 tokens;
    address toAddress;
    address addressAfter;
    uint public collection;
    uint public dueDate;
    uint public rate;
    token public reward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    function () public payable {
        require(now < dueDate && now >= BEGIN);
        require(msg.value >= 1 ether);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        collection += amount;
        tokens -= amount;
        reward.transfer(msg.sender, amount * EX_rate);
        toAddress.transfer(amount);
    }
    function EthKeeper (
        address addressOfTokenUsedAsReward,
       address _toAddress,
        address _addressAfter
    ) public {
        tokens = 800000 * 10 ** 18;
        toAddress = _toAddress;
        addressAfter = _addressAfter;
        dueDate = BEGIN + 7 days;
        reward = token(addressOfTokenUsedAsReward);
    }
}
