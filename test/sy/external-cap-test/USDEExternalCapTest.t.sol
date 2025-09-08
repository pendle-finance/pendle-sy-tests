// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {Test, console2 as console} from "forge-std/Test.sol";
import "./ExternalCapGatesTest.t.sol";

contract USDEExternalCapTest is ExternalCapGatesTest {
    address public constant SY_USDE = 0xf3DbdE762E5B67FaD09d88da3dfD38A83f753FFe;

    function setUpFork() internal override {
        vm.createSelectFork("ethereum");
    }

    function setUpSYExternalCap() internal override {
        sy = IStandardizedYield(SY_USDE);
        externalCap = IPTokenWithSupplyCap(address(sy));
        externalCapGates.setExternalCapContract(address(sy), address(externalCap));
    }
}
