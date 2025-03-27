// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {
    // Constructeur avec l'état initial du workflow
    constructor() Ownable(msg.sender) {
      currentStatus = WorkflowStatus.RegisteringVoters;
    }

    // Structure de données pour un électeur
    struct Voter {
      bool isRegistered;
      bool hasVoted;
      uint votedProposalId;
    }

    // Structure de données pour une proposition
    struct Proposal {
      string description;
      uint voteCount;
    }

    // Les différents états du workflow
    enum WorkflowStatus {
      RegisteringVoters,
      ProposalsRegistrationStarted,
      ProposalsRegistrationEnded,
      VotingSessionStarted,
      VotingSessionEnded,
      VotesTallied
    }

    // Variables d'état et mapping
    WorkflowStatus public currentStatus;
    mapping(address => Voter) public whitelist;
    Proposal[] public proposals;
    uint public winningProposalId;

    // Événements
    event VoterRegistered(address voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted(address voter, uint proposalId);

    // Modifier pour vérifier si le Workflow Status est bien celui attendu
    modifier checkWorkflowStatus(WorkflowStatus requiredStatus) {
      require(currentStatus == requiredStatus, "Incorrect workflow status");
      _;
    }

    // Fonction pour modifier l'état du Workflow Status
    function setWorkflowStatus(WorkflowStatus newStatus) internal onlyOwner {
      emit WorkflowStatusChange(currentStatus, newStatus);
      currentStatus = newStatus;
    }

    // Fonction pour enregistrer un Voter
    function addToWhitelist(address _address) public onlyOwner checkWorkflowStatus(WorkflowStatus.RegisteringVoters) {
      require(!whitelist[_address].isRegistered, "Address already registered");
      whitelist[_address] = Voter(true, false, 0);
      emit VoterRegistered(_address);
    }

    // Fonction pour enregistrer une Proposal
    function registerProposal(string memory _description) public checkWorkflowStatus(WorkflowStatus.ProposalsRegistrationStarted) {
      proposals.push(Proposal(_description, 0));
      emit ProposalRegistered(proposals.length - 1);
    }

    function getProposals() public view returns (Proposal[] memory) {
      return proposals;
    }

    // Fonction pour prendre en compte un vote
    function vote(uint _proposalId, address voter) public checkWorkflowStatus(WorkflowStatus.VotingSessionStarted) {
      require(whitelist[voter].isRegistered, "Address not registered");
      require(!whitelist[voter].hasVoted, "Address already voted");
      require(_proposalId < proposals.length, "Invalid proposal ID");

      whitelist[msg.sender].hasVoted = true;
      whitelist[msg.sender].votedProposalId = _proposalId;
      proposals[_proposalId].voteCount += 1;

      emit Voted(msg.sender, _proposalId);
    }

    // Fonction pour déterminer la proposition gagnante
    function tallyVotes() public onlyOwner checkWorkflowStatus(WorkflowStatus.VotingSessionEnded) {
      uint winningVoteCount = 0;

      for (uint i = 0; i < proposals.length; i++) {
          if (proposals[i].voteCount > winningVoteCount) {
              winningVoteCount = proposals[i].voteCount;
              winningProposalId = i;
          }
      }
      setWorkflowStatus(WorkflowStatus.VotesTallied);
    }

    // Fonction pour retourner l'id de la proposition gagnante
    function getWinner() public view checkWorkflowStatus(WorkflowStatus.VotesTallied) returns (uint) {
      return winningProposalId;
    }

    // Fonction pour passer au Workflow Status de l'enregistrement des propositions
    function openProposalRegistration() public onlyOwner checkWorkflowStatus(WorkflowStatus.RegisteringVoters) {
      setWorkflowStatus(WorkflowStatus.ProposalsRegistrationStarted);
    }

    // Fonction pour passer à la fermeture de l'enregistrement des propositions
    function closeProposalRegistration() public onlyOwner checkWorkflowStatus(WorkflowStatus.ProposalsRegistrationStarted) {
      setWorkflowStatus(WorkflowStatus.ProposalsRegistrationEnded);
    }

    // Fonction pour passer au Workflow Status de l'ouverture des votes
    function openVotingSession() public onlyOwner checkWorkflowStatus(WorkflowStatus.ProposalsRegistrationEnded) {
      setWorkflowStatus(WorkflowStatus.VotingSessionStarted);
    }

    // Fonction pour passer au Workflow Status de la fermeture des votes
    function closeVotingSession() public onlyOwner checkWorkflowStatus(WorkflowStatus.VotingSessionStarted) {
      setWorkflowStatus(WorkflowStatus.VotingSessionEnded);
    }
}
