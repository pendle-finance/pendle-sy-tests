// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {SYTest} from "../../common/SYTest.t.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {PendleL2LRTSY} from "pendle-sy/core/StandardizedYield/implementations/PendleL2LRTSY.sol";
import {
    PendleLBTCExchangeRateOracle
} from "pendle-sy/core/StandardizedYield/implementations/Lombard/PendleLBTCExchangeRateOracle.sol";
import {console} from "forge-std/console.sol";

contract LombardL2LRTTest is SYTest {
    function setUpFork() internal override {
        vm.createSelectFork("base", 33881222);
    }
    address public constant ORACLE = 0x1De9fcfeDF3E51266c188ee422fbA1c7860DA0eF;
    address public constant SY = 0xaee0844A089d4De3677CDB1d0AE4595a89963E78;

    function deploySY() internal override {
        vm.startPrank(deployer);

        address oracle = address(new PendleLBTCExchangeRateOracle(ORACLE));
        sy = IStandardizedYield(SY);
        vm.stopPrank();

        vm.prank(PendleL2LRTSY(payable(SY)).owner());
        PendleL2LRTSY(payable(SY)).setExchangeRateOracle(oracle);

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
