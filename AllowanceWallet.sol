// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract AllowanceWallet {
    
    // Strucs //
    
    struct Account {
        address account_id;
        uint balance;
        uint numPayments;
        uint numWithDraws;
        mapping (address => uint) allowanceStatus;
        mapping (uint => Payment) payments;
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
    mapping (address => Account) userAccount;
    
    
    // Variables//
    
    
    // Modifiers //
    
    modifier accountCreated {
        // User need to create an account
        require(userAccount[msg.sender].account_id != address(0), "You need to create a user first");
        _;
    }
    
    // Functions //
    
    
    function createAccount() public {
        require(userAccount[msg.sender].account_id == address(0), "This address already has an account");
        userAccount[msg.sender].account_id = msg.sender;
    }
    
    //Deposit
    function depositMoneyTo(address _to) public payable accountCreated {
        // Over/Under - Flow validation
        assert(userAccount[_to].balance + msg.value >= userAccount[_to].balance);
        userAccount[_to].balance += msg.value;
        
        //Add payment record
        Payment memory fpayment = Payment(_to, msg.value);
        userAccount[msg.sender].payments[userAccount[msg.sender].numPayments] = fpayment;
        userAccount[msg.sender].numPayments++;
    }
    
    
    // Get User Balance
    function getUserBalance() public view returns (uint) {
        return userAccount[msg.sender].balance;
    }
    
    
    //Get Payment Information
    
    function getPaymentInformation(uint _id) public view returns (Payment memory) {
        return userAccount[msg.sender].payments[_id];
    }
    
    //Normal withdraw
    
    
    
    
    
}