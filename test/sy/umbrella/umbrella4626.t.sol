// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {SYTest} from "../../common/SYTest.t.sol";
import {PendleUmbrellaStake4626SY} from "pendle-sy/core/StandardizedYield/implementations/Umbrella/PendleUmbrellaStake4626SY.sol";
import {console} from "forge-std/console.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Umbrella4626Test is SYTest {

    address public constant UMBRELLA_STAKE_4626 = 0x6bf183243FdD1e306ad2C4450BC7dcf6f0bf8Aa6;
    address public constant UMBRELLA_DISTRIBUTOR = 0x4655Ce3D625a63d30bA704087E52B4C31E38188B;

    address public constant ATOKEN = 0x98C23E9d8f34FEFb1B7BD6a91B7FF122F4e16F5c;
    address public constant ROOT = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant AAVE_POOL = 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2;

    function setUpFork() internal override {
        vm.createSelectFork("ethereum", 22765590);
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        sy = IStandardizedYield(
            deployTransparentProxy(
                address(new PendleUmbrellaStake4626SY(
                    UMBRELLA_STAKE_4626,
                    UMBRELLA_DISTRIBUTOR
                )),
                deployer,
                abi.encodeCall(PendleUmbrellaStake4626SY.initialize, ("SY Umbrella Stake 4626", "SY-UMBRL-4626", deployer))
            )
        );

        vm.stopPrank();
    }

    function initializeSY() internal override {
        super.initializeSY();
        startToken = PendleUmbrellaStake4626SY(payable(address(sy))).rootAsset();
    }

    function addFakeRewards() internal override returns (bool[] memory) {
        vm.roll(vm.getBlockNumber() + 1 days / 12);
        skip(1 days);
        return toArray(true);
    }

    function hasReward() internal pure override returns (bool) {
        return true;
    }


    function fundToken(address wallet, address token, uint256 amount) internal override {
        if (token == ATOKEN) {
            address whale = 0xd1074E0AE85610dDBA0147e29eBe0D8E5873a000;
            vm.prank(whale);
            IERC20(token).transfer(wallet, amount);
        } else {
            super.fundToken(wallet, token, amount);
        }
    }
}