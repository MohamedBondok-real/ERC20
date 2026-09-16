// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import {Test} from "forge-std/Test.sol";
import {BondokWeb3} from "../src/BondokWeb3.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

contract BondokWeb3Test is Test {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    BondokWeb3 public token;
    address public owner;
    address public alice;
    address public bob;

    function setUp() public {
        owner = address(this);
        alice = makeAddr("alice");
        bob = makeAddr("bob");

        token = new BondokWeb3();
    }

    //----------- Constructor Tests -----------------

    function test_constructor_setName() public view {
        assertEq(token.name(), "BondokWeb3");
    }

    function test_constructor_setSymbol() public view {
        assertEq(token.symbol(), "BW3");
    }

    function test_constructor_setOwner() public view {
        assertEq(token.owner(), owner);
    }

    function test_constructor_setTotalSupply() public view {
        assertEq(token.totalSupply(), 0);
    }

    function test_constructor_setDecimal() public view {
        assertEq(token.decimals(), 18);
    }

    //----------- Testing Mint Function -----------------

    function test_mint_asOwner() public {
        token.mint(alice, 1000 ether);
        assertEq(token.balanceOf(alice), 1000 ether);
        assertEq(token.totalSupply(), 1000 ether);
    }

    function test_multipleMint() public {
        token.mint(alice, 500 ether);
        token.mint(bob, 300 ether);
        assertEq(token.balanceOf(alice), 500 ether);
        assertEq(token.balanceOf(bob), 300 ether);
        assertEq(token.totalSupply(), 800 ether);
    }

    function test_mint_asNonOwner() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        token.mint(bob, 1000 ether);
    }

    function test_mint_zeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        token.mint(address(0), 1000 ether);
    }

    //----------- Transfer Tests -----------------

    function test_transfer() public {
        token.mint(alice, 1000 ether);
        vm.prank(alice);
        bool success = token.transfer(bob, 400 ether);
        assertTrue(success);
        assertEq(token.balanceOf(alice), 600 ether);
        assertEq(token.balanceOf(bob), 400 ether);
    }

    function test_transfer_revertInsufficientBalance() public {
        token.mint(alice, 1000 ether);
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, alice, 1000 ether, 1500 ether)
        );
        token.transfer(bob, 1500 ether);
    }

    function test_transfer_revertToZeroAddress() public {
        token.mint(alice, 1000 ether);
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        token.transfer(address(0), 400 ether);
    }

    function test_transfer_toSelf() public {
        token.mint(alice, 1000 ether);
        vm.prank(alice);
        bool success = token.transfer(alice, 400 ether);
        assertTrue(success);
        assertEq(token.balanceOf(alice), 1000 ether);
    }

    function test_transfer_emmitsTransferEvent() public {
        token.mint(alice, 1000 ether);
        vm.prank(alice);
        vm.expectEmit(true, true, false, true);
        emit Transfer(alice, bob, 400 ether);
        token.transfer(bob, 400 ether);
    }

    //----------- Approve & Allowance Tests -----------------

    function test_approve_success() public {
        token.mint(alice, 1000 ether);
        vm.prank(alice);
        bool success = token.approve(bob, 400 ether);
        assertTrue(success);
        assertEq(token.allowance(alice, bob), 400 ether);
    }

    function test_approve_overWrite() public {
        token.mint(alice, 1000 ether);
        vm.prank(alice);
        token.approve(bob, 400 ether);
        vm.prank(alice);
        token.approve(bob, 600 ether);
        assertEq(token.allowance(alice, bob), 600 ether);
    }

    function test_approve_revertSpenderZeroAddress() public {
        token.mint(alice, 1000 ether);
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InvalidSpender.selector, address(0))
        );
        token.approve(address(0), 400 ether);
    }

    function test_approve_emmitEvent() public {
        token.mint(alice, 1000 ether);
        vm.prank(alice);
        vm.expectEmit(true, true, false, true);
        emit Approval(alice, bob, 400 ether);
        token.approve(bob, 400 ether);
    }

    //----------- TransferFrom Tests -----------------

    function test_transferFrom_success() public {
        token.mint(alice, 1000 ether);
        vm.prank(alice);
        token.approve(bob, 400 ether);
        vm.prank(bob);
        bool success = token.transferFrom(alice, bob, 300 ether);
        assertTrue(success);
        assertEq(token.balanceOf(alice), 700 ether);
        assertEq(token.balanceOf(bob), 300 ether);
        assertEq(token.allowance(alice, bob), 100 ether);
    }
    function test_transferFrom_revertInsufficientAllowance() public {
        token.mint(alice, 1000 ether);
        vm.prank(alice);
        token.approve(bob, 400 ether);
        vm.prank(bob);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, bob, 400 ether, 500 ether)
        );
        token.transferFrom(alice, bob, 500 ether);
    }
    function test_transferFrom_infiniteApproval() public {
        token.mint(alice, 1000 ether);
        vm.prank(alice);
        token.approve(bob, type(uint256).max);
        vm.prank(bob);
        bool success = token.transferFrom(alice, bob, 300 ether);
        assertTrue(success);
        assertEq(token.balanceOf(alice), 700 ether);
        assertEq(token.balanceOf(bob), 300 ether);
        assertEq(token.allowance(alice, bob), type(uint256).max);
    }
    function test_transferFrom_revertToZeroAddress() public {
        token.mint(alice, 1000 ether);
        vm.prank(alice);
        token.approve(bob, 400 ether);
        vm.prank(bob);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        token.transferFrom(alice, address(0), 300 ether);
    }

    //----------- TransferOwnership Tests ----------------- 

    function test_transferOwnership_success() public {
        address newOwner = makeAddr("newOwner");
        token.transferOwnership(newOwner);
        assertEq(token.owner(), newOwner);
        
    }
    function test_transferOwnership_revertNotOwner() public {
        address newOwner = makeAddr("newOwner");
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        token.transferOwnership(newOwner);
    }
    function test_transferOwnership_revertZeroAddress() public {
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableInvalidOwner.selector, address(0)));
        token.transferOwnership(address(0));
    }
    function test_transferOwnership_newOwnerCanMint() public {
        address newOwner = makeAddr("newOwner");
        token.transferOwnership(newOwner);
        vm.prank(newOwner);
        token.mint(alice, 1000 ether);
        assertEq(token.balanceOf(alice), 1000 ether);
    }
    function test_transferOwnership_oldOwnerCannotMint() public {
        address newOwner = makeAddr("newOwner");
        token.transferOwnership(newOwner);
        vm.prank(owner);
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, owner));
        token.mint(alice, 1000 ether);
    }

    //----------- RenounceOwnership Tests -----------------

    function test_renounceOwnership_success() public {
        token.renounceOwnership();
        assertEq(token.owner(), address(0));
    }
    function test_renounceOwnership_revertNotOwner() public {
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        token.renounceOwnership();
    }
    function test_renounceOwnership_noOneCanMint() public {
        token.renounceOwnership();
        vm.prank(owner);
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, owner));
        token.mint(alice, 1000 ether);
    }
}
