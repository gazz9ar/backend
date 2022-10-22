// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Election{

    struct Candidate {
        string name;
        bool registered;
        bool approved;
        uint voteCount;
    }

    struct Voter {
        bool voted;
        bool registered;
        address vote;
    }

    address[] public candidateAddresses;
    address public owner;
    string public electionName;

    mapping(address => Voter) public voters;
    mapping(address => Candidate) public candidates;
    uint public totalVotes;

    enum State {Created, Voting, Ended} State public state;

    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier inState(State _state){
        require(state == _state, "Incorrect state");
        _;
    }

    constructor(string memory _name){
        owner = msg.sender;
        electionName = _name;
        state = State.Created;
    }

    function payFee() public payable {
        //TODO validar por el dueño del contrato
        require(msg.value == 1 ether, "Insufficients funds");
        candidates[msg.sender].registered = true;
    }

    function registerVoter(address _voterAddress) onlyOwner inState(State.Created) public {
        require(!voters[_voterAddress].registered, "Voter already registered");
        require(_voterAddress != owner, "The owner cannot be a voter");
        voters[_voterAddress].registered = true;
    }

    function addCandidate(address _canAddress, string memory _name) onlyOwner inState(State.Created) public{
        require(candidates[_canAddress].registered, "Unregistered candidate");
        candidates[_canAddress].name = _name;
        candidates[_canAddress].voteCount = 0;
        candidateAddresses.push(_canAddress);
    }

    function startVote() inState(State.Created) onlyOwner public {
        state = State.Voting;
    }

    function vote(address _canAddress) inState(State.Voting) public {
        require(voters[msg.sender].registered, "Voter not registered");
        require(!voters[msg.sender].voted, "The voter can only vote once");
        require(candidates[_canAddress].registered, "Candidate not registered");
        require(msg.sender != owner, "Owner cannot vote");
        voters[msg.sender].vote = _canAddress;
        voters[msg.sender].voted = true;
        candidates[_canAddress].voteCount++;
        totalVotes++;
    }




    function endVote() inState(State.Voting) onlyOwner public {
        state = State.Ended;
    }

    function announceWinner() inState(State.Ended) onlyOwner public view returns(address){
        uint max = 0;
        uint i;
        address winnerAddress;
        for(i=0; i<candidateAddresses.length; i++) {
            if(candidates[candidateAddresses[i]].voteCount > max){
                max = candidates[candidateAddresses[i]].voteCount;
                winnerAddress = candidateAddresses[i];
            }
        }
        return winnerAddress;
    }

    function getTotalCandidate() public view returns(uint){
        return candidateAddresses.length;
    }


}