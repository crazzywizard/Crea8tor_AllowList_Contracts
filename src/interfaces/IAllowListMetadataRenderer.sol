// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import {IMetadataRenderer} from "../interfaces/IMetadataRenderer.sol";

interface IAllowListMetadataRenderer is IMetadataRenderer {
    function setFormResponse(uint256, string memory) external;
}
