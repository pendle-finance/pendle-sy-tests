// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {console} from "forge-std/Test.sol";

import {TestFoundation} from "../TestFoundation.sol";

abstract contract RewardsTest is TestFoundation {
    function test_rewards_claim() public {
        console.log("[-----test_rewards_claim-----]");

        address alice = wallets[0];

        uint256 refAmount = refAmountFor(startToken);
        fundToken(alice, startToken, refAmount);
        deposit(alice, startToken, refAmount);

        bool[] memory hasRewards = addFakeRewards();
        assertEq(hasRewards.length, sy.getRewardTokens().length, "hasRewards.length mismatch");

        address[] memory rewardTokens = sy.getRewardTokens();
        uint256[] memory rewardBalancesBefore = getBalances(alice, rewardTokens);

        uint256[] memory rewardAmounts = sy.claimRewards(alice);
        uint256[] memory rewardBalancesAfter = getBalances(alice, rewardTokens);

        for (uint256 i = 0; i < rewardTokens.length; i++) {
            if (!hasRewards[i]) continue;

            uint256 expected = rewardAmounts[i];
            uint256 actual = rewardBalancesAfter[i] - rewardBalancesBefore[i];
            console.log("[DO CHECK] Claimed", actual, getSymbol(rewardTokens[i]));
            assertGt(actual, 0, "Claimed amount should be greater than 0");
            assertEq(
                actual,
                expected,
                string.concat("claimRewards ", getSymbol(rewardTokens[i]), " actual != expected")
            );
        }
        console.log("");
    }

    function addFakeRewards() internal virtual returns (bool[] memory);
}
