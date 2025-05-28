// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {SYTest} from "../common/SYTest.t.sol";
import {
    PendleMellowRstETHSY,
    IERC4626,
    PendleERC4626NoRedeemUpgSY
} from "pendle-sy/core/StandardizedYield/implementations/Mellow/PendleMellowRstETHSY.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";

contract RstETHTest is SYTest {
    function setUpFork() internal override {
        vm.createSelectFork("ethereum");
    }

    address public constant ERC4626_TOKEN = 0x7a4EffD87C2f3C55CA251080b1343b605f327E3a;

    function deploySY() internal override {
        vm.startPrank(deployer);

        address logic = address(new PendleMellowRstETHSY());
        sy = IStandardizedYield(
            deployTransparentProxy(
                logic,
                deployer,
                abi.encodeCall(PendleERC4626NoRedeemUpgSY.initialize, ("SY RSTETH", "SY-RSTETH"))
            )
        );

        vm.stopPrank();
    }

    function initializeSY() internal override {
        super.initializeSY();
        startToken = IERC4626(ERC4626_TOKEN).asset();
    }
}
