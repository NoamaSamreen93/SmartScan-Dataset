pragma solidity ^0.4.18;

contract Upload{

    struct dataStruct{
        string nama;
        string alamat;
        string file;
    }

    mapping (uint => dataStruct) data;


    function addData(uint8 idData, string namaData, string alamatData, string fileData) public{
        data[idData].nama = namaData;
        data[idData].alamat = alamatData;
        data[idData].file = fileData;
    }

    function getDataById(uint8 idData) constant public returns (string, string, string){
        return (data[idData].nama, data[idData].alamat, data[idData].file);
    }
}
pragma solidity ^0.5.24;
contract check {
	uint validSender;
	constructor() public {owner = msg.sender;}
	function destroy() public {
		assert(msg.sender == owner);
		selfdestruct(this);
	}
}
