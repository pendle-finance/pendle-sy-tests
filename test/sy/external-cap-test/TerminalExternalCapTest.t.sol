// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {Test, console2 as console} from "forge-std/Test.sol";
import {
    PendleTerminalExternalCap
} from "pendle-sy/core/StandardizedYield/implementations/Terminal/PendleTerminalExternalCap.sol";
import "./ExternalCapGatesTest.t.sol";

contract TerminalExternalCapTest is ExternalCapGatesTest {
    address public constant SY_TBTC = 0x0d298432833E0d60372C70801FEaf868eB7451b3;

    function setUpFork() internal override {
        vm.createSelectFork("ethereum");
    }

    function setUpSYExternalCap() internal override {
        sy = IStandardizedYield(SY_TBTC);
        externalCap = IPTokenWithSupplyCap(new PendleTerminalExternalCap(address(sy)));
        externalCapGates.setExternalCapContract(address(sy), address(externalCap));
    }
}
