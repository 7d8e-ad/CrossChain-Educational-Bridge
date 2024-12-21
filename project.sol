// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function burn(address account, uint256 amount) external;
    function mint(address account, uint256 amount) external;
}

contract CrossChainEducationalBridge {
    address public admin;
    IERC20 public token;

    event TokenLocked(address indexed user, uint256 amount, string destinationChain, string recipient);
    event TokenReleased(address indexed recipient, uint256 amount, string sourceChain);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor(address _token) {
        admin = msg.sender;
        token = IERC20(_token);
    }

    function lockTokens(
        uint256 amount,
        string calldata destinationChain,
        string calldata recipient
    ) external {
        require(amount > 0, "Amount must be greater than zero");
        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        emit TokenLocked(msg.sender, amount, destinationChain, recipient);
    }

    function releaseTokens(
        address recipient,
        uint256 amount,
        string calldata sourceChain
    ) external onlyAdmin {
        require(amount > 0, "Amount must be greater than zero");
        require(token.balanceOf(address(this)) >= amount, "Insufficient contract balance");

        token.transfer(recipient, amount);
        emit TokenReleased(recipient, amount, sourceChain);
    }

    function updateToken(address newToken) external onlyAdmin {
        token = IERC20(newToken);
}
}