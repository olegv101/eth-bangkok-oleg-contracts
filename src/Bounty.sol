// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {console2} from "forge-std/src/console2.sol";

contract Bounty is Ownable {
    struct Bounty {
        string tweetId;
        string keyword;
        ERC20 bountyToken;
        address bountyCreator;
        uint256 bountyAmount;
        uint256 minViewCount;
        uint256 filledAt;
        address filledBy;
    }

    mapping(uint256 bountyId => Bounty) public bounties;
    mapping(string tweetId => uint256 viewCount) public tweetToViewCount;
    uint256[] public bountyIds;

    constructor() Ownable(msg.sender) {}

    function createBounty(
        uint256 bountyAmount,
        uint256 minViewCount,
        string memory keyword,
        ERC20 bountyToken
    ) external {
        bountyToken.transferFrom(msg.sender, address(this), bountyAmount);
        Bounty memory bounty = Bounty({
            tweetId: "",
            keyword: keyword,
            bountyToken: bountyToken,
            bountyCreator: msg.sender,
            bountyAmount: bountyAmount,
            minViewCount: minViewCount,
            filledAt: type(uint256).max,
            filledBy: address(0)
        });
        bountyIds.push(bountyIds.length);
        bounties[bountyIds.length - 1] = bounty;
    }

    function fillBounty(uint256 bountyId, string memory tweetId) external {
        Bounty storage bounty = bounties[bountyId];
        require(bounty.filledAt == type(uint256).max, "Bounty already filled");
        require(tweetToViewCount[tweetId] >= bounty.minViewCount, "Not enough views");
        bounty.filledAt = block.timestamp;
        bounty.filledBy = msg.sender;
        bounty.tweetId = tweetId;
        bounty.bountyToken.transfer(msg.sender, bounty.bountyAmount);
    }

    function verifyTweet(string memory tweetId, uint256 viewCount) public {
        tweetToViewCount[tweetId] = viewCount;
    }

    function getBounties() external view returns (Bounty[] memory) {
        Bounty[] memory bountiesArray = new Bounty[](bountyIds.length);
        for (uint256 i = 0; i < bountyIds.length; i++) {
            bountiesArray[i] = bounties[bountyIds[i]];
        }
        return bountiesArray;
    }
}
