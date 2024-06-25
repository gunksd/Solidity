// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./DutchAuction.sol";
import "./BritishAuction.sol";

contract Vault is Ownable {
    DutchAuction public dutchAuction;
    BritishAuction public britishAuction;

    mapping(address => uint256) public balances;

    event BalanceUpdated(address indexed user, uint256 newBalance);

    constructor(address _dutchAuctionAddress, address _britishAuctionAddress) {
        dutchAuction = DutchAuction(_dutchAuctionAddress);
        britishAuction = BritishAuction(_britishAuctionAddress);
    }

    /**
     * 更新用户的余额信息
     */
    function updateBalance(address user) public {
        uint256 dutchBalance = dutchAuction.getBalance(user);
        uint256 britishBalance = britishAuction.getBalance(user);
        uint256 totalBalance = dutchBalance + britishBalance;
        
        balances[user] = totalBalance;
        emit BalanceUpdated(user, totalBalance);
    }

    /**
     * 获取用户的总余额
     */
    function getTotalBalance(address user) public view returns (uint256) {
        return balances[user];
    }

    /**
     * 用户提取自己的余额
     */
    function withdraw(uint256 amount) public {
        require(amount <= balances[msg.sender], "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }
}

