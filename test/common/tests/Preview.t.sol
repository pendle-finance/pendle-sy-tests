// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {console} from "forge-std/Test.sol";

import {TestFoundation} from "../TestFoundation.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

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

            console.log("[CHECK REQUIRED] ================= Test:", it + 1, " ====================");
            console.log("Testing ", getSymbol(tokenIn), "=>", getSymbol(tokenOut));
            console.log("Amount in :", amountIn);

            fundToken(alice, tokenIn, amountIn);

            uint256 amountOut = _executePreviewTest(alice, tokenIn, amountIn, tokenOut, true);
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
        address tokenOut,
        bool inFirstExecution
    ) private returns (uint256) {
        uint256 depositIn = netTokenIn / 2;
        for (uint256 i = 0; i < 2; ++i) {
            uint256 balanceBefore = sy.balanceOf(wallet);

            uint256 preview = sy.previewDeposit(tokenIn, depositIn);
            uint256 actual = deposit(wallet, tokenIn, depositIn);
            uint256 earning = sy.balanceOf(wallet) - balanceBefore;

            assertApprox(earning, actual, "previewDeposit: actual != earning | 59");
            assertApprox(preview, actual, "previewDeposit: preview != actual | 60");
        }

        uint256 redeemIn = sy.balanceOf(wallet) / 2;
        uint256 totalAmountOut = 0;
        for (uint256 i = 0; i < 2; ++i) {
            uint256 balanceBefore = getBalance(wallet, tokenOut);

            uint256 preview = sy.previewRedeem(tokenOut, redeemIn);
            uint256 actual = redeem(wallet, tokenOut, redeemIn);
            uint256 earning = getBalance(wallet, tokenOut) - balanceBefore;

            assertApprox(earning, actual, "previewRedeem: actual != earning | 72");
            assertApprox(preview, actual, "previewRedeem: preview != actual | 73");

            totalAmountOut += actual;
        }

        if (inFirstExecution && sy.isValidTokenIn(tokenOut) && sy.isValidTokenOut(tokenIn)) {
            uint256 amountRoundTrip = _executePreviewTest(
                wallet,
                tokenOut,
                totalAmountOut,
                tokenIn,
                false
            );

            uint256 delta = (amountRoundTrip > netTokenIn)
                ? amountRoundTrip - netTokenIn
                : netTokenIn - amountRoundTrip;

            console.log("Round trip:", amountRoundTrip);
            assertLt(delta, 10, "Amount round trip should be close to netTokenIn");
        }

        return totalAmountOut;
    }

    function getTokensInForPreviewTest() internal view virtual returns (address[] memory) {
        return sy.getTokensIn();
    }

    function getTokensOutForPreviewTest() internal view virtual returns (address[] memory) {
        return sy.getTokensOut();
    }

    function getPreviewTestAllowedDiff() internal pure virtual returns (uint256) {
        return 0;
    }

    function assertApprox(
        uint256 actual,
        uint256 expected,
        string memory message
    ) internal pure {
        uint256 allowDiff = getPreviewTestAllowedDiff();


        message = string.concat(
            message,
            " | actual: ",
            Strings.toString(actual),
            ", expected: ",
            Strings.toString(expected)
        );

        if (allowDiff == 0) {
            assertEq(actual, expected, message);
        } else {
            assertLt(
                actual > expected ? actual - expected : expected - actual,
                allowDiff + 1,
                message
            );
        }
    }
}
