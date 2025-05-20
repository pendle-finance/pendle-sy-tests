// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {PendleBoringOneracle} from "pendle-core/oracles/internal/PendleBoringOneracle.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {ILBTCMinterBase} from "pendle-sy/interfaces/Lombard/ILBTCMinterBase.sol";
import {PendleLBTCBaseSYV2} from "pendle-sy/core/StandardizedYield/implementations/Lombard/PendleLBTCBaseSYV2.sol";
import {PendleRescalingTokenFactory} from "pendle-sy/core/Misc/PendleRescalingTokenFactory.sol";
import {SYTest} from "../common/SYTest.t.sol";

contract PendleLBTCBaseSYTest is SYTest {
    IERC20 cbbtc;
    ILBTCMinterBase minter;
    PendleRescalingTokenFactory factory;


    function setUpFork() internal override {
        vm.createSelectFork("base");
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        factory = new PendleRescalingTokenFactory();

        address logic = address(new PendleLBTCBaseSYV2(address(factory)));
        sy = IStandardizedYield(
            deployTransparentProxy(logic, deployer, abi.encodeCall(PendleLBTCBaseSYV2.initialize, ()))
        );

        vm.stopPrank();
    }

    function initializeSY() internal override {
        super.initializeSY();

        PendleLBTCBaseSYV2 _sy = PendleLBTCBaseSYV2(payable(address(sy)));
        cbbtc = IERC20(_sy.CBBTC());
        minter = ILBTCMinterBase(_sy.MINTER());

        startToken = _sy.yieldToken();
    }

    function addFakeRewards() internal override returns (bool[] memory) {}
}
