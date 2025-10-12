// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title KipuBank - Vault bank with per-transaction withdraw limit and global deposit cap
/// @author Isabel
/// @notice Educational contract that allows users to deposit and withdraw ETH with limits.
/// @dev Implements checks-effects-interactions, custom errors, events and NatSpec.
contract KipuBank {
    /* ========== ERRORS ========== */

    /// @notice Reverted when a zero amount is provided where >0 is required.
    error AmountMustBeGreaterThanZero();

    /// @notice Reverted when a deposit would exceed the global bank cap.
    /// @param attempted The attempted new total after deposit.
    /// @param available Remaining available capacity.
    error BankCapExceeded(uint256 attempted, uint256 available);

    /// @notice Reverted when a withdraw request exceeds the per-transaction limit.
    /// @param requested The requested withdraw amount.
    /// @param limit The configured withdraw limit.
    error ExceedsWithdrawLimit(uint256 requested, uint256 limit);

    /// @notice Reverted when the caller tries to withdraw more than their balance.
    /// @param requested The requested amount.
    /// @param available The caller's available balance.
    error InsufficientBalance(uint256 requested, uint256 available);

    /// @notice Reverted when an ETH transfer fails.
    /// @param to Destination address.
    /// @param amount The transfer amount.
    error TransferFailed(address to, uint256 amount);

    /* ========== EVENTS ========== */

    /// @notice Emitted when a user deposits ETH.
    event Deposit(address indexed user, uint256 amount, uint256 indexed depositIndex);

    /// @notice Emitted when a user withdraws ETH.
    event Withdrawal(address indexed user, uint256 amount, uint256 indexed withdrawalIndex);

    /* ========== IMMUTABLE / CONSTANTS ========== */

    /// @notice Max amount (in wei) a user can withdraw in a single transaction.
    uint256 public immutable withdrawLimit;

    /// @notice Global cap (in wei) of total deposits the bank accepts.
    uint256 public immutable bankCap;

    /* ========== STORAGE ========== */

    /// @notice Mapping of user address to vault balance (in wei).
    mapping(address => uint256) private balances;

    /// @notice Sum total of ETH currently held in the contract (in wei).
    uint256 public totalDeposited;

    /// @notice Counter for total deposit operations.
    uint256 public depositCount;

    /// @notice Counter for total withdrawal operations.
    uint256 public withdrawalCount;

    /* ========== MODIFIERS ========== */

    /// @notice Ensures the amount is greater than zero.
    /// @param _amount The amount to check.
    modifier nonZeroAmount(uint256 _amount) {
        if (_amount == 0) revert AmountMustBeGreaterThanZero();
        _;
    }

    /* ========== CONSTRUCTOR ========== */

    /// @notice Initialize the bank with immutable limits.
    /// @param _withdrawLimit Max withdraw per tx (wei).
    /// @param _bankCap Global deposit cap (wei).
    constructor(uint256 _withdrawLimit, uint256 _bankCap) {
        if (_withdrawLimit == 0) revert AmountMustBeGreaterThanZero();
        if (_bankCap == 0) revert AmountMustBeGreaterThanZero();

        withdrawLimit = _withdrawLimit;
        bankCap = _bankCap;
    }

    /* ========== USER FUNCTIONS ========== */

    /// @notice Deposit native ETH into caller's vault.
    /// @dev Follows checks-effects-interactions. Emits {Deposit} on success.
    function deposit() external payable nonZeroAmount(msg.value) {
        // Checks
        if (totalDeposited + msg.value > bankCap) {
            revert BankCapExceeded(totalDeposited + msg.value, bankCap - totalDeposited);
        }

        // Effects
        balances[msg.sender] += msg.value;
        totalDeposited += msg.value;
        depositCount += 1;
        uint256 thisDepositIndex = depositCount;

        // Interactions (none external besides event)
        emit Deposit(msg.sender, msg.value, thisDepositIndex);
    }

    /// @notice Withdraw up to the configured per-transaction limit.
    /// @param _amount Amount to withdraw (in wei).
    /// @dev Updates state before external call and emits {Withdrawal}.
    function withdraw(uint256 _amount) external nonZeroAmount(_amount) {
        // Checks
        if (_amount > withdrawLimit) revert ExceedsWithdrawLimit(_amount, withdrawLimit);
        uint256 available = balances[msg.sender];
        if (_amount > available) revert InsufficientBalance(_amount, available);

        // Effects
        balances[msg.sender] = available - _amount;
        totalDeposited -= _amount;
        withdrawalCount += 1;
        uint256 thisWithdrawalIndex = withdrawalCount;

        // Interactions
        _safeTransfer(msg.sender, _amount);

        emit Withdrawal(msg.sender, _amount, thisWithdrawalIndex);
    }

    /* ========== PRIVATE HELPERS ========== */

    /// @notice Safely transfer ETH to `_to`.
    /// @param _to Destination address.
    /// @param _amount Amount in wei.
    /// @dev Uses call and reverts on failure.
    function _safeTransfer(address _to, uint256 _amount) private {
        (bool success, ) = _to.call{ value: _amount }("");
        if (!success) revert TransferFailed(_to, _amount);
    }

    /* ========== VIEW FUNCTIONS ========== */

    /// @notice Returns the stored balance for `_user`.
    /// @param _user Address to query.
    /// @return The balance in wei.
    function getBalance(address _user) external view returns (uint256) {
        return balances[_user];
    }

    /// @notice Returns total deposit operations count.
    /// @return Number of deposits.
    function getDepositCount() external view returns (uint256) {
        return depositCount;
    }

    /// @notice Returns total withdrawal operations count.
    /// @return Number of withdrawals.
    function getWithdrawalCount() external view returns (uint256) {
        return withdrawalCount;
    }
}
