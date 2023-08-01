import { ethers } from "hardhat";
import { setCode } from '@nomicfoundation/hardhat-network-helpers';

const CREATE2_FACTORY = "0x4e59b44847b379578588920cA78FbF26c0B4956C";
const CREATE2_FACTORY_BYTECODE =
  '0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe03601600081602082378035828234f58015156039578182fd5b8082525050506014600cf3';

  const isContract = async (address: string) => {
   const code = await ethers.provider.getCode(address);
   if (code.slice(2).length > 0) return true;
   else return false;
 };

  const checkAndDeployConstantAddressDeployerProxy = async () => {
   // check chain id, if its local, set the proxy
   let code = await ethers.provider.getCode(CREATE2_FACTORY);
 
   if (code !== '0x') {
     console.log('Constant Address Deployer Proxy found, do nothing.');
   } else {
     console.log(`Setting constant address deployer`);
     await setCode(CREATE2_FACTORY, CREATE2_FACTORY_BYTECODE);
     if (!isContract(CREATE2_FACTORY)) throw new Error('failed setting deployer');
   }
 };

async function main() {
 const abiCoder = new ethers.AbiCoder();
  const CounterFactory = await ethers.getContractFactory("Counter");
  
  const counterCreationCode = CounterFactory.bytecode;
  console.log({counterCreationCode})

  const saltString = "salty";
  const saltBytes = ethers.keccak256(ethers.solidityPacked(["string"], [saltString]));
  console.log({saltBytes})

  const initCodeHash = ethers.keccak256(
   ethers.solidityPacked(
    ['bytes'],
    [counterCreationCode])
  );
  console.log({initCodeHash})
  const precomputedAddress = ethers.getCreate2Address(CREATE2_FACTORY, saltBytes, initCodeHash);
  console.log({precomputedAddress})

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});