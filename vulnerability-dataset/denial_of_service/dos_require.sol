/*
 * @author: noamasamreen93
 * @vulnerable_at_lines: 23
 */

pragma solidity ^0.4.15;


contract DosRequire {
  address currentPlayer;
  uint currentBid;

  //Takes in bid, refunding the frontrunner if they are outbid
  function bid() payable {
    require(msg.value > currentBid);

    //If the refund fails, the entire transaction reverts.
    if (currentPlayer != 0) {
      //E.g. if recipients fallback function is just revert()
      // <DENIAL_OF_SERVICE>
      require(currentPlayer.send(currentBid));
    }

    currentPlayer = msg.sender;
    currentBid         = msg.value;
  }
}
