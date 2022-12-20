import { deployAndVerify } from './contract.mjs';
import { writeFile } from 'fs/promises';
import dotenv from 'dotenv';
import esMain from 'es-main';

dotenv.config({
  path: `.env.${process.env.CHAIN}`
});
export async function setupContracts() {
  const zoraERC721TransferHelperAddress = process.env.ZORA_ERC_721_TRANSFER_HELPER_ADDRESS;
  const trustedForwarderAddress = process.env.TRUSTED_FORWARDER_ADDRESS;

  if (!zoraERC721TransferHelperAddress) {
    throw new Error('erc721 transfer helper address is required');
  }

  if (!trustedForwarderAddress) {
    throw new Error('trusted forwarder address is required');
  }
  console.log('deploying Erc721Drop');
  const NFTNameGenDropContract = await deployAndVerify('src/NFTNameGenDrop.sol:NFTNameGenDrop', [
    zoraERC721TransferHelperAddress,
    trustedForwarderAddress
  ]);
  const NFTNameGenDropContractAddress = NFTNameGenDropContract.deployed.deploy.deployedTo;
  console.log('deployed drop contract to ', NFTNameGenDropContractAddress);

  console.log('deploying drops metadata');
  const NFTNameGenMetadataContract = await deployAndVerify(
    'src/metadata/NFTNameGenMetadataRenderer.sol:NFTNameGenMetadataRenderer',
    []
  );
  const NFTNameGenMetadataAddress = NFTNameGenMetadataContract.deployed.deploy.deployedTo;
  console.log('deployed drops metadata to', NFTNameGenMetadataAddress);

  console.log('deploying creator implementation');
  const creatorImpl = await deployAndVerify(
    'src/NFTNameGenNFTCreatorV1.sol:NFTNameGenNFTCreatorV1',
    [NFTNameGenDropContractAddress, NFTNameGenMetadataAddress]
  );
  console.log('deployed creator implementation to', creatorImpl.deployed.deploy.deployedTo);

  return {
    NFTNameGenDropContract,
    NFTNameGenMetadataContract,
    creatorImpl
  };
}

async function main() {
  const output = await setupContracts();
  const date = new Date().toISOString().slice(0, 10);
  writeFile(`./deployments/${date}.${process.env.CHAIN}.json`, JSON.stringify(output, null, 2));
}

if (esMain(import.meta)) {
  // Run main
  await main();
}
