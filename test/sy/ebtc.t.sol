// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {PendleBoringOneracle} from "pendle-core/oracles/internal/PendleBoringOneracle.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {ILBTCMinterBase} from "pendle-sy/interfaces/Lombard/ILBTCMinterBase.sol";
import {PendleEBTCBeraSYV2} from "pendle-sy/core/StandardizedYield/implementations/EtherFi/PendleEBTCBeraSYV2.sol";
import {PendleRescalingTokenFactory} from "pendle-sy/core/Misc/PendleRescalingTokenFactory.sol";
import {SYTest} from "../common/SYTest.t.sol";
import {console} from "forge-std/Test.sol";

interface MockRoles {
    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) external view returns (bool);
}

contract PendleEBTCSYTest is SYTest {
    PendleRescalingTokenFactory factory;

    function setUpFork() internal override {
        vm.createSelectFork("ethereum");
    }

    function deploySY() internal override {
        vm.startPrank(deployer);
        factory = new PendleRescalingTokenFactory();

        address logic = address(new PendleEBTCBeraSYV2(address(factory)));
        sy = IStandardizedYield(
            deployTransparentProxy(logic, deployer, abi.encodeCall(PendleEBTCBeraSYV2.initialize, ()))
        );
        vm.stopPrank();

        vm.mockCall(
            0x829675330fdcEE01022983493e71F73fb53eaB45,
            MockRoles.canCall.selector,
            abi.encode(1)
        );
    }

    function initializeSY() internal override {
        // super.initializeSY();

        // PendleEBTCBeraSYV2 _sy = PendleEBTCBeraSYV2(payable(address(sy)));
        // startToken = _sy.yieldToken();
    }

    function addFakeRewards() internal override returns (bool[] memory) {}
}
