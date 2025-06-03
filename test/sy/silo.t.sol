// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {SYTest} from "../common/SYTest.t.sol";
import {PendleSiloV2SY, IERC4626} from "pendle-sy/core/StandardizedYield/implementations/Silo/PendleSiloV2SY.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {PendleDecimalsWrapperFactory} from "pendle-sy/core/misc/PendleDecimalsWrapperFactory.sol";

contract SiloTest is SYTest {
    function setUpFork() internal override {
        vm.createSelectFork("sonic", 27202595);
    }

    address public constant SILO_VAULT = 0xF6F87073cF8929C206A77b0694619DC776F89885;
    address public constant INCENTIVE_CONTROLLER = 0x306Fad9009b104a323A232238afffD1f261bD05c;

    function deploySY() internal override {
        vm.startPrank(deployer);

        PendleDecimalsWrapperFactory factory = new PendleDecimalsWrapperFactory(deployer);

        address logic = address(new PendleSiloV2SY(SILO_VAULT, INCENTIVE_CONTROLLER, address(factory)));
        sy = IStandardizedYield(
            deployTransparentProxy(
                logic,
                deployer,
                abi.encodeCall(
                    PendleSiloV2SY.initialize,
                    (
                        "SY Silo",
                        "SY-SILO",
                        toArray(0x039e2fB66102314Ce7b64Ce5Ce3E5183bc94aD38, 0xb098AFC30FCE67f1926e735Db6fDadFE433E61db)
                    )
                )
            )
        );

        vm.stopPrank();
    }

    function initializeSY() internal override {
        super.initializeSY();
        startToken = IERC4626(SILO_VAULT).asset();
    }

    function hasReward() internal pure virtual override returns (bool) {
        return true;
    }

    function addFakeRewards() internal virtual override returns (bool[] memory) {
        vm.roll(vm.getBlockNumber() + 1 days);
        skip(1 days);
        bool[] memory rewardsAdded = new bool[](2);
        rewardsAdded[0] = false;
        rewardsAdded[1] = true;
        return rewardsAdded;
    }

    function refAmountFor(address token) internal view override returns (uint256) {
        if (token == SILO_VAULT) {
            return 1000_000e18; // 1000 tokens
        }
        return super.refAmountFor(token) * 10;
    }
}
