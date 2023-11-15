// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.23;

import {Test} from "@std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {HopVault} from "../../src/hop/HopVault.sol";
import {IStakingRewards} from "../../src/hop/interfaces/IStakingRewards.sol";

contract HopVaultTest is Test {
  string RPC_URL_ARBITRUM = vm.envString("RPC_URL_ARBITRUM");

  address owner = vm.addr(0xB453D);
  address alice = vm.addr(0xA11CE);
  address bob = vm.addr(0xB0B);

  HopVault public vault;
  address asset = 0x59745774Ed5EfF903e615F5A2282Cae03484985a;
  address stakingRewards = 0x755569159598f3702bdD7DFF6233A317C156d3Dd;

  function setUp() public {
    uint256 fork = vm.createFork(RPC_URL_ARBITRUM);
    vm.selectFork(fork);

    vault = new HopVault(
      "Vaultbird Hop ETH",
      "VBT-HOP-ETH",
      IERC20(asset),
      IStakingRewards(stakingRewards)
    );
  }

  // TODO(pyk):
  // Make sure:
  // 1. Rewards reinvested
  // 2. Asset got staked

  function test_DepositInitial() public {
    uint256 amount = 10 ether;
    deal(asset, alice, amount);

    vm.startPrank(alice);
    IERC20(asset).approve(address(vault), amount);
    vault.deposit(amount, alice);
    vm.stopPrank();

    assertEq(vault.balanceOf(alice), amount);
    assertEq(vault.totalAssets(), amount);
    assertEq(vault.convertToShares(amount), amount);
    assertEq(vault.convertToAssets(amount), amount);
    assertEq(IStakingRewards(stakingRewards).balanceOf(address(vault)), amount);
  }

  function test_MintInitial() public {
    uint256 amount = 10 ether;
    deal(asset, alice, amount);

    vm.startPrank(alice);
    IERC20(asset).approve(address(vault), amount);
    vault.mint(amount, alice);
    vm.stopPrank();

    assertEq(vault.balanceOf(alice), amount);
    assertEq(vault.totalAssets(), amount);
    assertEq(vault.convertToShares(amount), amount);
    assertEq(vault.convertToAssets(amount), amount);
    assertEq(IStakingRewards(stakingRewards).balanceOf(address(vault)), amount);
  }
}
