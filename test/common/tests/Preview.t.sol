// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {console} from "forge-std/Test.sol";
import {stdMath} from "forge-std/StdMath.sol";
import {PMath} from "pendle-core/core/libraries/math/PMath.sol";

import {TestFoundation} from "../TestFoundation.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

abstract contract PreviewTest is TestFoundation {
    struct PreviewDepositThenRedeemTestParam {
        address tokenIn;
        uint256 netTokenIn;
        address tokenOut;
        bool shouldCheck;
    }

    function test_preview_depositThenRedeem() public {
        PreviewDepositThenRedeemTestParam[] memory testParams = _genPreviewDepositThenRedeemTestParams();
        console.log("[-----test_preview_depositThenRedeem-----]");

        address alice = wallets[0];
        uint256 maxRoundTripDeltaAbs = 0;
        uint256 maxRoundTripDeltaRel = 0;
        uint256 totalRoundTripDeltaRel = 0;

        uint256 cntRoundTripTest = 0;

        for (uint256 i = 0; i < testParams.length; ++i) {

            address tokenIn = testParams[i].tokenIn;
            address tokenOut = testParams[i].tokenOut;
            uint256 amountIn = testParams[i].netTokenIn;

            if (testParams[i].shouldCheck) {
                checkRequired(string.concat("Test ", vm.toString(i + 1)));
                console.log("Testing ", getSymbol(tokenIn), "=>", getSymbol(tokenOut));
                console.log("Amount in :", amountIn);
            }

            fundToken(alice, tokenIn, amountIn);

            (
                uint256 amountOut,
                bool doRoundTrip,
                uint256 amountRoundTrip,
                uint256 roundTripDeltaAbs
            ) = _executePreviewTest(alice, tokenIn, amountIn, tokenOut);

            if (doRoundTrip) {
                cntRoundTripTest++;
            }

            uint256 roundTripDeltaRel = PMath.divDown(roundTripDeltaAbs, amountIn);
            maxRoundTripDeltaAbs = PMath.max(maxRoundTripDeltaAbs, roundTripDeltaAbs);
            maxRoundTripDeltaRel = PMath.max(maxRoundTripDeltaRel, roundTripDeltaRel);
            totalRoundTripDeltaRel += roundTripDeltaRel;

            if (testParams[i].shouldCheck) {
                console.log("Amount out:", amountOut);
                if (doRoundTrip) {
                    console.log("Amount round trip:", amountRoundTrip);
                    console.log("Round trip delta abs:", roundTripDeltaAbs);
                    console.log("Round trip delta rel: %18e", roundTripDeltaRel);
                } else {
                    console.log("No round trip possible for this pair");
                }
                console.log("");
            }
        }

        checkRequired("Summary");
        console.log("Total tests                    :", testParams.length);
        console.log("Total round trip tests         :", cntRoundTripTest);
        // console.log("Max round trip delta abs:", maxRoundTripDeltaAbs);
        console.log("Max round trip delta rel       : %18e", maxRoundTripDeltaRel);
        console.log("Average round trip delta rel   : %18e", totalRoundTripDeltaRel / cntRoundTripTest);

        console.log("");
    }

    PreviewDepositThenRedeemTestParam[] params;
    // override this if you want a different set of test parameters
    function _genPreviewDepositThenRedeemTestParams()
        internal
        virtual
        returns (PreviewDepositThenRedeemTestParam[] memory)
    {
        uint256 DENOM = 17;
        uint256 NUMER = 3;
        uint256 NUM_TESTS_PER_PAIR = 5;

        address[] memory allTokensIn = getTokensInForPreviewTest();
        address[] memory allTokensOut = getTokensOutForPreviewTest();
        delete params;

        uint256 divBy = 1;
        for (uint256 i = 0; i < allTokensIn.length; ++i) {
            for (uint256 j = 0; j < allTokensOut.length; ++j) {
                uint256 refAmount = refAmountFor(allTokensIn[i]);
                for (uint256 numTest = 0; numTest < NUM_TESTS_PER_PAIR; ++numTest) {
                    uint256 amountIn = refAmount / divBy;
                    divBy = (divBy * NUMER) % DENOM;

                    params.push() = PreviewDepositThenRedeemTestParam({
                        tokenIn: allTokensIn[i],
                        netTokenIn: amountIn,
                        tokenOut: allTokensOut[j],
                        shouldCheck: numTest == 0
                    });
                }
            }
        }

        return params;
    }

    function _executePreviewTest(
        address wallet,
        address tokenIn,
        uint256 netTokenIn,
        address tokenOut
    ) private returns (uint256 totalAmountOut, bool doRoundTrip, uint256 amountRoundTrip, uint256 roundTripDeltaAbs) {
        totalAmountOut = _executePreviewTestOnce(wallet, tokenIn, netTokenIn, tokenOut);

        doRoundTrip = sy.isValidTokenIn(tokenOut) && sy.isValidTokenOut(tokenIn);
        if (doRoundTrip) {
            amountRoundTrip = _executePreviewTestOnce(wallet, tokenOut, totalAmountOut, tokenIn);
            roundTripDeltaAbs = stdMath.delta(amountRoundTrip, netTokenIn);

            if (!hasFee()) {
                assertApprox(
                    amountRoundTrip,
                    netTokenIn,
                    getDecimals(tokenIn),
                    "amountRoundTrip should be close to netTokenIn | 50"
                );
            }
        }
    }

    function _executePreviewTestOnce(
        address wallet,
        address tokenIn,
        uint256 netTokenIn,
        address tokenOut
    ) internal returns (uint256) {
        uint256 depositIn = netTokenIn / 2;
        for (uint256 i = 0; i < 2; ++i) {
            uint256 balanceBefore = sy.balanceOf(wallet);

            uint256 preview = sy.previewDeposit(tokenIn, depositIn);
            uint256 actual = deposit(wallet, tokenIn, depositIn);
            uint256 earning = sy.balanceOf(wallet) - balanceBefore;
            uint8 decimals = sy.decimals();

            assertApprox(earning, actual, decimals, "previewDeposit: actual != earning | 59");
            assertApprox(preview, actual, decimals, "previewDeposit: preview != actual | 60");
        }

        uint256 redeemIn = sy.balanceOf(wallet) / 2;
        uint256 totalAmountOut = 0;
        for (uint256 i = 0; i < 2; ++i) {
            uint256 balanceBefore = getBalance(wallet, tokenOut);

            uint256 preview = sy.previewRedeem(tokenOut, redeemIn);
            uint256 actual = redeem(wallet, tokenOut, redeemIn);
            uint256 earning = getBalance(wallet, tokenOut) - balanceBefore;
            uint8 decimals = getDecimals(tokenOut);

            assertApprox(earning, actual, decimals, "previewRedeem: actual != earning | 72");
            assertApprox(preview, actual, decimals, "previewRedeem: preview != actual | 73");

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

    function getPreviewTestAllowedDiff() internal pure virtual returns (uint256) {
        return 0;
    }

    function assertApprox(uint256 actual, uint256 expected, uint8 decimal, string memory message) internal pure {
        uint256 allowDiff = getPreviewTestAllowedDiff();
        if (allowDiff == 0) {
            assertEqDecimal(actual, expected, decimal, message);
        } else {
            uint256 allowDiffAbs = PMath.max(1, PMath.mulDown(expected, allowDiff));
            assertApproxEqAbsDecimal(actual, expected, allowDiffAbs, decimal, message);
        }
    }

    function hasFee() internal pure virtual returns (bool) {
        return false;
    }
}
