// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {SYTest} from "../common/SYTest.t.sol";
import {
    PendleBeraVedaETHSY,
    PendleERC20SYUpg
} from "pendle-sy/core/StandardizedYield/implementations/EtherFi/PendleBeraVedaETHSY.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";

contract LiquidBeraETHTest is SYTest {
    function setUpFork() internal override {
        vm.createSelectFork("ethereum", 22594799);
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        address implementation = address(new PendleBeraVedaETHSY());

        sy = IStandardizedYield(
            deployTransparentProxy(
                address(implementation),
                address(1),
                abi.encodeCall(PendleERC20SYUpg.initialize, ("SY BERA ETH", "SY-BERA-ETH"))
            )
        );

        PendleBeraVedaETHSY syContract = PendleBeraVedaETHSY(payable(address(sy)));
        syContract.approveAllForTeller();

        vm.mockCall(0x5979F753b417c17FCd8f8c87b86154A0EB0E2c17, 0xb7009613, abi.encode(1));

        vm.stopPrank();
    }

    function initializeSY() internal override {
        super.initializeSY();
        startToken = sy.yieldToken();
    }

    function refAmountFor(address token) internal view override returns (uint256) {
        if (token == 0x35fA164735182de50811E8e2E824cFb9B6118ac2) {
            return 1e16;
        }
        return super.refAmountFor(token);
    }
}
