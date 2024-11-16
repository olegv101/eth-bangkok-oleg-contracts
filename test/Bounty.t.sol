// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import { Bounty } from "../src/Bounty.sol";
import { Coin } from "../src/Coin.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

/// @dev If this is your first time with Forge, read this tutorial in the Foundry Book:
/// https://book.getfoundry.sh/forge/writing-tests
contract BountyTest is Test {
    Bounty internal bounty;
    Coin internal coin;
    address internal oracle = makeAddr("Oracle");
    address internal bountyCreator = makeAddr("BountyCreator");
    address internal bountyFiller = makeAddr("BountyFiller");

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        // Instantiate the contract-under-test.
        vm.startPrank(oracle);
        bounty = new Bounty();
        coin = new Coin();
        vm.stopPrank();
    }

    /**
     * The lifecycle of a pool
     */
    function test_realisticScenario() external {
        // Create bounty
        uint256 bountyAmount = 100;
        uint256 minViewCount = 10;
        string memory keyword = "keyword";
        vm.startPrank(bountyCreator);
        coin.mint(bountyCreator, bountyAmount);
        coin.approve(address(bounty), bountyAmount);
        bounty.createBounty(bountyAmount, minViewCount, keyword, coin);
        vm.stopPrank();

        // Verify tweet
        vm.startPrank(oracle);
        bounty.verifyTweet("tweetId", minViewCount);
        vm.stopPrank();

        // Fill bounty
        assertEq(coin.balanceOf(address(bounty)), bountyAmount);
        assertEq(coin.balanceOf(bountyFiller), 0);
        vm.startPrank(bountyFiller);
        bounty.fillBounty(0, "tweetId");
        vm.stopPrank();
        assertEq(coin.balanceOf(address(bounty)), 0);
        assertEq(coin.balanceOf(bountyFiller), bountyAmount);
    }
}
