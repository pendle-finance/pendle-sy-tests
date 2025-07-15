// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {SYTest} from "../common/SYTest.t.sol";
import {
    PendleL2LRTUpgSY
} from "pendle-sy/core/StandardizedYield/implementations/PendleL2LRTUpgSY.sol";
import {PendleRedStoneRateOracleAdapter} from "pendle-core/oracles/internal/PendleRedStoneRateOracleAdapter.sol";

import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";


contract L2LRTTest is SYTest {
    function setUpFork() internal override {
        vm.createSelectFork("base");
    }

    address public constant L2_LRT_TOKEN = 0xB6fe221Fe9EeF5aBa221c348bA20A1Bf5e73624c;
    address public constant CHAINLINK = 0x1E6A29666288a310326B37d823Fe4Ea3937424D2;

    function deploySY() internal override {
        vm.startPrank(deployer);

        address oracle = address(new PendleRedStoneRateOracleAdapter(
            CHAINLINK,
            18
        ));

        sy = IStandardizedYield(
            deployTransparentProxy(
                address(new PendleL2LRTUpgSY(L2_LRT_TOKEN, address(0), 18)),
                deployer,
                abi.encodeCall(PendleL2LRTUpgSY.initialize, ("SY L2LRT", "SY-L2LRT", oracle, deployer))
            )
        );

        vm.stopPrank();
    }

    
    function initializeSY() internal override {
        super.initializeSY();
        startToken = L2_LRT_TOKEN;
    }
}