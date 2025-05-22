// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {SYWithAdapterTest} from "../common/SYWithAdapterTest.t.sol";
import {
    PendleERC4626UpgSYV2,
    IERC4626
} from "pendle-sy/core/StandardizedYield/implementations/PendleERC4626UpgSYV2.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {PendleERC4626Adapter} from "pendle-sy/core/StandardizedYield/implementations/PendleERC4626Adapter.sol";
import {console} from "forge-std/console.sol";

contract SLPETHTest is SYWithAdapterTest {
    function setUpFork() internal override {
        vm.createSelectFork("https://eth.llamarpc.com");
    }

    address public constant SLP_ETH = 0x3976d71e7DdFBaB9bD120Ec281B7d35fa0F28528;
    address public constant SOMETHING_4626_ETH = 0xa684EAf215ad323452e2B2bF6F817d4aa5C116ab;

    function deploySY() internal override {
        vm.startPrank(deployer);
        address adapter = address(new PendleERC4626Adapter(SOMETHING_4626_ETH, false));
        sy = IStandardizedYield(deploySYWithAdapter(AdapterType.ERC4626_NoRedeem, SLP_ETH, "SY SLP ETH", "SY-slpETH", adapter));

        vm.stopPrank();
    }
}
