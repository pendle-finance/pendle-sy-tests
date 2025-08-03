// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {SYTest} from "../common/SYTest.t.sol";
import {PendleFXSaveSY} from "pendle-sy/core/StandardizedYield/implementations/FX/PendleFXSaveSY.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";

contract FxSaveTest is SYTest {
    function setUpFork() internal override {
        vm.createSelectFork("ethereum", 22564829);
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        address logic = address(new PendleFXSaveSY());
        vm.stopPrank();

        upgradeExistingProxy(
            0x13945B761B2Ed3219A497a46D15a8923f418d2ab,
            logic,
            abi.encodeWithSelector(PendleFXSaveSY.approveForCurvePool.selector)
        );
        sy = IStandardizedYield(0x13945B761B2Ed3219A497a46D15a8923f418d2ab);
    }

    function initializeSY() internal override {
        super.initializeSY();
        startToken = PendleFXSaveSY(payable(address(sy))).USDC();
    }
}
