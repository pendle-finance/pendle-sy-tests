// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {PendleHyperbeatUSDTSY, PendleMidasSY} from "pendle-sy/core/StandardizedYield/implementations/Hyperbeat/PendleHyperbeatUSDTSY.sol";
import {SYTest} from "../../common/SYTest.t.sol";

contract PendleHyperbeatUSDTSYTest is SYTest {
    address _depositVault = 0xbE8A4f1a312b94A712F8E5367B02ae6E378E6F19;
    address _redemptionVault = 0xC898a5cbDb81F260bd5306D9F9B9A893D0FdF042;
    address _hbUSDT = 0x5e105266db42f78FA814322Bce7f388B4C2e61eb;
    address _hbDataFeed = 0x2812076947e07FF85734afEa2c438BA6dcEb2083;
    address USDT0 = 0xB8CE59FC3717ada4C02eaDF9682A9e934F625ebb;

    function setUpFork() internal override {
        vm.createSelectFork("https://rpc.purroofgroup.com/", 9319239);
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        sy = IStandardizedYield(deployTransparentProxy(
            address(new PendleHyperbeatUSDTSY(_hbUSDT, _depositVault, _redemptionVault, _hbDataFeed, USDT0)),
            deployer,
            abi.encodeCall(PendleMidasSY.initialize, ("SY HyperbeatUSDT", "SY-hbUSDT"))
        ));

        vm.stopPrank();
    }

    function hasFee() internal pure override returns (bool) {
        return true;
    }

    function getTokensOutFeeForPreviewTest() internal view override returns (uint256[] memory) {
        uint256[] memory fees = new uint256[](getTokensOutForPreviewTest().length);
        fees[0] = 5e15;
        return fees;
    }

    function getPreviewTestAllowedEps() internal pure override returns (uint256) { // 1e-4
        return 1e14;
    }
}
