// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {console} from "forge-std/Test.sol";

import {TestFoundation} from "../TestFoundation.sol";

abstract contract PreviewTest is TestFoundation {
    uint256 internal constant DENOM = 17;
    uint256 internal constant NUMER = 3;
    uint256 internal constant NUM_TESTS = 20;

    function test_preview_depositThenRedeem() public {
        address[] memory allTokensIn = getTokensInForPreviewTest();
        address[] memory allTokensOut = getTokensOutForPreviewTest();

        console.log("[-----test_preview_depositThenRedeem-----]");

        address alice = wallets[0];

        uint256 divBy = 1;

        for (uint256 it = 0; it < NUM_TESTS; ++it) {
            address tokenIn = allTokensIn[it % allTokensIn.length];
            address tokenOut = allTokensOut[(it + 1) % allTokensOut.length];
            uint256 amountIn = refAmountFor(tokenIn) / divBy;

            console.log("[DO CHECK] ================= Test:", it + 1, " ====================");
            console.log("Testing ", getSymbol(tokenIn), "=>", getSymbol(tokenOut));
            console.log("Amount in :", amountIn);

            fundToken(alice, tokenIn, amountIn);

            uint256 amountOut = _executePreviewTest(alice, tokenIn, amountIn, tokenOut);
            console.log("Amount out:", amountOut);
            console.log("");

            divBy = (divBy * NUMER) % DENOM;
        }

        console.log("");
    }

    function _executePreviewTest(
        address wallet,
        address tokenIn,
        uint256 netTokenIn,
        address tokenOut
    ) private returns (uint256) {
        uint256 depositIn = netTokenIn / 2;
        for (uint256 i = 0; i < 2; ++i) {
            uint256 balanceBefore = sy.balanceOf(wallet);

            uint256 preview = sy.previewDeposit(tokenIn, depositIn);
            uint256 actual = deposit(wallet, tokenIn, depositIn);
            uint256 earning = sy.balanceOf(wallet) - balanceBefore;

            assertEq(earning, actual, "previewDeposit: actual != earning");
            assertEq(preview, actual, "previewDeposit: preview != actual");
        }

        uint256 redeemIn = sy.balanceOf(wallet) / 2;
        uint256 totalAmountOut = 0;
        for (uint256 i = 0; i < 2; ++i) {
            uint256 balanceBefore = getBalance(wallet, tokenOut);

            uint256 preview = sy.previewRedeem(tokenOut, redeemIn);
            uint256 actual = redeem(wallet, tokenOut, redeemIn);
            uint256 earning = getBalance(wallet, tokenOut) - balanceBefore;

            assertEq(earning, actual, "previewRedeem: actual != earning");
            assertEq(preview, actual, "previewRedeem: preview != actual");

            totalAmountOut += actual;
        }
        return totalAmountOut;
    }

    function getTokensInForPreviewTest() internal view virtual returns (address[] memory) {
        return sy.getTokensIn();
    }

    function getTokensOutForPreviewTest() internal view virtual returns (address[] memory) {
        return sy.getTokensOut();
    }
}
