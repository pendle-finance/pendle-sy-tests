// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {PendleBoringOneracle} from "pendle-core/oracles/internal/PendleBoringOneracle.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {ILBTCMinterBase} from "pendle-sy/interfaces/Lombard/ILBTCMinterBase.sol";
import {PendleEBTCBeraSYV2} from "pendle-sy/core/StandardizedYield/implementations/EtherFi/PendleEBTCBeraSYV2.sol";
import {SYTest} from "../common/SYTest.t.sol";
import {console} from "forge-std/Test.sol";

contract PendleEBTCSYTest is SYTest {

    function setUpFork() internal override {
        vm.createSelectFork("ethereum");
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        console.log("123");
        address logic = address(new PendleEBTCBeraSYV2());
        console.log("456");
        sy = IStandardizedYield(
            deployTransparentProxy(logic, deployer, abi.encodeCall(PendleEBTCBeraSYV2.initialize, ()))
        );
        console.log("789");

        vm.stopPrank();
    }

    function initializeSY() internal override {
        // super.initializeSY();

        // PendleEBTCBeraSYV2 _sy = PendleEBTCBeraSYV2(payable(address(sy)));
        // startToken = _sy.yieldToken();
    }

    function addFakeRewards() internal override returns (bool[] memory) {}
}
