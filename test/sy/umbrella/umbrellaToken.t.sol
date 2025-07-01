// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {SYTest} from "../../common/SYTest.t.sol";
import {PendleUmbrellaStakeTokenSY} from "pendle-sy/core/StandardizedYield/implementations/Umbrella/PendleUmbrellaStakeTokenSY.sol";
import {console} from "forge-std/console.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UmbrellaTokenTest is SYTest {

    address public constant UMBRELLA_STAKE_TOKEN = 0x4f827A63755855cDf3e8f3bcD20265C833f15033;
    address public constant UMBRELLA_DISTRIBUTOR = 0x4655Ce3D625a63d30bA704087E52B4C31E38188B;

    function setUpFork() internal override {
        vm.createSelectFork("ethereum", 22765590);
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        sy = IStandardizedYield(
            deployTransparentProxy(
                address(new PendleUmbrellaStakeTokenSY(
                    UMBRELLA_STAKE_TOKEN,
                    UMBRELLA_DISTRIBUTOR
                )),
                deployer,
                abi.encodeCall(PendleUmbrellaStakeTokenSY.initialize, ("SY Umbrella Stake 4626", "SY-UMBRL-4626", deployer))
            )
        );

        vm.stopPrank();
    }

    function initializeSY() internal override {
        super.initializeSY();
        startToken = PendleUmbrellaStakeTokenSY(payable(address(sy))).asset();
    }

    function addFakeRewards() internal override returns (bool[] memory) {
        vm.roll(vm.getBlockNumber() + 1 days / 12);
        skip(1 days);
        return toArray(true);
    }

    function hasReward() internal pure override returns (bool) {
        return true;
    }
}