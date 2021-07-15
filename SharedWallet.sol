// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract SharedWallet {
    
    // Strucs ////////////
    
    struct Account {
        address account_id;
        uint balance;
        uint numPayments;
        uint numWithDraws;
        mapping (address => uint) allowanceMapping;
        mapping (uint => Payment) payments;
        mapping (uint => Withdraws) withdraws;
        
    }
    
    struct Payment {
        address _from;
        address to;
        uint amount;
        bool receivedFromOtherAccount;
        uint timestamp;
    }
    
    struct Withdraws {
        uint amount;
        address wfrom;
        address wto;
        uint timestamp;
        bool withdrawedFromAllowance;
    }
    
    // Mappings ///////////
    mapping (address => Account) userAccount;
    
    
    // Modifiers //////////
    
    modifier accountCreated {
        // User need to create an account
        require(userAccount[msg.sender].account_id != address(0), "You need to create a user first");
        _;
    }
    
    // Functions //////////
    
    
    function createAccount() public {
        require(userAccount[msg.sender].account_id == address(0), "This address already has an account");
        userAccount[msg.sender].account_id = msg.sender;
    }
    
    // Deposit Money to your account - Also used in fallback and receive Functions
    
    function depositMoney() public payable accountCreated {
        // Over/Under - Flow validation
        assert(userAccount[msg.sender].balance + msg.value >= userAccount[msg.sender].balance);
        userAccount[msg.sender].balance += msg.value;
        
        //Add payment record
        Payment memory payment = Payment(msg.sender, msg.sender, msg.value, false, block.timestamp);
        userAccount[msg.sender].payments[userAccount[msg.sender].numPayments] = payment;
        userAccount[msg.sender].numPayments++;
    }
    
    //Transfer Money to specific account
    function transferMoney(address _to, uint _amount) public accountCreated {
        // Over/Under - Flow validation
        assert(userAccount[_to].balance + _amount >= userAccount[_to].balance);
        require(userAccount[msg.sender].balance - _amount <= userAccount[msg.sender].balance);
        require(userAccount[msg.sender].balance - _amount >= 0);
        userAccount[_to].balance += _amount;
        userAccount[msg.sender].balance -= _amount;
        
        //Add payment record - sender
        Payment memory spayment = Payment(msg.sender, _to, _amount, false, block.timestamp);
        userAccount[msg.sender].payments[userAccount[msg.sender].numPayments] = spayment;
        userAccount[msg.sender].numPayments++;
        
        //add payment record - receiver
        Payment memory rpayment = Payment(msg.sender, _to, _amount, true, block.timestamp);
        userAccount[msg.sender].payments[userAccount[msg.sender].numPayments] = rpayment;
        userAccount[msg.sender].numPayments++;
    }
    
    
    // Get User Balance
    function getUserBalance() public view accountCreated returns (uint) {
        return userAccount[msg.sender].balance;
    }
    
    
    //Get Payment Information
    
    function getPaymentInformation(uint _id) public view accountCreated returns (Payment memory) {
        return userAccount[msg.sender].payments[_id];
    }
    
    //Set Allowance for an account
    
    function SetAllowance(address _to, uint _amount) public accountCreated {
        // Over/Under - Flow validation
        require(userAccount[msg.sender].balance >= _amount, "Not enought money");
        require(msg.sender != _to, "Cannot set allowance to yourself");
        userAccount[msg.sender].allowanceMapping[_to] = _amount;
    }
    
    // View current allowance amount for user
    function viewCurrentAllowanceBalance(address _from, address _to) public view accountCreated returns (uint){
        // Only the giver or the receiver can view the allowance status
        assert(_from == msg.sender || _to == msg.sender);
        return userAccount[_from].allowanceMapping[_to];
    }
    
    
    //Withdraw Money from userAccount
    function withdrawMoney(uint _amount) public accountCreated {
        // Test withdraw is valid
        assert(userAccount[msg.sender].balance - _amount <= userAccount[msg.sender].balance);
        require(userAccount[msg.sender].balance - _amount >= 0);
        
        //Withdraw
        userAccount[msg.sender].balance -= _amount;
        payable(msg.sender).transfer(_amount);
        
        //Add Withdraw details to the withdraws mapping
        Withdraws memory withdraw = Withdraws(_amount, msg.sender, msg.sender, block.timestamp, false);
        userAccount[msg.sender].withdraws[userAccount[msg.sender].numWithDraws] = withdraw;
        userAccount[msg.sender].numWithDraws++;
        
    }
    
    // Withdraw money from Allowance
    function withdrawFromAllowance(address _from, address _to, uint _amount) public accountCreated {
        assert(msg.sender == _to);
        
        // Test withdraw is valid
        require(userAccount[_from].allowanceMapping[_to] - _amount <= _amount, 'Invalid Amount');
        require(userAccount[_from].allowanceMapping[_to] - _amount >= 0, 'Not enought money');
        
        //Withdraw
        userAccount[_from].allowanceMapping[_to] -= _amount;
        userAccount[_from].balance -= _amount;
        payable(_to).transfer(_amount);
        
        //Add Withdraw details to the withdraws mapping for both users (allowance giver and receiver)
        Withdraws memory withdraw = Withdraws(_amount, _from, _to, block.timestamp, true);
        //receiver
        userAccount[msg.sender].withdraws[userAccount[msg.sender].numWithDraws] = withdraw;
        userAccount[msg.sender].numWithDraws++;
        //giver
        userAccount[_to].withdraws[userAccount[_to].numWithDraws] = withdraw;
        userAccount[_to].numWithDraws++;
        
    }
    
    function getWithdrawInformation(uint _index) public view returns(Withdraws memory) {
        return userAccount[msg.sender].withdraws[_index];
    }
    
    fallback() external payable {
        depositMoney();
    }

    receive() external payable {
        depositMoney();
    }
    
}