// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {SYWithAdapterTest} from "../../../common/SYWithAdapterTest.t.sol";
import {PendleUSDSAdapter} from "../../adapters/PendleUSDSAdapter.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";

contract NZAERC4626NoRdeemSYTest is SYWithAdapterTest {
    address internal constant SUSDS = 0xa3931d71877C0E7a3148CB7Eb4463524FEc27fbD;

    function setUpFork() internal override {
        vm.createSelectFork("ethereum");
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        address adapter = address(new PendleUSDSAdapter());
        sy = IStandardizedYield(
            deploySYWithAdapter(AdapterType.ERC4626_NoRedeem, SUSDS, "SY Sky SUSDS", "SY-SUSDS", adapter)
        );

        vm.stopPrank();
    }
}
