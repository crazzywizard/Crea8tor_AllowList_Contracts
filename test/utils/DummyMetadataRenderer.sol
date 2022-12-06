// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IAllowListMetadataRenderer} from "../../src/interfaces/IAllowListMetadataRenderer.sol";

contract DummyMetadataRenderer is IAllowListMetadataRenderer {
    function tokenURI(uint256) external pure override returns (string memory) {
        return "DUMMY";
    }

    function contractURI() external pure override returns (string memory) {
        return "DUMMY";
    }

    function initializeWithData(bytes memory data) external {
        // no-op
    }

    function setFormResponse(uint256, string memory) external {
        // no-op
    }
}
