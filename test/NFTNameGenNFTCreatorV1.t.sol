// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";
import {INFTNameGenMetadataRenderer} from "../src/interfaces/INFTNameGenMetadataRenderer.sol";
import "../src/NFTNameGenNFTCreatorV1.sol";
import "../src/ZoraNFTCreatorProxy.sol";
import {MockMetadataRenderer} from "./metadata/MockMetadataRenderer.sol";
import {NFTNameGenMetadataRenderer} from "../src/metadata/NFTNameGenMetadataRenderer.sol";
import {FactoryUpgradeGate} from "../src/FactoryUpgradeGate.sol";
import {IERC721AUpgradeable} from "erc721a-upgradeable/IERC721AUpgradeable.sol";

contract ZoraNFTCreatorV1Test is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);
    address public constant DEFAULT_OWNER_ADDRESS = address(0x23499);
    address payable public constant DEFAULT_FUNDS_RECIPIENT_ADDRESS =
        payable(address(0x21303));
    address payable public constant DEFAULT_ZORA_DAO_ADDRESS =
        payable(address(0x999));
    NFTNameGenDrop public dropImpl;
    NFTNameGenNFTCreatorV1 public creator;
    NFTNameGenMetadataRenderer public allowListMetadataRenderer;

    function setUp() public {
        vm.prank(DEFAULT_ZORA_DAO_ADDRESS);
        dropImpl = new NFTNameGenDrop(address(1234), address(1235));
        allowListMetadataRenderer = new NFTNameGenMetadataRenderer();
        NFTNameGenNFTCreatorV1 impl = new NFTNameGenNFTCreatorV1(
            address(dropImpl),
            allowListMetadataRenderer
        );
        creator = NFTNameGenNFTCreatorV1(
            address(new ZoraNFTCreatorProxy(address(impl), ""))
        );
        creator.initialize();
    }

    function test_CreateNFTNameGen() public {
        creator.createNFTNameGen(
            "name",
            "symbol",
            DEFAULT_FUNDS_RECIPIENT_ADDRESS,
            1000,
            100,
            DEFAULT_FUNDS_RECIPIENT_ADDRESS,
            INFTNameGenDrop.ERC20SalesConfiguration({
                publicSaleStart: 0,
                erc20PaymentToken: address(0),
                publicSaleEnd: 0,
                presaleStart: 0,
                presaleEnd: 0,
                publicSalePrice: 0,
                maxSalePurchasePerAddress: 0,
                presaleMerkleRoot: bytes32(0)
            }),
            "Description for metadata",
            "https://example.com/image.png",
            "https://example.com/animation.mp4"
        );
    }

    function test_CreateNFTNameGenAndMint() public {
        address deployedDrop = creator.createNFTNameGen(
            "creators",
            "cr8",
            DEFAULT_FUNDS_RECIPIENT_ADDRESS,
            1000,
            100,
            DEFAULT_FUNDS_RECIPIENT_ADDRESS,
            INFTNameGenDrop.ERC20SalesConfiguration({
                publicSaleStart: 0,
                erc20PaymentToken: address(0),
                publicSaleEnd: uint64(block.timestamp + 1),
                presaleStart: 0,
                presaleEnd: 0,
                publicSalePrice: 0,
                maxSalePurchasePerAddress: 0,
                presaleMerkleRoot: bytes32(0)
            }),
            "Description for metadata",
            "https://example.com/image.png",
            "https://example.com/animation.mp4"
        );

        INFTNameGenDrop(deployedDrop).purchase(
            1,
            "name",
            "description",
            "image",
            address(23)
        );
        assertEq(IERC721AUpgradeable(deployedDrop).ownerOf(1), address(23));
    }

    function test_CreateNFTNameGenDrop() public {
        NFTNameGenMetadataRenderer mockRenderer = new NFTNameGenMetadataRenderer();
        bytes memory data = abi.encode(
            "Description for metadata",
            "https://example.com/image.png",
            "https://example.com/animation.mp4"
        );
        address deployedDrop = creator.setupDropsContract(
            "name",
            "symbol",
            DEFAULT_FUNDS_RECIPIENT_ADDRESS,
            1000,
            100,
            DEFAULT_FUNDS_RECIPIENT_ADDRESS,
            INFTNameGenDrop.ERC20SalesConfiguration({
                publicSaleStart: 0,
                erc20PaymentToken: address(0),
                publicSaleEnd: type(uint64).max,
                presaleStart: 0,
                presaleEnd: 0,
                publicSalePrice: 0,
                maxSalePurchasePerAddress: 0,
                presaleMerkleRoot: bytes32(0)
            }),
            mockRenderer,
            data
        );
        NFTNameGenDrop drop = NFTNameGenDrop(payable(deployedDrop));
        vm.expectRevert(
            IERC721AUpgradeable.URIQueryForNonexistentToken.selector
        );
        drop.tokenURI(1);
        assertEq(
            drop.contractURI(),
            "data:application/json;base64,eyJuYW1lIjogIm5hbWUiLCAiZGVzY3JpcHRpb24iOiAiRGVzY3JpcHRpb24gZm9yIG1ldGFkYXRhIiwgInNlbGxlcl9mZWVfYmFzaXNfcG9pbnRzIjogMTAwLCAiZmVlX3JlY2lwaWVudCI6ICIweDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMjEzMDMiLCAiaW1hZ2UiOiAiaHR0cHM6Ly9leGFtcGxlLmNvbS9pbWFnZS5wbmcifQ=="
        );
        drop.purchase(1, "name", "description", "image", address(23));
        assertEq(
            drop.tokenURI(1),
            "data:application/json;base64,eyJuYW1lIjogIm5hbWUgMS8xMDAwIiwgImRlc2NyaXB0aW9uIjogImRlc2NyaXB0aW9uIiwgImltYWdlIjogImltYWdlIiwgImFuaW1hdGlvbl91cmwiOiAiaHR0cHM6Ly9leGFtcGxlLmNvbS9hbmltYXRpb24ubXA0IiwgInByb3BlcnRpZXMiOiB7Im51bWJlciI6IDEsICJuYW1lIjogIm5hbWUifX0="
        );
    }
}
