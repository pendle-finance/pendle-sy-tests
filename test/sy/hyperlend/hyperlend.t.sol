// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IStandardizedYield} from "pendle-sy/interfaces/IStandardizedYield.sol";
import {
    PendleAaveV3WithRewardsSYUpg
} from "pendle-sy/core/StandardizedYield/implementations/AaveV3/PendleAaveV3WithRewardsSYUpg.sol";
import {console} from "forge-std/console.sol";
import {SYTest} from "../../common/SYTest.t.sol";

interface IAaveV3Pool {
    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;

    function withdraw(address asset, uint256 amount, address to) external returns (uint256);

    function getReserveNormalizedIncome(address asset) external view returns (uint256);
}

contract HyperLendTest is SYTest {
    address public constant HLEND_HYPE = 0x0D745EAA9E70bb8B6e2a0317f85F1d536616bD34;

    function setUpFork() internal override {
        vm.createSelectFork("hyperevm", 10826579);
    }

    function deploySY() internal override {
        vm.startPrank(deployer);

        sy = IStandardizedYield(
            deployTransparentProxy(
                address(
                    new PendleAaveV3WithRewardsSYUpg(
                        0x00A89d7a5A02160f20150EbEA7a2b5E4879A1A8b, // aavePool
                        HLEND_HYPE, // aToken
                        address(0),
                        0x5555555555555555555555555555555555555555 // defaultRewardToken
                    )
                ),
                address(1),
                abi.encodeCall(
                    PendleAaveV3WithRewardsSYUpg.initialize,
                    ("SY HyperLend HyperEVM WHYPE", "SY-hHyperEvmWHYPE")
                )
            )
        );

        vm.stopPrank();
    }

    function initializeSY() internal override {
        super.initializeSY();
        startToken = 0x5555555555555555555555555555555555555555;
    }

    function getPreviewTestAllowedEps() internal pure virtual override returns (uint256) {
        return 100;
    }

    function fundToken(address wallet, address token, uint256 amount) internal override {
        if (token == HLEND_HYPE) {
            address whale = 0x78b68763294B86d451958dc01c8E6b3057645F67;
            vm.prank(whale);
            IERC20(token).transfer(wallet, amount);
        } else {
            super.fundToken(wallet, token, amount);
        }
    }
}
