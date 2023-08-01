// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Script, console2} from "forge-std/Script.sol";

import {Counter} from "../../src/Counter.sol";


contract DeployScript is Script {

    // CREATE2_FACTORY declared in forge StdUtils.sol

    // anvil[0] account: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
    uint256 constant ANVIL_ACCOUNT_0_PVT_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    Counter counter;

    event logBytes32(string label, bytes32 value);
    event logAddress(string label, address value);
    event logBytes(string label, bytes value);

    function setUp() public {
    }

    
    function run() public {
        vm.startBroadcast(ANVIL_ACCOUNT_0_PVT_KEY);

        bytes memory counterCreationCode = type(Counter).creationCode;
        bytes memory constructorArgs; // no constructor args
        string memory saltString = "salty";
        bytes32 saltBytes = keccak256(
            abi.encodePacked(saltString)
        );
        emit logBytes("counterCreationCode", counterCreationCode);
        emit logBytes32("saltBytes", saltBytes);
        bytes32 initcodeHash = hashInitCode(counterCreationCode); // can exclude `abi.encode(constructorArgs)` as a 2nd arg

        address precomputedAddress = computeCreate2Address(saltBytes, initcodeHash);
        if (_contractExistsAtAddress(precomputedAddress)) {
            revert("Router Proxy contract exists at pre-computed address");
        }
        emit logAddress("precomputedAddress", precomputedAddress);

        bytes memory deployCalldata = abi.encodePacked(saltBytes, counterCreationCode, constructorArgs);

        // deploys to: 0x70a080B0f60D102F6542d89645bD13d3FBe57B49
        // (bool success,bytes memory data ) = CREATE2_FACTORY.call(deployCalldata);

        // deploys to: 0x70a080B0f60D102F6542d89645bD13d3FBe57B49
        address counterAddr = address(new Counter{salt: saltBytes}());


    }

    /*
        REF:
        /// @dev returns the hash of the init code (creation code + ABI-encoded args) used in CREATE2
        /// @param creationCode the creation code of a contract C, as returned by type(C).creationCode
        /// @param args the ABI-encoded arguments to the constructor of C
        function hashInitCode(bytes memory creationCode, bytes memory args) internal pure returns (bytes32) {
            return keccak256(abi.encodePacked(creationCode, args));
        }

    */

    // UTILS

    function _contractExistsAtAddress(address contractAddress) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(contractAddress)
        }
        return (size > 0);
    }
}
