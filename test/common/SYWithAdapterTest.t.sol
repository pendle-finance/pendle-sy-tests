// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {
    PendleERC20WithAdapterSY
} from "pendle-sy/core/StandardizedYield/implementations/Adapter/extensions/PendleERC20WithAdapterSY.sol";
import {
    PendleERC4626WithAdapterSY
} from "pendle-sy/core/StandardizedYield/implementations/Adapter/extensions/PendleERC4626WithAdapterSY.sol";
import {
    PendleERC4626NoRedeemWithAdapterSY
} from "pendle-sy/core/StandardizedYield/implementations/Adapter/extensions/PendleERC4626NoRedeemWithAdapterSY.sol";

import {DepositRedeemTest} from "./tests/DepositRedeem.t.sol";
import {MetadataTest} from "./tests/Metadata.t.sol";
import {PreviewTest} from "./tests/Preview.t.sol";

abstract contract SYWithAdapterTest is DepositRedeemTest, MetadataTest, PreviewTest {
    enum AdapterType {
        ERC20,
        ERC4626,
        ERC4626_NoRedeem
    }

    function deploySYWithAdapter(
        AdapterType adapterType,
        address yieldToken,
        string memory name,
        string memory symbol,
        address adapter
    ) internal returns (address syAddr) {
        address logic = _deploySYWithAdapterLogic(adapterType, yieldToken);
        syAddr = deployTransparentProxy(
            logic,
            deployer,
            abi.encodeCall(PendleERC20WithAdapterSY.initialize, (name, symbol, adapter))
        );
    }

    function _deploySYWithAdapterLogic(AdapterType adapterType, address yieldToken) private returns (address) {
        if (adapterType == AdapterType.ERC20) {
            return address(new PendleERC20WithAdapterSY(yieldToken));
        } else if (adapterType == AdapterType.ERC4626) {
            return address(new PendleERC4626WithAdapterSY(yieldToken));
        } else if (adapterType == AdapterType.ERC4626_NoRedeem) {
            return address(new PendleERC4626NoRedeemWithAdapterSY(yieldToken));
        } else {
            revert("SYWithAdapterTest: Invalid adapter type");
        }
    }
}
