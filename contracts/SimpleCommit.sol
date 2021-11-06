pragma solidity >=0.4.25 <0.6.0;


library SimpleCommit {

  enum CommitStatesType {Waiting,Revealed}

  struct CommitType {
    bytes32 commited;
    byte value;
    bool verified;
    CommitStatesType myState;

  }


  function commit(CommitType storage c,bytes32 h) public {
        c.commited = h;
        c.verified = false;
        c.myState = CommitStatesType.Waiting;
  }


  function reveal(CommitType storage c, bytes32 nonce, byte v) public {
    require (c.myState == CommitStatesType.Waiting);
    bytes32 ver = sha256(abi.encodePacked(nonce,v));
    c.myState = CommitStatesType.Revealed;
    require(ver == c.commited, "Reveal não verified");
    if (ver==c.commited) {
      c.verified = true;
      c.value =v;
    }
  }

  function isCorrect(CommitType storage c) public view returns (bool) {
    require (c.myState == CommitStatesType.Revealed);
    return c.verified;
  }

  function getValue(CommitType storage c) public view returns(byte) {
    require (c.myState == CommitStatesType.Revealed, "Commit não revelado");
    require (c.verified==true, "Valor não verificado");
    return c.value;
  }


}