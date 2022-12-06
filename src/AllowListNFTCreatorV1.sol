// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Version} from "./utils/Version.sol";
import {IAllowListDrop} from "./interfaces/IAllowListDrop.sol";
import {IAllowListMetadataRenderer} from "./interfaces/IAllowListMetadataRenderer.sol";
import {AllowListDrop} from "./AllowListDrop.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {AllowListMetadataRenderer} from "./metadata/AllowListMetadataRenderer.sol";

/// @notice Allow List NFT Creator V1
contract AllowListNFTCreatorV1 is
    OwnableUpgradeable,
    UUPSUpgradeable,
    Version(2)
{
    string private constant CANNOT_BE_ZERO = "Cannot be 0 address";

    /// @notice Emitted when a edition is created reserving the corresponding token IDs.
    event CreatedDrop(
        address indexed creator,
        address indexed editionContractAddress,
        uint256 editionSize
    );

    /// @notice Address for implementation of ZoraNFTBase to clone
    address public immutable implementation;

    /// @notice Allow list metadata renderer
    AllowListMetadataRenderer public immutable allowListMetadataRenderer;

    /// @notice Initializes factory with address of implementation logic
    /// @param _implementation SingleEditionMintable logic implementation contract to clone
    /// @param _allowListMetadataRenderer Metadata renderer for drops
    constructor(
        address _implementation,
        AllowListMetadataRenderer _allowListMetadataRenderer
    ) {
        require(_implementation != address(0), CANNOT_BE_ZERO);
        require(
            address(_allowListMetadataRenderer) != address(0),
            CANNOT_BE_ZERO
        );
        implementation = _implementation;
        allowListMetadataRenderer = _allowListMetadataRenderer;
    }

    /// @dev Initializes the proxy contract
    function initialize() external initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    /// @dev Function to determine who is allowed to upgrade this contract.
    /// @param _newImplementation: unused in access check
    function _authorizeUpgrade(address _newImplementation)
        internal
        override
        onlyOwner
    {}

    //        ,-.
    //        `-'
    //        /|\
    //         |                    ,----------------.              ,----------.
    //        / \                   |ZoraNFTCreatorV1|              |ERC721Drop|
    //      Caller                  `-------+--------'              `----+-----'
    //        |                       createDrop()                       |
    //        | --------------------------------------------------------->
    //        |                             |                            |
    //        |                             |----.
    //        |                             |    | initialize NFT metadata
    //        |                             |<---'
    //        |                             |                            |
    //        |                             |           deploy           |
    //        |                             | --------------------------->
    //        |                             |                            |
    //        |                             |       initialize drop      |
    //        |                             | --------------------------->
    //        |                             |                            |
    //        |                             |----.                       |
    //        |                             |    | emit CreatedDrop      |
    //        |                             |<---'                       |
    //        |                             |                            |
    //        | return drop contract address|                            |
    //        | <----------------------------                            |
    //      Caller                  ,-------+--------.              ,----+-----.
    //        ,-.                   |ZoraNFTCreatorV1|              |ERC721Drop|
    //        `-'                   `----------------'              `----------'
    //        /|\
    //         |
    //        / \
    /// @notice Function to setup the media contract across all metadata types
    /// @dev Called by edition and drop fns internally
    /// @param name Name for new contract (cannot be changed)
    /// @param symbol Symbol for new contract (cannot be changed)
    /// @param defaultAdmin Default admin address
    /// @param editionSize The max size of the media contract allowed
    /// @param royaltyBPS BPS for on-chain royalties (cannot be changed)
    /// @param fundsRecipient recipient for sale funds and, unless overridden, royalties
    function setupDropsContract(
        string memory name,
        string memory symbol,
        address defaultAdmin,
        uint64 editionSize,
        uint16 royaltyBPS,
        address payable fundsRecipient,
        IAllowListDrop.ERC20SalesConfiguration memory saleConfig,
        IAllowListMetadataRenderer metadataRenderer,
        bytes memory metadataInitializer
    ) public returns (address newDrop) {
        newDrop = Clones.clone(implementation);

        address payable newDropAddress = payable(newDrop);

        AllowListDrop(newDropAddress).initialize(
            name,
            symbol,
            defaultAdmin,
            fundsRecipient,
            editionSize,
            royaltyBPS,
            saleConfig,
            metadataRenderer,
            metadataInitializer
        );

        emit CreatedDrop({
            creator: msg.sender,
            editionSize: editionSize,
            editionContractAddress: newDropAddress
        });

        return newDropAddress;
    }

    function createBase(
        string memory name,
        string memory symbol,
        address defaultAdmin,
        uint64 editionSize,
        uint16 royaltyBPS,
        address payable fundsRecipient,
        IAllowListDrop.ERC20SalesConfiguration memory saleConfig,
        IAllowListMetadataRenderer metadataRenderer,
        bytes memory metadataInitializer
    ) internal returns (address) {
        return
            setupDropsContract({
                defaultAdmin: defaultAdmin,
                name: name,
                symbol: symbol,
                royaltyBPS: royaltyBPS,
                editionSize: editionSize,
                fundsRecipient: fundsRecipient,
                saleConfig: saleConfig,
                metadataRenderer: metadataRenderer,
                metadataInitializer: metadataInitializer
            });
    }

    /// @dev Setup the media contract for a allow list
    /// @param name Name for new contract (cannot be changed)
    /// @param symbol Symbol for new contract (cannot be changed)
    /// @param defaultAdmin Default admin address
    /// @param editionSize The max size of the media contract allowed
    /// @param royaltyBPS BPS for on-chain royalties (cannot be changed)
    /// @param fundsRecipient recipient for sale funds and, unless overridden, royalties
    /// @param description Description for the media
    /// @param imageURI URI for the media
    /// @param animationURI URI for the animation
    function createAllowList(
        string memory name,
        string memory symbol,
        address defaultAdmin,
        uint64 editionSize,
        uint16 royaltyBPS,
        address payable fundsRecipient,
        IAllowListDrop.ERC20SalesConfiguration memory saleConfig,
        string memory description,
        string memory imageURI,
        string memory animationURI
    ) external returns (address) {
        bytes memory metadataInitializer = abi.encode(
            description,
            imageURI,
            animationURI
        );
        return
            createBase({
                defaultAdmin: defaultAdmin,
                name: name,
                symbol: symbol,
                royaltyBPS: royaltyBPS,
                editionSize: editionSize,
                fundsRecipient: fundsRecipient,
                saleConfig: saleConfig,
                metadataRenderer: allowListMetadataRenderer,
                metadataInitializer: metadataInitializer
            });
    }
}
