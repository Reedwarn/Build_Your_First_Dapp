// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract StackUp {
    using SafeMath for uint256;

    enum PlayerQuestStatus {
        NOT_JOINED,
        IN_PROGRESS,
        SUBMITTED,
        NOT_SUBMITTED,
        REVIEWING
    }

    struct Quest {
        uint256 questId;
        uint256 numberOfPlayers;
        string title;
        uint8 reward;
        uint256 numberOfRewards;
        uint256 startDate;
        uint256 endDate;
        address[] playerAddresses;
    }

    address public admin;
    uint256 public nextQuestId;
    mapping(uint256 => Quest) public quests;
    mapping(address => mapping(uint256 => PlayerQuestStatus)) public playerQuestStatuses;
    uint256[] questIds;
    uint256[] endedQuestIds;

    constructor() {
        admin = msg.sender;
    }

    // Create a new quest
    function createQuest(
        string calldata title_,
        uint8 reward_,
        uint256 numberOfRewards_
    ) external {
        // Initialize quest properties
        require(msg.sender == admin, "Only the admin can create quests");
        quests[nextQuestId].questId = nextQuestId;
        quests[nextQuestId].title = title_;
        quests[nextQuestId].reward = reward_;
        quests[nextQuestId].numberOfRewards = numberOfRewards_;
        quests[nextQuestId].startDate = block.timestamp;
        quests[nextQuestId].endDate = quests[nextQuestId].startDate.add(11 days);

        // Add the quest to the list of questIds
        questIds.push(nextQuestId);

        // Increment the nextQuestId for the next quest creation
        nextQuestId++;
    }

    // Join a quest
    function joinQuest(uint256 questId) external questExists(questId) questStillOn(questId) {
        require(
            playerQuestStatuses[msg.sender][questId] == PlayerQuestStatus.NOT_JOINED,
            "Player has already joined/submitted this quest"
        );
        // Update player's quest status to IN_PROGRESS
        playerQuestStatuses[msg.sender][questId] = PlayerQuestStatus.IN_PROGRESS;

        Quest storage thisQuest = quests[questId];
        thisQuest.numberOfPlayers++;
        thisQuest.playerAddresses.push(msg.sender);
    }

    // Submit a quest
    function submitQuest(uint256 questId) external questExists(questId) questStillOn(questId) {
        require(
            playerQuestStatuses[msg.sender][questId] == PlayerQuestStatus.IN_PROGRESS,
            "Player must first join the quest"
        );
        // Update player's quest status to SUBMITTED
        playerQuestStatuses[msg.sender][questId] = PlayerQuestStatus.SUBMITTED;
    }

    // Review a quest and change the player's status
    function reviewQuest(uint256 questId, address player) internal questExists(questId) {
        if (playerQuestStatuses[player][questId] == PlayerQuestStatus.SUBMITTED) {
            playerQuestStatuses[player][questId] = PlayerQuestStatus.REVIEWING;
        } else if (playerQuestStatuses[player][questId] == PlayerQuestStatus.IN_PROGRESS) {
            playerQuestStatuses[player][questId] = PlayerQuestStatus.NOT_SUBMITTED;
        }
    }

    // Get the IDs of ended quests
    function getEndedQuestsIds() internal {
        
        uint256 numberOfQuests = questIds.length;
        for (uint256 i = 0; i < numberOfQuests; i++) {
            uint256 questId = questIds[i];
            if (block.timestamp >= quests[questId].endDate){
                endedQuestIds.push(questId);
            }
        }
    }

    // Review all ended quests
    function reviewEndedQuests() external {
        getEndedQuestsIds();
        uint256 numberOfEndedQuests = endedQuestIds.length;
        for (uint256 i = 0; i < numberOfEndedQuests; i++) {
            uint256 endedQuestId = endedQuestIds[i];
            Quest storage endedQuest = quests[endedQuestId];
            uint256 numberOfPlayers = endedQuest.playerAddresses.length;

            for (uint256 j = 0; j < numberOfPlayers; j++) {
                address playerAddress = endedQuest.playerAddresses[j];
                reviewQuest(endedQuestId, playerAddress);
            }
        }
    }


    // Modifier: Check if a quest exists
    modifier questExists(uint256 questId) {
        require(quests[questId].reward != 0, "Quest does not exist");
        _;
    }

    // Modifier: Check if a quest is still ongoing
    modifier questStillOn(uint256 questId) {
        require(block.timestamp < quests[questId].endDate, "Cannot join/submit quest, quest has ended");
        _;
    }
}
