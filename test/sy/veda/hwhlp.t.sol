// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {PendleHwHLPSY} from "pendle-sy/core/StandardizedYield/implementations/Veda/PendleHwHLPSY.sol";
import {console} from "forge-std/console.sol";
import {SYTest} from "../../common/SYTest.t.sol";

contract HwHLPTest is SYTest {
    function setUpFork() internal override {
        vm.createSelectFork("ethereum", 22929161);
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        sy = IStandardizedYield(
            deployTransparentProxy(
                address(new PendleHwHLPSY()),
                address(1),
                abi.encodeCall(PendleHwHLPSY.initialize, ("SY HWHLP", "SY HWHLP", deployer, 10 ** 12))
            )
        );

        vm.stopPrank();
    }

    function initializeSY() internal override {
        super.initializeSY();
        startToken = PendleHwHLPSY(payable(address(sy))).USDT();
    }

    function getPreviewTestAllowedEps() internal pure virtual override returns (uint256) {
        return 1e12;
    }

    function hasSupplyCap() internal pure virtual override returns (bool) {
        return true;
    }
}
