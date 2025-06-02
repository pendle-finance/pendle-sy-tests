// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {SYWithAdapterTest} from "../../../common/SYWithAdapterTest.t.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";


contract AZAERC4626Test is SYWithAdapterTest {
    address internal constant ZERO_ADDRESS = address(0);
    address internal constant ERC4626 = 0xe0a80d35bB6618CBA260120b279d357978c42BCE;

    function setUpFork() internal override {
        vm.createSelectFork("ethereum");
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        sy = IStandardizedYield(
            deploySYWithAdapter(AdapterType.ERC4626, ERC4626, "SY EVK USDC", "SY-EVK-USDC", ZERO_ADDRESS)
        );

        vm.stopPrank();
    }
}