// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {PendleBoringOneracle} from "pendle-core/oracles/internal/PendleBoringOneracle.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {ILBTCMinterBase} from "pendle-sy/interfaces/Lombard/ILBTCMinterBase.sol";
import {PendleLBTCBaseSY} from "pendle-sy/core/StandardizedYield/implementations/Lombard/PendleLBTCBaseSY.sol";

import {SYTest} from "../common/SYTest.t.sol";

contract PendleLBTCBaseSYTest is SYTest {
    IERC20 cbbtc;
    ILBTCMinterBase minter;

    function setUpFork() internal override {
        vm.createSelectFork("https://base.llamarpc.com");
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        address oneracle = address(new PendleBoringOneracle());

        address logic = address(new PendleLBTCBaseSY());
        sy = IStandardizedYield(
            deployTransparentProxy(logic, deployer, abi.encodeCall(PendleLBTCBaseSY.initialize, (oneracle)))
        );

        vm.stopPrank();
    }

    function initializeSY() internal override {
        super.initializeSY();

        PendleLBTCBaseSY _sy = PendleLBTCBaseSY(payable(address(sy)));
        cbbtc = IERC20(_sy.CBBTC());
        minter = ILBTCMinterBase(_sy.MINTER());

        startToken = _sy.yieldToken();
    }

    function addFakeRewards() internal override returns (bool[] memory) {}
}
