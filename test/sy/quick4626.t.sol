// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {SYTest} from "../common/SYTest.t.sol";
import {
    PendleERC4626UpgSYV2,
    IERC4626
} from "pendle-sy/core/StandardizedYield/implementations/PendleERC4626UpgSYV2.sol";
import { PendleERC4626NoRedeemUpgSY } from "pendle-sy/core/StandardizedYield/implementations/PendleERC4626NoRedeemUpgSY.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";

contract Quick4626Test is SYTest {
    function setUpFork() internal override {
        vm.createSelectFork("ethereum");
    }

    address public constant ERC4626_TOKEN = 0x6bf183243FdD1e306ad2C4450BC7dcf6f0bf8Aa6;
    bool public constant IS_REDEEMABLE = false;

    function deploySY() internal override {
        vm.startPrank(deployer);



        sy = IStandardizedYield(
            deployTransparentProxy(
                deployImpl(),
                deployer,
                abi.encodeCall(PendleERC4626UpgSYV2.initialize, ("SY 4626", "SY-4626"))
            )
        );

        vm.stopPrank();
    }

    function deployImpl() internal returns (address) {
        address logic1 =  address(new PendleERC4626NoRedeemUpgSY(ERC4626_TOKEN));
        address logic2 = address(new PendleERC4626UpgSYV2(ERC4626_TOKEN));
        return IS_REDEEMABLE ? logic2 : logic1;
    }

    function initializeSY() internal override {
        super.initializeSY();
        startToken = IERC4626(ERC4626_TOKEN).asset();
    }
}
