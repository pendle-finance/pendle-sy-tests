// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {PendleKinetiqKHYPESY} from "pendle-sy/core/StandardizedYield/implementations/Kinetiq/PendleKinetiqKHYPESY.sol";
import {console} from "forge-std/console.sol";
import {SYTest} from "../../common/SYTest.t.sol";

contract KinetiqHYPETest is SYTest {
    function setUpFork() internal override {
        vm.createSelectFork("hyperevm", 9248471);
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        sy = IStandardizedYield(
            deployTransparentProxy(
                address(new PendleKinetiqKHYPESY()),
                address(1),
                abi.encodeCall(PendleKinetiqKHYPESY.initialize, (address(1)))
            )
        );

        vm.stopPrank();
    }

    function initializeSY() internal override {
        super.initializeSY();
        startToken = address(0);
    }

    function getPreviewTestAllowedEps() internal pure virtual override returns (uint256) {
        return 2e10;
    }

    function getSupplyCapType() internal pure virtual override returns (SupplyCapType) {
        return SupplyCapType.Underlying;
    }

    function refAmountFor(address token) internal view override returns (uint256) {
        if (token == NATIVE) {
            return 5000000000000000000 * 100;
        }
        return super.refAmountFor(token);
    }
}
