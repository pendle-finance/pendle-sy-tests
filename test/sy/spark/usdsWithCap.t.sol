// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
// import {PendleUniBTCBeraSYUpgScaled18} from "pendle-sy/core/StandardizedYield/implementations/Bedrock/PendleUniBTCBeraSYUpgScaled18.sol";
import {PendleUSDSSYWithCap} from "pendle-sy/core/StandardizedYield/implementations/Sky/PendleUSDSSYWithCap.sol";
import {console} from "forge-std/console.sol";
import {SYTest} from "../../common/SYTest.t.sol";
contract UsdsWithCap is SYTest {
    function setUpFork() internal override {
        vm.createSelectFork("ethereum", 23036169);
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        sy = IStandardizedYield(
            0x508deFdB5DD2aDEEfe36f58fdCD75d6efa36697b
        );
        address newImpl = address(new PendleUSDSSYWithCap(sy.yieldToken()));
        vm.stopPrank();
        
        upgradeExistingProxy(address(sy), newImpl, abi.encode());

        PendleUSDSSYWithCap c = PendleUSDSSYWithCap(payable(address(sy)));

        vm.startPrank(c.owner());

        c.updateSupplyCap(1e27); // Set supply cap to 1 million USDS

        vm.stopPrank();
    }

    function initializeSY() internal override {
        super.initializeSY();
        startToken = sy.yieldToken();
    }

    function getPreviewTestAllowedEps() internal pure virtual override returns (uint256) {
        return 1e12; // 1e-6
    }

    function getSupplyCapType() internal pure virtual override returns (SupplyCapType) {
        return SupplyCapType.BuiltIn;
    }

    // function refAmountFor(address token) internal view override returns (uint256) {
    //     if (token == NATIVE) {
    //         return 5000000000000000000 * 100;
    //     }
    //     return super.refAmountFor(token);
    // }
}
