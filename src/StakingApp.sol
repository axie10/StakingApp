// SPDX-License-Identifier: MIT
pragma solidity 0.8.35;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// 1. Stakingtoken address
// 2. Admin account
// 3. Only stake amount that smart contract define
// 4. Staking rewards periods => one day => rewards withDraw

contract StakingApp is Ownable, ReentrancyGuard {
    // Variables
    address public StakingToken;
    uint256 public stakingPeriod;
    uint256 public TotalBalanceStaked;
    uint256 public MaxStakeingAmount;
    uint256 public RewardsPerPeriod;
    mapping(address => uint256) public stakedUserBalance;
    mapping(address => uint256) public elapsePeriod;
    // Use `safe` to check that the transfer functions are correct; this is better than using a boolean and `require`, as some tokens do not comply with the standard and not return boolean
    using SafeERC20 for IERC20;

    // Events
    event ChangeStakingPeriod(uint256 stakingPeriod);
    event StakeTokens(address account, uint256 stakingPeriod);
    event UnStakeTokens(address account, uint256 stakingPeriod);
    event ReceiveEth(uint256 stakingPeriod);

    // Modifiers

    // Constructor
    constructor(
        address StakingToken_,
        address owner_,
        uint256 stakingPeriod_,
        uint256 maxStakeingAmount_,
        uint256 rewardsPerPeriod_
    ) Ownable(owner_) {
        StakingToken = StakingToken_;
        stakingPeriod = stakingPeriod_;
        MaxStakeingAmount = maxStakeingAmount_;
        RewardsPerPeriod = rewardsPerPeriod_;
    }

    // Functions : first external functions, second internal functions
    // Use modifier of ERC20
    function changeStakingPeriod(uint256 newStakingPeriod_) external onlyOwner {
        stakingPeriod = newStakingPeriod_;
        emit ChangeStakingPeriod(newStakingPeriod_);
    }

    // 1. Deposit
    function stake(uint256 _amount) external nonReentrant {
        require(_amount > 0, "the amount must be greater than zero");
        require(_amount <= MaxStakeingAmount, "the amount must be less than ten");
        require(stakedUserBalance[msg.sender] == 0, "user already deposit");
        // after transfer token need call approve
        IERC20(StakingToken).safeTransferFrom(msg.sender, address(this), _amount);
        stakedUserBalance[msg.sender] += _amount;
        elapsePeriod[msg.sender] = block.timestamp;
        TotalBalanceStaked += _amount;
        emit StakeTokens(msg.sender, _amount);
    }

    // 2. WithDraw
    function unStake(uint256 _amount) external nonReentrant {
        require(stakedUserBalance[msg.sender] <= _amount, "insufficient funds");
        // first apdate balance CEI
        stakedUserBalance[msg.sender] -= _amount;
        TotalBalanceStaked -= _amount;
        // second transfer tokens
        IERC20(StakingToken).safeTransfer(msg.sender, _amount);
        emit UnStakeTokens(msg.sender, _amount);
    }

    // 3. Claim Rewards
    function claimReward(uint256 reward) external nonReentrant {
        // 1. check balance
        require(reward > 0, "No hay recompensas pendientes");

        // 2. calculate period that staked
        uint256 elapsePeriod_ = block.timestamp - elapsePeriod[msg.sender];
        require(elapsePeriod_ > stakingPeriod, "need to wait");

        // 3. update state
        elapsePeriod[msg.sender] = block.timestamp;

        // 4. calculate and transfer rewards
        (bool success,) = payable(msg.sender).call{value: RewardsPerPeriod}("");
        require(success, "transfer failed");
    }

    // 4. Funds rewards
    function fundRewards(uint256 reward) external payable onlyOwner {
        require(reward > 0, "No hay recompensas pendientes");
        IERC20(StakingToken).safeTransferFrom(msg.sender, address(this), reward);
    }

    receive() external payable onlyOwner {
        emit ReceiveEth(msg.value);
    }

    // Try functions inherited of Ownable
    function getOwner() external view returns (address) {
        address v = Ownable.owner();
        return v;
    }

    function getOwner2() external view onlyOwner returns (address) {
        address v = Ownable.owner();
        return v;
    }
}
