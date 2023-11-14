// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.23;

import "@std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "src/Vault.sol";

/**
 * @title Vault Test
 * @author sepyke.eth
 * @notice Test basic functionalities
 */
contract VaultTest is Test {
  Vault vault;

  address admin = vm.addr(0xBA5ED);
  address treasury = vm.addr(0xDADD1);
  address alice = vm.addr(0xA11CE);

  // bps: 100 -> 1%
  Vault.Config config =
    Vault.Config({
      name: "Vaultbird Vault",
      symbol: "VBT",
      asset: IERC20(alice),
      rewards: IERC20(alice),
      native: IERC20(alice),
      admin: admin,
      treasury: alice,
      feeDistributor: alice,
      creator: alice,
      reinvestMinAmount: 0,
      reinvestFeeBps: 1000,
      reinvestFeeTreasuryBps: 3500,
      reinvestFeeDistributorBps: 5000,
      reinvestFeeCreatorBps: 1000,
      reinvestFeeCallerBps: 500
    });

  function setUp() public {
    vault = new Vault(config);
  }

  function test_metadata() public {
    assertEq(vault.name(), config.name);
    assertEq(vault.symbol(), config.symbol);
    assertEq(vault.owner(), config.admin);
    assertEq(address(vault.asset()), address(config.asset));
    assertEq(address(vault.rewards()), address(config.rewards));
    assertEq(address(vault.native()), address(config.native));
  }

  function test_setTreasury() public {
    address addr = vm.addr(0x012);

    vm.startPrank(admin);
    vault.setTreasury(addr);
    vm.stopPrank();

    assertEq(vault.treasury(), addr);
  }

  function test_setTreasuryRevertNonAdmin() public {
    address addr = vm.addr(0x012);

    vm.startPrank(alice);
    vm.expectRevert(
      abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
    );
    vault.setTreasury(addr);
  }

  function test_setTreasuryRevertBurnAddress() public {
    vm.startPrank(admin);
    vm.expectRevert(
      abi.encodeWithSelector(Vault.InvalidTreasuryAddress.selector)
    );
    vault.setTreasury(address(0));
  }

  function test_setFeeDistributor() public {
    address addr = vm.addr(0x012);

    vm.startPrank(admin);
    vault.setFeeDistributor(addr);
    vm.stopPrank();

    assertEq(vault.feeDistributor(), addr);
  }

  function test_setFeeDistributorRevertNonAdmin() public {
    address addr = vm.addr(0x012);

    vm.startPrank(alice);
    vm.expectRevert(
      abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
    );
    vault.setFeeDistributor(addr);
  }

  function test_setFeeDistributorRevertBurnAddress() public {
    vm.startPrank(admin);
    vm.expectRevert(
      abi.encodeWithSelector(Vault.InvalidFeeDistributorAddress.selector)
    );
    vault.setFeeDistributor(address(0));
  }

  function test_setCreator() public {
    address addr = vm.addr(0x012);

    vm.startPrank(admin);
    vault.setCreator(addr);
    vm.stopPrank();

    assertEq(vault.creator(), addr);
  }

  function test_setCreatorRevertNonAdmin() public {
    address addr = vm.addr(0x012);

    vm.startPrank(alice);
    vm.expectRevert(
      abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
    );
    vault.setCreator(addr);
  }

  function test_setCreatorRevertBurnAddress() public {
    vm.startPrank(admin);
    vm.expectRevert(
      abi.encodeWithSelector(Vault.InvalidCreatorAddress.selector)
    );
    vault.setCreator(address(0));
  }

  function test_setReinvestMinAmount() public {
    vm.startPrank(admin);
    vault.setReinvestMinAmount(1 ether);
    vm.stopPrank();

    assertEq(vault.reinvestMinAmount(), 1 ether);
  }

  function test_setReinvestMinAmountRevertNonAdmin() public {
    vm.startPrank(alice);
    vm.expectRevert(
      abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
    );
    vault.setReinvestMinAmount(1 ether);
  }

  function test_setReinvestFeeBps() public {
    vm.startPrank(admin);
    vault.setReinvestFeeBps(100);
    vm.stopPrank();

    assertEq(vault.reinvestFeeBps(), 100);
  }

  function test_setReinvestFeeBpsRevertNonAdmin() public {
    vm.startPrank(alice);
    vm.expectRevert(
      abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
    );
    vault.setReinvestFeeBps(100);
  }

  function test_setReinvestFeeBpsRevertGreaterThanMax() public {
    vm.startPrank(admin);
    vm.expectRevert(
      abi.encodeWithSelector(Vault.InvalidReinvestFeeBps.selector)
    );
    vault.setReinvestFeeBps(1001);
  }

  function test_setReinvestFeeDistribution() public {
    vm.startPrank(admin);
    vault.setReinvestFeeDistribution(5000, 4000, 500, 500);
    vm.stopPrank();

    assertEq(vault.reinvestFeeTreasuryBps(), 5000);
    assertEq(vault.reinvestFeeDistributorBps(), 4000);
    assertEq(vault.reinvestFeeCreatorBps(), 500);
    assertEq(vault.reinvestFeeCallerBps(), 500);
  }

  function test_setReinvestFeeDistributionRevertNonAdmin() public {
    vm.startPrank(alice);
    vm.expectRevert(
      abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice)
    );
    vault.setReinvestFeeDistribution(5000, 4000, 500, 500);
  }

  function test_setReinvestFeeDistributionRevertInvalid() public {
    vm.startPrank(admin);
    vm.expectRevert(
      abi.encodeWithSelector(Vault.InvalidReinvestFeeDistribution.selector)
    );
    vault.setReinvestFeeDistribution(5000, 4000, 1000, 500);

    vm.startPrank(admin);
    vm.expectRevert(
      abi.encodeWithSelector(Vault.InvalidReinvestFeeDistribution.selector)
    );
    vault.setReinvestFeeDistribution(5000, 4000, 200, 500);
  }
}
