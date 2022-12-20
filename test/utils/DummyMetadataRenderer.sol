// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {INFTNameGenMetadataRenderer} from "../../src/interfaces/INFTNameGenMetadataRenderer.sol";

contract DummyMetadataRenderer is INFTNameGenMetadataRenderer {
    function tokenURI(uint256) external pure override returns (string memory) {
        return "DUMMY";
    }

    function contractURI() external pure override returns (string memory) {
        return "DUMMY";
    }

    function initializeWithData(bytes memory data) external {
        // no-op
    }

    function setTokenInfo(
        uint256,
        string memory,
        string memory,
        string memory
    ) external {
        // no-op
    }
}
