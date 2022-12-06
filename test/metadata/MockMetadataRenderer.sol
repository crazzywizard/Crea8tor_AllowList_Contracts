// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IMetadataRenderer} from "../../src/interfaces/IMetadataRenderer.sol";

contract MockMetadataRenderer is IMetadataRenderer {
    function tokenURI(uint256) external pure returns (string memory) {
        return "DEMO";
    }

    function contractURI() external pure returns (string memory) {
        return "DEMO";
    }

    function initializeWithData(bytes memory initData) external pure {
        require(initData.length == 0, "not zero");
    }
}
