// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {TestFoundation} from "../TestFoundation.sol";

// Fuzz tests for deposit/redeem and preview invariants.
abstract contract FuzzTest is TestFoundation {
    // Bound the fuzzed amount to realistic ranges.
    function _boundedAmount(address token, uint256 rand) internal view returns (uint256) {
        uint256 ref = refAmountFor(token);
        return bound(rand, 1, ref * 1000);
    }

    // Pick a valid tokenOut.
    function _pickValidTokenOut(address tokenOutCandidate) internal view returns (address) {
        if (sy.isValidTokenOut(tokenOutCandidate)) return tokenOutCandidate;
        address[] memory outs = sy.getTokensOut();
        return outs.length > 0 ? outs[0] : address(0);
    }

    // Pick a valid tokenIn.
    function _pickValidTokenIn(address tokenInCandidate) internal view returns (address) {
        if (sy.isValidTokenIn(tokenInCandidate)) return tokenInCandidate;
        address[] memory ins = sy.getTokensIn();
        return ins.length > 0 ? ins[0] : address(0);
    }

    // previewDeposit/previewRedeem ~= actuals
    function testFuzz_preview_matches_actual(address tokenInRandom, address tokenOutRandom, uint256 amountRandom) public {
        address tokenIn = _pickValidTokenIn(tokenInRandom);
        address tokenOut = _pickValidTokenOut(tokenOutRandom);
        vm.assume(tokenIn != address(0) && tokenOut != address(0));

        uint256 amountIn = _boundedAmount(tokenIn, amountRandom);

        address alice = wallets[0];
        fundToken(alice, tokenIn, amountIn);

        uint256 previewDepositAmt = sy.previewDeposit(tokenIn, amountIn);
        uint256 balanceBeforeSY = sy.balanceOf(alice);
        uint256 actualDepositAmt = deposit(alice, tokenIn, amountIn);
        uint256 earningDeposit = sy.balanceOf(alice) - balanceBeforeSY;

        uint8 syDecimals = sy.decimals();
        assertApproxEqAbsDecimal(earningDeposit, actualDepositAmt, 1, syDecimals, "deposit earning ~= actual");
        assertApproxEqAbsDecimal(previewDepositAmt, actualDepositAmt, 1, syDecimals, "previewDeposit ~= actual");

        uint256 sharesToRedeem = sy.balanceOf(alice);
        vm.assume(sharesToRedeem > 0);
        uint256 previewRedeemAmt = sy.previewRedeem(tokenOut, sharesToRedeem);
        uint256 balanceBeforeTokenOut = getBalance(alice, tokenOut);
        uint256 actualRedeemAmt = redeem(alice, tokenOut, sharesToRedeem);
        uint256 earningRedeem = getBalance(alice, tokenOut) - balanceBeforeTokenOut;

        uint8 outDecimals = getDecimals(tokenOut);
        assertApproxEqAbsDecimal(earningRedeem, actualRedeemAmt, 1, outDecimals, "redeem earning ~= actual");
        assertApproxEqAbsDecimal(previewRedeemAmt, actualRedeemAmt, 1, outDecimals, "previewRedeem ~= actual");
    }

    // Round-trip deposit→redeem should not revert and returns > 0.
    function testFuzz_round_trip_sanity(address tokenInRandom, address tokenOutRandom, uint256 amountRandom) public {
        address tokenIn = _pickValidTokenIn(tokenInRandom);
        address tokenOut = _pickValidTokenOut(tokenOutRandom);
        vm.assume(tokenIn != address(0) && tokenOut != address(0));

        uint256 amountIn = _boundedAmount(tokenIn, amountRandom);

        address alice = wallets[0];
        fundToken(alice, tokenIn, amountIn);

        uint256 shares = deposit(alice, tokenIn, amountIn);
        vm.assume(shares > 0);

        uint256 amountOut = redeem(alice, tokenOut, shares);
        assertGt(amountOut, 0, "redeem should return > 0");
    }
}


