// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {SYTest} from "../../common/SYTest.t.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {PendleConcreteLBTCSY} from "pendle-sy/core/StandardizedYield/implementations/Concrete/PendleConcreteLBTCSY.sol";
import {
    PendleLBTCExchangeRateOracle
} from "pendle-sy/core/StandardizedYield/implementations/Lombard/PendleLBTCExchangeRateOracle.sol";
import {console} from "forge-std/console.sol";

interface IConcrete {
    function owner() external view returns (address);

    function unpause() external;

    function toggleWithdraw() external;
}

contract LombardConcreteTest is SYTest {
    function setUpFork() internal override {
        vm.createSelectFork("ethereum", 23087451);
    }

    address public constant ORACLE = 0x1De9fcfeDF3E51266c188ee422fbA1c7860DA0eF;
    address public constant CONCRETE_VAULT = 0x34bdbA9b3D8E3073Eb4470cd4C031C2e39C32DA8;
    address public constant SY = 0xac614884b52DbAB8728476b5d50F0D672BaED31F;
    address public constant STRAT1 = 0x34bdbA9b3D8E3073Eb4470cd4C031C2e39C32DA8;

    function deploySY() internal override {
        vm.startPrank(deployer);

        address oracle = address(new PendleLBTCExchangeRateOracle(ORACLE));
        address newImpl = address(new PendleConcreteLBTCSY(CONCRETE_VAULT, oracle));
        vm.stopPrank();
        upgradeExistingProxy(SY, newImpl, abi.encode());

        sy = IStandardizedYield(SY);

        /// Preprocessing
        vm.prank((IConcrete(payable(CONCRETE_VAULT)).owner()));
        IConcrete(payable(CONCRETE_VAULT)).unpause();

        // console.log(IConcrete(payable(STRAT1)).owner());

        // vm.deal(IConcrete(payable(STRAT1)).owner(), 1 ether);
        // vm.prank(IConcrete(payable(STRAT1)).owner());
        // IConcrete(STRAT1).toggleWithdraw();
    }

    function initializeSY() internal override {
        super.initializeSY();
        startToken = sy.yieldToken();
    }

    function skipPreviewTest() internal pure virtual override returns (bool) {
        return true;
    }
}
