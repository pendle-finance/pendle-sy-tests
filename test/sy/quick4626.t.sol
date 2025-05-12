// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {SYTest} from "../common/SYTest.t.sol";
import {
    PendleERC4626UpgSYV2,
    IERC4626
} from "pendle-sy/core/StandardizedYield/implementations/PendleERC4626UpgSYV2.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";

contract Quick4626Test is SYTest {
    function setUpFork() internal override {
        vm.createSelectFork("https://eth.llamarpc.com");
    }

    address public constant ERC4626_TOKEN = 0xe0a80d35bB6618CBA260120b279d357978c42BCE;

    function deploySY() internal override {
        vm.startPrank(deployer);

        address logic = address(new PendleERC4626UpgSYV2(ERC4626_TOKEN));
        sy = IStandardizedYield(
            deployTransparentProxy(
                logic,
                deployer,
                abi.encodeCall(PendleERC4626UpgSYV2.initialize, ("SY 4626", "SY-4626"))
            )
        );

        vm.stopPrank();
    }

    function initializeSY() internal override {
        super.initializeSY();
        startToken = IERC4626(ERC4626_TOKEN).asset();
    }
}
