// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {ISophonFarming as ISophonFarming_} from "pendle-sy/interfaces/Sophon/ISophonFarming.sol";
import {PendleSophonFarmingSY} from "pendle-sy/core/StandardizedYield/implementations/Sophon/PendleSophonFarmingSY.sol";
import {
    PendleSophonPointManager
} from "pendle-sy/core/StandardizedYield/implementations/Sophon/PendleSophonPointManager.sol";

import {SYTest} from "../common/SYTest.t.sol";

interface ISophonFarming is ISophonFarming_ {
    function setUsersWhitelisted(address _userAdmin, address[] memory _users, bool _isInWhitelist) external;
}

contract PendleSophonFarmingSYTest is SYTest {
    address internal constant SOPHON_FARMING = 0xEfF8E65aC06D7FE70842A4d54959e8692d6AE064;
    address internal constant SOPHON_FARMING_OWNER = 0x3b181838Ae9DB831C17237FAbD7c10801Dd49fcD;
    uint256 internal constant USDC_PID = 7;

    PendleSophonPointManager pm;
    ISophonFarming sophonFarming;
    uint256 pid;

    function setUpFork() internal override {
        vm.createSelectFork("https://eth.llamarpc.com", 20438259);
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        pm = PendleSophonPointManager(vm.computeCreateAddress(deployer, vm.getNonce(deployer) + 1));
        sy = IStandardizedYield(
            address(new PendleSophonFarmingSY("Sophon USDC", "Sophon USDC", SOPHON_FARMING, USDC_PID, address(pm)))
        );
        assertEq(address(pm), address(new PendleSophonPointManager(SOPHON_FARMING, USDC_PID, address(sy))));

        vm.stopPrank();
    }

    function initializeSY() internal override {
        super.initializeSY();

        PendleSophonFarmingSY _sy = PendleSophonFarmingSY(payable(address(sy)));
        sophonFarming = ISophonFarming(_sy.sophonFarming());
        pid = _sy.pid();

        assertEq(address(sophonFarming), SOPHON_FARMING);
        assertEq(pid, USDC_PID);

        vm.prank(deployer);
        pm.addWhitelistedAddress(address(sy));

        vm.prank(SOPHON_FARMING_OWNER);
        sophonFarming.setUsersWhitelisted(address(pm), toArray(address(pm)), true);

        vm.prank(SOPHON_FARMING_OWNER);
        sophonFarming.setUsersWhitelisted(address(sy), toArray(address(sy)), true);

        startToken = sy.yieldToken();
    }

    function addFakeRewards() internal override returns (bool[] memory) {
        vm.roll(vm.getBlockNumber() + 1 days / 12);
        skip(1 days);
        return toArray(true);
    }

    function getBalance(address wallet, address token) internal view override returns (uint256) {
        if (token == address(pm)) {
            return sophonFarming.pendingPoints(pid, wallet);
        } else {
            return super.getBalance(wallet, token);
        }
    }
}
