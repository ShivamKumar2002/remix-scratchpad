// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAO {
    struct Proposal {
        string description;
        uint256 voteCount;
        uint256 yesVotes;
        uint256 noVotes;
        bool executed;
    }

    struct Member {
        address memberAddress;
        uint256 memberSince;
        uint256 tokenBalance;
    }

    address[] public members;
    mapping(address => bool) public isMember;
    mapping(address => Member) public memberInfo;
    mapping(address => mapping(uint256 => bool)) public votes;
    Proposal[] public proposals;

    uint256 public totalSupply;
    mapping(address => uint256) public balances;

    event ProposalCreated(uint256 indexed proposalId, string description);
    event VoteCast(
        address indexed voter,
        uint256 indexed proposalId,
        uint256 tokenAmount
    );
    event ProposalAccepted(string message);
    event ProposalRejected(string rejected);

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function addMember(address _member) public {
        require(msg.sender == owner);
        require(isMember[_member] == false, "Member already exists");
        memberInfo[_member] = Member({
            memberAddress: _member,
            memberSince: block.timestamp,
            tokenBalance: 100
        });
        members.push(_member);
        isMember[_member] = true;
        balances[_member] = 100;
        totalSupply += 100;
    }

    function removeMember(address _member) public {
        require(msg.sender == owner);
        require(isMember[_member] == true, "member does not exist");
        memberInfo[_member] = Member({
            memberAddress: address(0),
            memberSince: 0,
            tokenBalance: 0
        });
        for (uint256 i = 0; i < members.length; i++) {
            if (members[i] == _member) {
                members[i] = members[members.length - 1];
                members.pop();
                break;
            }
        }
        isMember[_member] = false;
        balances[_member] = 0;
        totalSupply -= 100;
    }

    function createProposal(string memory _description) public {
        proposals.push(
            Proposal({
                description: _description,
                voteCount: 0,
                yesVotes: 0,
                noVotes: 0,
                executed: false
            })
        );
        emit ProposalCreated(proposals.length - 1, _description);
    }

    function castVote(
        uint256 _proposalId,
        uint256 _tokenAmount,
        bool _decision
    ) public {
        require(
            isMember[msg.sender] == true,
            "You should be a member to vote"
        );
        require(
            balances[msg.sender] >= _tokenAmount,
            "Not enough tokens to vote"
        );
        require(
            votes[msg.sender][_proposalId] == false,
            "You have already voted for this proposal"
        );
        votes[msg.sender][_proposalId] = _decision;
        memberInfo[msg.sender].tokenBalance -= _tokenAmount;
        proposals[_proposalId].voteCount += _tokenAmount;
        if (_decision == true) {
            proposals[_proposalId].yesVotes += _tokenAmount;
        } else {
            proposals[_proposalId].noVotes += _tokenAmount;
        }
        emit VoteCast(msg.sender, _proposalId, _tokenAmount);
    }

    function executeProposal(uint256 _proposalId) public {
        require(
            proposals[_proposalId].executed == false,
            "Proposal has already been executed"
        );
        require(
            proposals[_proposalId].yesVotes > proposals[_proposalId].noVotes
        );
        proposals[_proposalId].executed = true;
        emit ProposalAccepted("Proposal has been approved");
    }
}
