// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {SYTest} from "../../common/SYTest.t.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
// PendleCornLBTCSY
import {PendleCornLBTCSY} from "pendle-sy/core/StandardizedYield/implementations/Corn/PendleCornLBTCSY.sol";
import {PendleLBTCExchangeRateOracle} from "pendle-sy/core/StandardizedYield/implementations/Lombard/PendleLBTCExchangeRateOracle.sol";
import {console} from "forge-std/console.sol";


contract LombardCornLBTCSYTest is SYTest {
    function setUpFork() internal override {
        vm.createSelectFork("ethereum", 23087451);
    }
    address public constant ORACLE = 0x1De9fcfeDF3E51266c188ee422fbA1c7860DA0eF;
    address public constant SY = 0x9d6Ec7a7B051B32205F74B140A0fa6f09D7F223E;

    function deploySY() internal override {
        vm.startPrank(deployer);

        address oracle = address(new PendleLBTCExchangeRateOracle(ORACLE));
        sy = IStandardizedYield(SY);
        vm.stopPrank();

        vm.prank(PendleCornLBTCSY(payable(SY)).owner());
        PendleCornLBTCSY(payable(SY)).setExchangeRateOracle(oracle);

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

    