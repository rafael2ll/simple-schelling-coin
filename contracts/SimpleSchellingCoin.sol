pragma solidity >=0.4.25 <0.6.0;

import "./SimpleCommit.sol";


contract SimpleSchellingCoin{
     using SimpleCommit for SimpleCommit.CommitType;

    enum State{WAITING_DEPOSIT,COLLECTING_VOTES, REVEALING_VOTES, PAYING_WINNERS, FINISHED}
    
    address owner;
    mapping (address => SimpleCommit) voteCommitMap;
    mapping (bool => uint256) voteResultMap;
    uint256 voteCount = 0;
    
    State state = State.WAITING_DEPOSIT;
    bool allRevealed = false;
    uint256 initialBlock;
    uint256 votingThreshold = 20;
    uint256 revealingThreshold = 50;
    uint256 reward;

    constructor () public payable{
        owner = msg.sender;
        reward = msg.value;
        state = State.COLLECTING_VOTES;
        initialBlock = block.number;
    }

    function vote(bytes32 _commit) public{
        require(state == State.COLLECTING_VOTES, "You cannot vote yet");
        address voter = msg.sender;
        require(!voteCommitMap[voter].exist, "You already voted!");

        SimpleCommit memory c;
        c.commit(_commit);
        voteCommitMap[msg.address] = c;

        voteCount++;

        if(block.number == initialBlock + votingThreshold){
            state = State.REVEALING_VOTES;
            initalizeResultMap();
        }
    }

    function closeVotation() public{
        require(msg.sender == owner, "Only the owner can close the votation");
        require(state == State.COLLECTING_VOTES, "You cannot close the votation now");
        initalizeResultMap();
        state = State.REVEALING_VOTES;
    }

    function revealVote(bytes32 _nonce, bool _vote) public{
        address voter = msg.sender;
        SimpleCommit voterCommit = voteCommitMap[voter];
        require(state == State.REVEALING_VOTES);
        require(voterCommit.exist, "You did not vote");
        require(!voterCommit.isRevealed(), "You already revealed once");

        voterCommit.reveal(_nonce, _vote);
        
        if(voterCommit.isCorrect())
            voteResultMap[voterCommit.getValue()] = voteResultMap[voterCommit.getValue()] + 1;
        if(block.number == initialBlock + revealingThreshold){
            state = State.PAYING_WINNERS;
        }
    }

    // On tie, yes wins....to avoid reopening the votation. Fair? Maybe not
    function payMe() payable public{
        require(state == State.PAYING_WINNERS, "You cannot ask for this yet");
        
        bool winnerValue = voteResultMap[true] >= voteResultMap[false];
        address voter = msg.sender;
        SimpleCommit voterCommit = voteCommitMap[voter];
        require(voterCommit.exist, "You did not vote");
        require(voter.getValue() == winnerValue, "You did not voted right");
        require(!voterCommit.paid, "You already got paid");
        
        uint256 amount = reward/voteResultMap[winnerValue];
        voter.transfer(amount);
        
        voteCommitMap[voter].setPaid();
    }

    function initalizeResultMap() internal{
        voteResultMap[true] = 0;
        voteResultMap[false] = 0;
    }
}