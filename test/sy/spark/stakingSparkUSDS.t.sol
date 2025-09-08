// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {PendleStakingSPKUSDSSY} from "pendle-sy/core/StandardizedYield/implementations/Sky/PendleStakingSPKUSDSSY.sol";
import {console} from "forge-std/console.sol";
import {SYTest} from "../../common/SYTest.t.sol";

contract StakingSparkUSDSSYTest is SYTest {
    function setUpFork() internal override {
        vm.createSelectFork("ethereum", 22837998);
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        sy = IStandardizedYield(
            deployTransparentProxy(
                address(new PendleStakingSPKUSDSSY()),
                deployer,
                abi.encodeCall(PendleStakingSPKUSDSSY.initialize, (deployer))
            )
        );

        vm.stopPrank();
    }

    function initializeSY() internal override {
        super.initializeSY();
        startToken = PendleStakingSPKUSDSSY(payable(address(sy))).USDS();
    }

    function addFakeRewards() internal virtual override returns (bool[] memory) {
        vm.roll(vm.getBlockNumber() + 1 days / 12);
        skip(1 days);
        return toArray(true);
    }

    function hasReward() internal pure virtual override returns (bool) {
        return true;
    }
}
