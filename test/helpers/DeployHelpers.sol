// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../common/TestFoundation.sol";

abstract contract DeployHelpers {
    function deployTransparentProxy(address _logic, address admin_, bytes memory _data) internal returns (address) {
        return address(new TransparentUpgradeableProxy(_logic, admin_, _data));
    }
}
