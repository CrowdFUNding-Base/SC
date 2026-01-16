// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Network {
    struct NetworkConfig {
        string name;
        string url;
        uint256 chainId;
    }
    
    mapping(string => NetworkConfig) public networkConfig;

    constructor(){
        networkConfig["localhost"] = getLocalNetworkConfig();
        networkConfig["base-sepolia"] = getBaseSepoliaNetworkConfig();
    }

    function getLocalNetworkConfig() public returns(NetworkConfig memory){
        return NetworkConfig({
            name: "localhost",
            url: "http://127.0.0.1:8545",
            chainId: 31337
        });
    }

    function getBaseSepoliaNetworkConfig() public returns(NetworkConfig memory){
        return NetworkConfig({
            name: "base-sepolia",
            url: "https://base-sepolia.g.alchemy.com/v2/your-api-key",
            chainId: 84531
        });
    }

    function getNetworkConfig(string memory name) public view returns (NetworkConfig memory) {
        return networkConfig[name];
    }
}