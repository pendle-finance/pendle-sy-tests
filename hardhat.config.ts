import '@nomicfoundation/hardhat-foundry';
import '@nomicfoundation/hardhat-toolbox';
import {HardhatUserConfig} from 'hardhat/types';

const config: HardhatUserConfig = {
    paths: {
        sources: './src',
        tests: './test',
        artifacts: './build/artifacts',
        cache: './build/cache',
    },
    solidity: {
        compilers: [
            {
                version: '0.8.28',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 0,
                    },
                    evmVersion: 'paris',
                },
            },
        ],
        overrides: {},
    },
};

export default config;
