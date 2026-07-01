// SPDX-License-Identifier: MIT
pragma solidity 0.8.35;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {StakingApp} from "../src/StakingApp.sol";
import {StakingToken} from "../src/StakingToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract StakingAppTest is Test {
    StakingApp stakingApp;
    StakingToken stakingToken;
    string name = "StakingToken";
    string symbol = "STK";
    address owner_;
    address account1;
    uint256 stakingPeriod_ = 100000000000;
    uint256 maxStakingAmount_ = 10 ether;
    uint256 rewardsPerPeriod_ = 1 ether;
    using SafeERC20 for IERC20;

    function setUp() external {
        owner_ = vm.addr(1);
        account1 = vm.addr(2);
        stakingToken = new StakingToken(name, symbol);
        stakingApp = new StakingApp(address(stakingToken), owner_, stakingPeriod_, maxStakingAmount_, rewardsPerPeriod_);
    }

    function testCorrectDeployContracts() external view {
        assert(address(stakingToken) != address(stakingApp));
    }

    function testCorrectDeployContractStakingToken() external view {
        assert(address(stakingToken) != address(0));
    }

    function testCorrectDeployContractStakingApp() external view {
        assert(address(stakingApp) != address(0));
    }

    //* ChangeStaking functions test
    function testChangeStakingPeriodOwner() external {
        vm.startPrank(owner_);
        uint256 newStakingPeriod = 200000000000;
        uint256 numBefore = stakingApp.stakingPeriod();
        stakingApp.changeStakingPeriod(newStakingPeriod);
        // console.log('stakingPeriod_', stakingPeriod_);
        uint256 numAfter = stakingApp.stakingPeriod();
        assert(newStakingPeriod == numAfter);
        assert(newStakingPeriod != numBefore);
        vm.stopPrank();
    }

    function testChangeStakingPeriodNotOwner() external {
        uint256 newStakingPeriod = 200000000000;
        vm.expectRevert();
        stakingApp.changeStakingPeriod(newStakingPeriod);
    }

    //* recieve functions test
    function testRecieveExternalEtherCorrectly() external {
        vm.startPrank(owner_);
        // create ether on owner account only en foundry
        vm.deal(owner_, 1 ether);

        uint256 value_ = 1 ether;

        uint256 balanceBefore = address(stakingApp).balance;
        // console.log('balanceBefore', balanceBefore);

        (bool success,) = address(stakingApp).call{value: value_}("");

        uint256 balanceAfter = address(stakingApp).balance;
        // console.log('balanceAfter', balanceAfter);

        require(success, "Trander failed");
        assert(balanceAfter - balanceBefore == value_);

        vm.stopPrank();
    }

    //* stake functions test
    function testStakeCorrectly() external {
        vm.startPrank(account1);
        uint256 _amount = stakingApp.MaxStakingAmount();
        stakingToken.mint(_amount);

        uint256 stakedUserBalanceBefore = stakingApp.stakedUserBalance(account1);
        uint256 elapsePeriodBefore = stakingApp.elapsePeriod(account1);

        // IERC20(stakingToken) => Con esto inicializamos el samrt contract del stakingToken
        // Approve => recibe la direccion de quien estamos dando permiso para coger los tokens de nuestra cuenta
        IERC20(stakingToken).approve(address(stakingApp), _amount);
        stakingApp.stake(_amount);

        uint256 time = block.timestamp;
        uint256 stakedUserBalanceAfter = stakingApp.stakedUserBalance(account1);
        uint256 elapsePeriodAfter = stakingApp.elapsePeriod(account1);

        assert(stakedUserBalanceAfter - stakedUserBalanceBefore == _amount);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == time);

        vm.stopPrank();
    }

    function testStakeShouldRevertMoreThanOnce() external {
        vm.startPrank(account1);
        uint256 _amount = stakingApp.MaxStakingAmount();
        stakingToken.mint(_amount);

        uint256 stakedUserBalanceBefore = stakingApp.stakedUserBalance(account1);
        uint256 elapsePeriodBefore = stakingApp.elapsePeriod(account1);

        // IERC20(stakingToken) => Con esto inicializamos el samrt contract del stakingToken
        // Approve => recibe la direccion de quien estamos dando permiso para coger los tokens de nuestra cuenta
        IERC20(stakingToken).approve(address(stakingApp), _amount);
        stakingApp.stake(_amount);

        uint256 time = block.timestamp;
        uint256 stakedUserBalanceAfter = stakingApp.stakedUserBalance(account1);
        uint256 elapsePeriodAfter = stakingApp.elapsePeriod(account1);

        assert(stakedUserBalanceAfter - stakedUserBalanceBefore == _amount);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == time);

        stakingToken.mint(_amount);
        IERC20(stakingToken).approve(address(stakingApp), _amount);
        vm.expectRevert();
        stakingApp.stake(_amount);

        vm.stopPrank();
    }

    function testStakeShouldRevert() external {
        vm.startPrank(owner_);
        vm.expectRevert();
        uint256 _amount = 20 ether;
        stakingApp.stake(_amount);
        vm.stopPrank();
    }

    //* unStake functions test
    function testUnStakeCorrectly() external {
        vm.startPrank(account1);
        uint256 _amount = stakingApp.MaxStakingAmount();
        stakingToken.mint(_amount);

        uint256 stakedUserBalanceBefore = stakingApp.stakedUserBalance(account1);
        uint256 elapsePeriodBefore = stakingApp.elapsePeriod(account1);

        // IERC20(stakingToken) => Con esto inicializamos el samrt contract del stakingToken
        // Approve => recibe la direccion de quien estamos dando permiso para coger los tokens de nuestra cuenta
        IERC20(stakingToken).approve(address(stakingApp), _amount);
        stakingApp.stake(_amount);

        uint256 time = block.timestamp;
        uint256 stakedUserBalanceAfter = stakingApp.stakedUserBalance(account1);
        uint256 elapsePeriodAfter = stakingApp.elapsePeriod(account1);

        assert(stakedUserBalanceAfter - stakedUserBalanceBefore == _amount);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == time);

        stakingApp.unStake(_amount);

        uint256 unStakedUserBalanceBefore = stakingApp.stakedUserBalance(account1);
        assert(stakedUserBalanceAfter - unStakedUserBalanceBefore == _amount);

        vm.stopPrank();
    }

    function testUnStakeShouldRevertNotAmount() external {
        vm.startPrank(account1);
        uint256 _amount = stakingApp.MaxStakingAmount();
        IERC20(stakingToken).approve(address(stakingApp), _amount);
        vm.expectRevert();
        stakingApp.stake(_amount);
        vm.stopPrank();
    }

    //* ClaimRewards functions test
    function testCannotClaimIfAmountZero() external {
        vm.startPrank(account1);
        uint256 _amount = 0;

        vm.expectRevert();
        stakingApp.claimReward(_amount);

        vm.stopPrank();
    }

    function testCannotClaimIfNotStaking() external {
        vm.startPrank(account1);
        uint256 _amount = 10;
        vm.expectRevert();
        stakingApp.claimReward(_amount);
        vm.stopPrank();
    }

    function testCannotClaimIfNotPeriodEnouft() external {
        vm.startPrank(account1);
        uint256 _amount = stakingApp.MaxStakingAmount();
        stakingToken.mint(_amount);

        uint256 stakedUserBalanceBefore = stakingApp.stakedUserBalance(account1);
        uint256 elapsePeriodBefore = stakingApp.elapsePeriod(account1);

        // IERC20(stakingToken) => Con esto inicializamos el samrt contract del stakingToken
        // Approve => recibe la direccion de quien estamos dando permiso para coger los tokens de nuestra cuenta
        IERC20(stakingToken).approve(address(stakingApp), _amount);
        stakingApp.stake(_amount);

        uint256 time = block.timestamp;
        uint256 stakedUserBalanceAfter = stakingApp.stakedUserBalance(account1);
        uint256 elapsePeriodAfter = stakingApp.elapsePeriod(account1);

        assert(stakedUserBalanceAfter - stakedUserBalanceBefore == _amount);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == time);

        vm.expectRevert("need to wait");
        stakingApp.claimReward(_amount);

        vm.stopPrank();
    }

    function testClaimRewardsRevertOutOfFunds() external {
        vm.startPrank(account1);
        uint256 _amount = stakingApp.MaxStakingAmount();
        uint256 _amountRewards = stakingApp.MaxStakingAmount();
        stakingToken.mint(_amount);

        uint256 stakedUserBalanceBefore = stakingApp.stakedUserBalance(account1);
        uint256 elapsePeriodBefore = stakingApp.elapsePeriod(account1);

        // IERC20(stakingToken) => Con esto inicializamos el samrt contract del stakingToken
        // Approve => recibe la direccion de quien estamos dando permiso para coger los tokens de nuestra cuenta
        IERC20(stakingToken).approve(address(stakingApp), _amount);
        stakingApp.stake(_amount);

        uint256 time = block.timestamp;
        uint256 stakedUserBalanceAfter = stakingApp.stakedUserBalance(account1);
        uint256 elapsePeriodAfter = stakingApp.elapsePeriod(account1);

        assert(stakedUserBalanceAfter - stakedUserBalanceBefore == _amount);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == time);

        vm.warp(block.timestamp + (2 * stakingPeriod_));
        vm.expectRevert();
        stakingApp.claimReward(_amountRewards);

        vm.stopPrank();
    }

    function testClaimRewardsPeriodEnouft() external {
        vm.startPrank(account1);
        uint256 _amount = stakingApp.MaxStakingAmount();
        uint256 _amountRewards = stakingApp.MaxStakingAmount();
        stakingToken.mint(_amount);

        uint256 stakedUserBalanceBefore = stakingApp.stakedUserBalance(account1);
        uint256 elapsePeriodBefore = stakingApp.elapsePeriod(account1);

        // IERC20(stakingToken) => Con esto inicializamos el samrt contract del stakingToken
        // Approve => recibe la direccion de quien estamos dando permiso para coger los tokens de nuestra cuenta
        IERC20(stakingToken).approve(address(stakingApp), _amount);
        stakingApp.stake(_amount);

        uint256 time = block.timestamp;
        uint256 stakedUserBalanceAfter = stakingApp.stakedUserBalance(account1);
        uint256 elapsePeriodAfter = stakingApp.elapsePeriod(account1);

        assert(stakedUserBalanceAfter - stakedUserBalanceBefore == _amount);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == time);

        vm.stopPrank();

        vm.startPrank(owner_);

        vm.deal(owner_, 100 ether);
        (bool success,) = address(stakingApp).call{value: 100 ether}("");
        require(success, "Transaction failed");

        vm.stopPrank();

        vm.startPrank(account1);

        vm.warp(block.timestamp + (2 * stakingPeriod_));
        uint256 etherAmountBefore = address(account1).balance;
        stakingApp.claimReward(_amountRewards);
        uint256 etherAmountAfter = address(account1).balance;
        uint256 elapsePeriod = stakingApp.elapsePeriod(account1);
        assert(etherAmountBefore < etherAmountAfter);
        assert(elapsePeriod == block.timestamp);

        vm.stopPrank();
    }
}
