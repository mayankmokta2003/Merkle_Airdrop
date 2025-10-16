// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import{Script,console} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script{

    bytes32 private s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private i_amountToTransfer = 4 * 25 * 1e18;

    function deployMerkleAirdrop() public returns(MerkleAirdrop,BagelToken){
        vm.startBroadcast();
        BagelToken token = new BagelToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(s_merkleRoot,IERC20(token));
        token.mint(token.owner(),i_amountToTransfer);
        token.transfer(address(airdrop),i_amountToTransfer);
        vm.stopBroadcast();
        return (airdrop,token);
    }

    function run() external returns (MerkleAirdrop,BagelToken){}

}