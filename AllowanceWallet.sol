// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract AllowanceWallet {
    
    // Strucs //
    
    struct Account {
        uint balance;
        uint numPayments;
        uint numWithDraws;
        mapping (address => uint) allowanceStatus;
        mapping (uint => Payments) payments;
        mapping (uint => Withdraws) withdraws;
        
    }
    
    struct Payment {
        address to;
        uint amount;
    }
    
    struct Withdraws {
        uint amount;
        address wfrom;
        uint timestamp;
    }
    
    // Mappings //
    
    
    
    // Variables//
    
    // Modifiers //
    modifier permission {
        
        
        _;
    }
    
    
    // Functions //
    
    function depositMoney(address _to, uint _amount) public payable {
        require(walletBalance[msg.sender] +)
    }
    
    
    
}