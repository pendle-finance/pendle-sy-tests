// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {PendleUniBTCBeraSYUpgScaled18} from "pendle-sy/core/StandardizedYield/implementations/Bedrock/PendleUniBTCBeraSYUpgScaled18.sol";
import {console} from "forge-std/console.sol";
import {SYTest} from "../../common/SYTest.t.sol";

contract UniBTCScaled18Test is SYTest {
    function setUpFork() internal override {
        vm.createSelectFork("berachain");
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        sy = IStandardizedYield(
            deployTransparentProxy(
                address(new PendleUniBTCBeraSYUpgScaled18()),
                address(1),
                abi.encodeCall(PendleUniBTCBeraSYUpgScaled18.initialize, ())
            )
        );

        vm.stopPrank();
    }

    function initializeSY() internal override {
        super.initializeSY();
        startToken = PendleUniBTCBeraSYUpgScaled18(payable(address(sy))).WBTC();
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
