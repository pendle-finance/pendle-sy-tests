// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {SYTest} from "../../common/SYTest.t.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {PendleLBTCBaseSYScaled18} from "pendle-sy/core/StandardizedYield/implementations/Lombard/PendleLBTCBaseSYScaled18.sol";
import {PendleLBTCExchangeRateOracle} from "pendle-sy/core/StandardizedYield/implementations/Lombard/PendleLBTCExchangeRateOracle.sol";
import {console} from "forge-std/console.sol";


contract LombardBaseScaled18Test is SYTest {
    function setUpFork() internal override {
        vm.createSelectFork("base", 33881697);
    }
    address public constant ORACLE = 0x1De9fcfeDF3E51266c188ee422fbA1c7860DA0eF;
    address public constant SY = 0x67E64AF30E04A7277ab2D4f09ACE3F77a15801F9;
    address public constant DECIMALS_WRAPPER_FACTORY = 0x992EC6A490A4B7f256bd59E63746951D98B29Be9;

    function deploySY() internal override {
        vm.startPrank(deployer);

        address oracle = address(new PendleLBTCExchangeRateOracle(ORACLE));
        address newImpl = address(new PendleLBTCBaseSYScaled18(DECIMALS_WRAPPER_FACTORY, oracle));
        vm.stopPrank();
        upgradeExistingProxy(
            SY,
            newImpl,
            abi.encode()
        );

        sy = IStandardizedYield(SY);

        // vm.prank(PendleLBTCBaseSY(payable(SY)).owner());
        // PendleLBTCBaseSY(payable(SY)).setExchangeRateOracle(oracle);

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
        return 2e12;
    }

}

    