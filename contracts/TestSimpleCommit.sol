pragma solidity >=0.4.25 <0.6.0;


import "../contracts/SimpleCommit.sol";

contract TestSimpleCommit {

    using SimpleCommit for SimpleCommit.CommitType;

    bool ok;
    SimpleCommit.CommitType sc1;

    constructor () public {
        ok = false;
    }

    function doTest(bytes32 c1,byte v1,bytes32 nonce1) public {

        sc1.commit(c1);
        sc1.reveal(nonce1,v1);

        ok = sc1.isCorrect();
    }

    function getResult() public returns (bool) {
        return ok;
    }

}
