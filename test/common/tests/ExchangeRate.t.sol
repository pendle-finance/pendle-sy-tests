// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;


import "../TestFoundation.sol";

abstract contract ExchangeRateTest is TestFoundation {
    function test_exchangeRateSanity() public view {
        uint256 exchangeRate = sy.exchangeRate();

        uint256 decimalsSY = IERC20Metadata(address(sy)).decimals();
        (, , uint8 decimalsAsset) = sy.assetInfo();

        uint256 amtAsset = ((10 ** decimalsSY) * sy.exchangeRate()) / (10 ** 18);
        uint256 amtAsset18 = amtAsset;
        if (decimalsAsset < 18) {
            amtAsset18 = amtAsset * (10 ** (18 - decimalsAsset));
        } else if (decimalsAsset > 18) {
            amtAsset18 = amtAsset / (10 ** (decimalsAsset - 18));
        }

        checkRequired(string.concat("Exchange rate: ", vm.toString(exchangeRate)));
        console.log("                 1 SY = %18e asset", amtAsset18);

        assertGt(exchangeRate, 0, "Exchange rate should be greater than 0");
    }

    function test_exchangeRate_isMonotonicIncreasing() public {
        vm.makePersistent(address(sy));
        if (_getImplementationAddress(address(sy)) != address(0)) {
            vm.makePersistent(_getImplementationAddress(address(sy)));
        }
    
        uint256 pinnedBlock = _exchangeRateTestStartBlock();
        uint256 interval = (block.number - pinnedBlock) / 10;
        uint256 endBlock = block.number;

        checkRequired("Exchange Rate Monotonic");

        for (; pinnedBlock <= endBlock; pinnedBlock += interval) {
            vm.rollFork(pinnedBlock);
            uint256 exchangeRate = sy.exchangeRate();
            console.log("Exchange rate at block %s: %s", pinnedBlock, exchangeRate);
        } 
    }

    function _exchangeRateTestStartBlock() internal view virtual returns (uint256) {
        return block.number - 1000;
    }

    function _getImplementationAddress(address proxy) internal view returns (address) {
        return address(uint160(uint256(vm.load(proxy, 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc))));
    }
}