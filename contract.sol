//SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

contract UniversiDAO {
    address payable DAOaddress;

    uint256 proposalId;
    uint256 memberCount; // number of members

    struct member {
        bool canVote;
        address memberAdress;
        uint256 memberCount;
    }

    mapping(address => member) members;

    struct proposal {
        string data;
        uint256 valueToReward;
        address payable owner;
        bool active;
        uint256 createdAt;
        uint256 deadline;
        mapping(address => bool) voters;
        uint256 voteFor;
        uint256 voteAgainst;
    }

    mapping(uint256 => proposal) proposals;

    //
    //  start of membershig handling
    //

    constructor() {
        DAOaddress = payable(msg.sender); // setting the owner the contract deployer: The DAO
    }

    modifier onlyDAO() {
        require(msg.sender == DAOaddress, "Ownable: caller is not the DAO");
        _;
    }

    function addMember(address _newMemberAddress) public onlyDAO {
        members[_newMemberAddress].canVote = true;
        members[_newMemberAddress].memberAdress = _newMemberAddress;
        members[_newMemberAddress].memberCount = memberCount;
        memberCount++;
    }

    function removeMember(address _newMemberAddress) public onlyDAO {
        delete members[_newMemberAddress];
    }

    function verifyMember(address _thisMemberAddress)
        public
        view
        returns (bool)
    {
        bool userCanVote = members[_thisMemberAddress].canVote;
        return userCanVote;
    }

    modifier isMember(address _address) {
        require(members[_address].canVote, "You need to be a member");
        _;
    }

    //
    //  finish of membershig handling
    //

    function CreateProposal(
        string memory _data,
        uint256 _valueToReward,
        uint256 timeStamp
    ) public {
        proposals[proposalId].data = _data;
        proposals[proposalId].valueToReward = _valueToReward;
        proposals[proposalId].owner = payable(msg.sender);
        proposals[proposalId].active = true;
        proposals[proposalId].createdAt = block.timestamp;
        proposals[proposalId].deadline =
            proposals[proposalId].createdAt +
            timeStamp;
        proposalId++;
    }

    function getProposal(uint256 index)
        public
        view
        returns (
            string memory,
            uint256,
            address,
            bool,
            uint256,
            uint256
        )
    {
        return (
            proposals[index].data,
            proposals[index].valueToReward,
            proposals[index].owner,
            proposals[index].active,
            proposals[index].createdAt,
            proposals[index].deadline
        );
    }

    function toVote(uint256 _proposalId, bool vote) public {
        require(
            proposals[_proposalId].voters[msg.sender] == false,
            "already voted"
        );
        require(
            block.timestamp < proposals[_proposalId].deadline,
            "voting endend"
        );
        if (vote) {
            proposals[_proposalId].voteFor++;
        } else {
            proposals[_proposalId].voteAgainst++;
        }
        proposals[_proposalId].voters[msg.sender] = true;
    }

    function getParcialResult(uint256 _proposalId)
        public
        view
        returns (uint256)
    {
        require(
            proposals[_proposalId].voteFor +
                proposals[_proposalId].voteAgainst !=
                0,
            "No votes, baby"
        );
        return
            (100 * proposals[_proposalId].voteFor) /
            (proposals[_proposalId].voteFor +
                proposals[_proposalId].voteAgainst);
    }

    function listActiveProposals() public view returns (uint256[] memory) {
        uint256[] memory activeProposals;

        for (uint256 i = 0; i < proposalId; i++) {
            if (proposals[i].active) {
                activeProposals[i] = i;
            }
        }
        return activeProposals;
    }

    function withdrawProposal(uint256 _proposalId) public payable {
        require(
            block.timestamp > proposals[_proposalId].deadline,
            "voting on going"
        );
        require(
            proposals[_proposalId].voteFor < proposals[_proposalId].voteAgainst,
            "voting not approved"
        );
        require(
            address(this).balance - proposals[_proposalId].valueToReward > 0,
            "No funds, comeback later"
        );
        uint256 value = proposals[_proposalId].valueToReward;
        address payable _receiver = proposals[_proposalId].owner;
        // address(proposals[_proposalId].owner).transfer(proposals[_proposalId].valueToReward);
        (_receiver).transfer(value);
    }

    function deposit() public payable {
        // nothing else to do!
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
