// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
// import {PendleUniBTCBeraSYUpgScaled18} from "pendle-sy/core/StandardizedYield/implementations/Bedrock/PendleUniBTCBeraSYUpgScaled18.sol";
import {PendleSolvBNBBTCSY} from "pendle-sy/core/StandardizedYield/implementations/Solv/V2/PendleSolvBNBBTCSY.sol";
import {console} from "forge-std/console.sol";
import {SYTest} from "../../common/SYTest.t.sol";

contract SolvTest is SYTest {
    function setUpFork() internal override {
        vm.createSelectFork("bsc", 55814314);
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        address newImpl = address(new PendleSolvBNBBTCSY());
        vm.stopPrank();

        sy = IStandardizedYield(0x58b4441B97C577B66E46AA155e04dC4652FD0D34);
        upgradeExistingProxy(address(sy), newImpl, abi.encode());
    }

    function initializeSY() internal override {
        super.initializeSY();
        startToken = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
    }

    function getPreviewTestAllowedEps() internal pure virtual override returns (uint256) {
        return 1e12; // 1e-6
    }

    // function getSupplyCapType() internal pure virtual override returns (SupplyCapType) {
    //     return SupplyCapType.Underlying;
    // }

    // function refAmountFor(address token) internal view override returns (uint256) {
    //     if (token == NATIVE) {
    //         return 5000000000000000000 * 100;
    //     }
    //     return super.refAmountFor(token);
    // }
}
