// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {SYTest} from "../../common/SYTest.t.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {PendleLBTCBaseSY} from "pendle-sy/core/StandardizedYield/implementations/Lombard/PendleLBTCBaseSY.sol";
import {
    PendleLBTCExchangeRateOracle
} from "pendle-sy/core/StandardizedYield/implementations/Lombard/PendleLBTCExchangeRateOracle.sol";
import {console} from "forge-std/console.sol";

contract LombardBaseTest is SYTest {
    function setUpFork() internal override {
        vm.createSelectFork("base", 33881222);
    }
    address public constant ORACLE = 0x1De9fcfeDF3E51266c188ee422fbA1c7860DA0eF;
    address public constant SY = 0xB261266Cb30c255CB9c73EBf4A3eaD9398D23AB4;

    function deploySY() internal override {
        vm.startPrank(deployer);

        address oracle = address(new PendleLBTCExchangeRateOracle(ORACLE));
        sy = IStandardizedYield(SY);
        vm.stopPrank();

        vm.prank(PendleLBTCBaseSY(payable(SY)).owner());
        PendleLBTCBaseSY(payable(SY)).setExchangeRateOracle(oracle);

        /// Preprocessing

        // console.log(IConcrete(payable(STRAT1)).owner());

        // vm.deal(IConcrete(payable(STRAT1)).owner(), 1 ether);
        // vm.prank(IConcrete(payable(STRAT1)).owner());
        // IConcrete(STRAT1).toggleWithdraw();
    }

    function initializeSY() internal override {
        super.initializeSY();
        startToken = sy.yieldToken();
    }

    // function skipPreviewTest() internal pure override virtual returns (bool) {
    //     return true;
    // }

    function getPreviewTestAllowedEps() internal pure virtual override returns (uint256) {
        return 1;
    }
}
