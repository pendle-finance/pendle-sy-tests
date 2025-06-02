// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {SYWithAdapterTest} from "../../../common/SYWithAdapterTest.t.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";


contract AZAERC20SYTest is SYWithAdapterTest {
    address internal constant ZERO_ADDRESS = address(0);
    address internal constant ERC20 = 0xdC035D45d973E3EC169d2276DDab16f1e407384F;

    function setUpFork() internal override {
        vm.createSelectFork("ethereum");
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        sy = IStandardizedYield(
            deploySYWithAdapter(AdapterType.ERC20, ERC20, "SY USDS", "SY-USDS", ZERO_ADDRESS)
        );

        vm.stopPrank();
    }
}