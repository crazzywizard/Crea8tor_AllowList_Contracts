import { deployAndVerify } from './contract.mjs';
import { writeFile } from 'fs/promises';
import dotenv from 'dotenv';
import esMain from 'es-main';
import yargs from 'yargs';
const argv = yargs(process.argv.slice(2)).option('allowList', {
  alias: 'a',
  type: 'boolean',
  description: 'Deploy Allow List Contracts'
}).argv;
dotenv.config({
  path: `.env.${process.env.CHAIN}`
});
export async function setupAllowListContracts() {
  const zoraERC721TransferHelperAddress = process.env.ZORA_ERC_721_TRANSFER_HELPER_ADDRESS;
  const trustedForwarderAddress = process.env.TRUSTED_FORWARDER_ADDRESS;

  if (!zoraERC721TransferHelperAddress) {
    throw new Error('erc721 transfer helper address is required');
  }

  if (!trustedForwarderAddress) {
    throw new Error('trusted forwarder address is required');
  }
  console.log('deploying Erc721Drop');
  const allowListDropContract = await deployAndVerify('src/AllowListDrop.sol:AllowListDrop', [
    zoraERC721TransferHelperAddress,
    trustedForwarderAddress
  ]);
  const allowListDropContractAddress = allowListDropContract.deployed.deploy.deployedTo;
  console.log('deployed drop contract to ', allowListDropContractAddress);

  console.log('deploying drops metadata');
  const allowListMetadataContract = await deployAndVerify(
    'src/metadata/AllowListMetadataRenderer.sol:AllowListMetadataRenderer',
    []
  );
  const allowListMetadataAddress = allowListMetadataContract.deployed.deploy.deployedTo;
  console.log('deployed drops metadata to', allowListMetadataAddress);

  console.log('deploying creator implementation');
  const creatorImpl = await deployAndVerify('src/AllowListNFTCreatorV1.sol:AllowListNFTCreatorV1', [
    allowListDropContractAddress,
    allowListMetadataAddress
  ]);
  console.log('deployed creator implementation to', creatorImpl.deployed.deploy.deployedTo);

  return {
    allowListDropContract,
    allowListMetadataContract,
    creatorImpl
  };
}

async function main() {
  const output = argv.a ? await setupAllowListContracts() : await setupContracts();
  const date = new Date().toISOString().slice(0, 10);
  writeFile(`./deployments/${date}.${process.env.CHAIN}.json`, JSON.stringify(output, null, 2));
}

if (esMain(import.meta)) {
  // Run main
  await main();
}
