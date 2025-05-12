// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {IRewardRouterV2} from "pendle-sy/interfaces/GMX/IRewardRouterV2.sol";
import {IWETH} from "pendle-sy/interfaces/IWETH.sol";
import {PendleGlpSY} from "pendle-sy/core/StandardizedYield/implementations/GLP/PendleGlpSY.sol";

import {SYTest} from "../common/SYTest.t.sol";

contract PendleGlpSYTest is SYTest {
    address internal constant GLP = 0x4277f8F2c384827B5273592FF7CeBd9f2C1ac258;
    address internal constant FSGLP = 0x1aDDD80E6039594eE970E5872D247bf0414C8903;
    address internal constant STAKED_GLP = 0x5402B5F40310bDED796c7D0F3FF6683f5C0cFfdf;
    address internal constant REWARD_ROUTER = 0x159854e14A862Df9E39E1D128b8e5F70B4A3cE9B;
    address internal constant GLP_REWARD_ROUTER = 0xB95DB5B167D75e6d04227CfFFA61069348d271F5;
    address internal constant VAULT = 0x489ee077994B6658eAfA855C308275EAd8097C4A;
    address internal constant MIM = 0xFEa7a6a0B346362BF88A9e4A88416B77a57D6c2A;

    IWETH weth;
    IERC20 stakedGlp;
    IRewardRouterV2 rewardRouter;
    IRewardRouterV2 glpRewardRouter;

    function setUpFork() internal override {
        vm.createSelectFork("https://arbitrum-one.public.blastapi.io", 189565902);
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        address logic = address(new PendleGlpSY(GLP, FSGLP, STAKED_GLP, REWARD_ROUTER, GLP_REWARD_ROUTER, VAULT));
        sy = IStandardizedYield(deployTransparentProxy(logic, deployer, abi.encodeCall(PendleGlpSY.initialize, ())));

        vm.stopPrank();
    }

    function initializeSY() internal override {
        super.initializeSY();

        PendleGlpSY _sy = PendleGlpSY(payable(address(sy)));
        weth = IWETH(_sy.weth());
        stakedGlp = IERC20(_sy.stakedGlp());
        rewardRouter = IRewardRouterV2(_sy.rewardRouter());
        glpRewardRouter = IRewardRouterV2(_sy.glpRouter());

        assertEq(address(stakedGlp), STAKED_GLP);
        assertEq(address(rewardRouter), REWARD_ROUTER);
        assertEq(address(glpRewardRouter), GLP_REWARD_ROUTER);

        startToken = _sy.weth();
    }

    function refAmountFor(address token) internal view override returns (uint256) {
        return super.refAmountFor(token);
    }

    function fundToken(address wallet, address token, uint256 amount) internal override {
        if (token == STAKED_GLP) {
            address whale = 0x85667409a723684Fe1e57Dd1ABDe8D88C2f54214;
            vm.prank(whale);
            IERC20(token).transfer(wallet, amount);
        } else {
            super.fundToken(wallet, token, amount);
        }
    }

    function addFakeRewards() internal override returns (bool[] memory) {
        vm.roll(vm.getBlockNumber() + 1 days / 12);
        skip(1 days);
        return toArray(true);
    }

    function getTokensInForPreviewTest() internal view override returns (address[] memory res) {
        res = sy.getTokensIn();

        // skip MIM pool due to error "Vault: poolAmount exceeded" when depositing
        erase(res, MIM);
    }

    function getTokensOutForPreviewTest() internal view override returns (address[] memory res) {
        res = sy.getTokensOut();

        // skip MIM pool due to error "Vault: poolAmount exceeded" when redeeming
        erase(res, MIM);
    }

    function hasReward() internal pure override returns (bool) {
        return true;
    }
}
