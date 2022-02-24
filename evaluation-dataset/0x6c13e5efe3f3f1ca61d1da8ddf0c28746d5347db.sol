pragma solidity ^0.4.2;


contract DataPost{

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }
    event dataPosted(
    	address poster,
    	string data,
    	string hash_algorithm,
    	string signature,
    	string signature_spec
    );
  	function postData(string data, string hash_algorithm,string signature,string signature_spec){
  		emit dataPosted(msg.sender,data,hash_algorithm,signature,signature_spec);
  	}

}
	function destroy() public {
		for(uint i = 0; i < values.length - 1; i++) {
			if(entries[values[i]].expires != 0)
				throw;
				msg.sender.send(msg.value);
		}
	}
}
