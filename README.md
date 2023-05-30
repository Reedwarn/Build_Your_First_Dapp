# Build_Your_First_Dapp Bounty on StackUp

The bounty requires us to add more functionalituies to the Stackup smart contract in the "Build your first Dapp" module, to make it as similar to the stackup site as it can be, and my additions are the following;
1. Quest start and end dates
2. More PlayerQuestStatuses (NOT_SUBMITTED and REVIEWING)

I chose these two because they give continuity to the existing smart contract, the start and end dates set ultimatum for the players, the NOT_SUBMITTED and REVIEWING statuses states what happens when the quests end.

## Quest Start and End dates
For the first addition, i added two more variables to the Quest struct; the `startDate`, which stores the date and time quests are created, and the `endDate`, which stores the date and time quests ended. The `startDate` is gotten by taking the timestamp when the `createQuest` function is invoked, while the `endDate` is gotten by adding eleven days to the `startDate` to mimic the Stackup site functionality, this addition is done using Safemath from the openzeppelin library to ensure safe arithmetic operations. Adding these two properties to the quest struct means there will be an ultimatum for joining and submitting the quests, and this has to be included in the smart contract, this was why i added a `questStillOn` modifier in the `joinQuest` and `submitQuest` functions, this modifier ensures that players can only join or submit quests that are still on, i.e, quests whose endDates have not yet elapsed.

## More PlayerQuestStatuses (NOT_SUBMITTED and REVIEWING)
The start and end dates prompted the question, "what happens to the players' statuses when a quest ends?", and to answer this question, i updated the `PlayerQuestStatus` enum to include `REVIEWING` and `NOT_SUBMITTED`, so, for all players that joined a quest, their statuses change as follows;
* Players who submitted the quest before its `endDate` have their statuses changed to "REVIEWING",
* Players who didn't submit the quest before its `endDate` have their statuses changed to "NOT_SUBMITTED", while
* Players who didn't join the quest have their statuses remain "NOT_JOINED".

I achieved all these by writing a `reviewQuest` function that takes in two parameters; the questID of ended quests, and the address of each player that joined, validates that the quest exists and uses an `if elseif` statement to check the player's status for the quest, and change it accordingly. This threw a problem of how the `reviewQUest` function reviews all quests for all their players, to overcome this, i created three array variables; `playerAddresses` to store the addresses of players that join a quest, `questIds` to store the IDs of the quests as they are being created, and `endedQuestIds` to store IDs of quests that have ended, the `getEndedQuestsIDs` function was used to get the IDs of the ended quests by looping through the `questIds` array and comparing their `endDates` with the block timestamp.
The `reviewEndedQuests` function is then used to loop through the `endedQuestIDs` and `playerAddresses` for the ended quest, and each endedQuestID and the addresses of the players that joined are passed to the `reviewQuest` function.
