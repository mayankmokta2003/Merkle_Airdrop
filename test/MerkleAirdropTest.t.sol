// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ZkSyncChainChecker} from "../lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test, ZkSyncChainChecker {
    MerkleAirdrop public airdrop;
    BagelToken public token;
    uint256 public constant AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public AMOUNT_TO_SEND = 4 * AMOUNT_TO_CLAIM;
    address user;
    uint256 privateKey;
    address public gaspayer;
    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    bytes32 public proof1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 public proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proof1, proof2];

    function setUp() public {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        } else {
            token = new BagelToken();
            // airdrop = new MerkleAirdrop(ROOT,IERC20(address(token)));
            airdrop = new MerkleAirdrop(ROOT, token);
            token.mint(token.owner(), AMOUNT_TO_SEND);
            token.transfer(address(airdrop), AMOUNT_TO_SEND);
        }
        (user, privateKey) = makeAddrAndKey("user");
        // gaspayer = makeAddr("gaspayer");
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 hashed = airdrop._getMessageHash(user, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, hashed);
        vm.prank(user);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        uint256 endingbalance = token.balanceOf(user);
        assertEq(endingbalance - startingBalance, AMOUNT_TO_CLAIM);
    }

    function testRevertsIfUserhasAlreadyClaimed() public {
        bytes32 hashed = airdrop._getMessageHash(user, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, hashed);
        vm.prank(user);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        vm.prank(user);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__alreadyClaimed.selector);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
    }

    function testrevertsIfSignatureIsNotValid() public {
        address user2 = makeAddr("user2");
        bytes32 hashed = airdrop._getMessageHash(user, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, hashed);
        vm.prank(user2);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__invalidSignature.selector);
        airdrop.claim(user2, AMOUNT_TO_CLAIM, PROOF, v, r, s);
    }
}
