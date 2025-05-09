// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {SYWithAdapterTest} from "../../common/SYWithAdapterTest.t.sol";
import {PendleUSDSAdapter} from "./adapters/PendleUSDSAdapter.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";

contract PendleUSDSSYTest is SYWithAdapterTest {
    address internal constant USDS = 0xdC035D45d973E3EC169d2276DDab16f1e407384F;

    function setUpFork() internal override {
        vm.createSelectFork("ethereum", 22442361);
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        address adapter = address(new PendleUSDSAdapter());
        sy = IStandardizedYield(deploySYWithAdapter(AdapterType.ERC20, USDS, "SY Sky USDS", "SY-USDS", adapter));

        vm.stopPrank();
    }

    function fundToken(address wallet, address token, uint256 amount) internal override {
        super.fundToken(wallet, token, amount);
    }
}
