// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract Interact is Script {
    error InvalidSignatureLength();
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 proof1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [proof1, proof2];
    bytes private SIGNATURE = hex"b128f041fffd5b8b34062d62329a359b42e5b4b97a6df21874b20a6cd0db837048a93891091c9f93788781bdcf8011b296fb2e51f935b255ea5dc223208e63661b";

    function claimAirdrop(address airdrop) public {
        vm.startBroadcast();
        (uint8 v,bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, proof,v,r,s);
        vm.stopBroadcast();
    }
    function splitSignature(bytes memory sig) public pure returns(uint8 v,bytes32 r, bytes32 s){
        if(sig.length != 65){
            revert InvalidSignatureLength();
        }
        assembly {
            r := mload(add(sig,32))
        s := mload(add(sig,64))
        v := byte(0,mload(add(sig,96)))
        }
    }

    function run() public {
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        
        claimAirdrop(mostRecentDeployment);
        
    }
}
