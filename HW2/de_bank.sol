pragma solidity ^0.6.0;

contract de_bank{
    address payable public owner; //學號映射到地址
    mapping(string => address) public students; //地址映射到存款金額
    mapping(address => uint256) public balances; //銀行的擁有者，會在constructor做設定
    
    //可以讓使用者call這個函數把錢存進合約地址，並且在balances中紀錄使用者的帳戶金額
    function deposit(address studentAddress,uint256 depo_amount) external payable{
        depo_amount = msg.value;
        balances[studentAddress] = depo_amount;
    }
    //可以讓使用者從合約提錢，這邊需要去確認合約裡的餘額 >= 想提的金額
    function withdraw(uint256 withd_amount, address studentAddress) external{
        require(balances[studentAddress] >= withd_amount, "Not enough balances.");
        balances[studentAddress] = withd_amount;
    }
    //可以讓使用者從合約轉帳給某個地址，這邊需要去確認合約裡的餘額 >= 想轉的金額
    //實現的是銀行內部轉帳，也就是說如果轉帳成功balances的目標地址會增加轉帳金額
    function transfer(uint256 tranf_amount, address studentAddress) external{
        if (tranf_amount > balances[studentAddress]) 
            revert("Not enough amount.");
        balances[studentAddress] = tranf_amount;
    }
    //透過students把學號映射到使用者的地址
    function enroll(string memory studentId) public { 
        students[studentId] = msg.sender;
    }
    //從balances回傳使用者的銀行帳戶餘額
    function getBalance() external view returns(uint256){
        return balances[msg.sender];
    }
    //回傳銀行合約的所有餘額，設定為只有owner才能呼叫成功
    function getBankBalance(address studentAddress) public view returns(uint256){
        require(owner == msg.sender, "Permission denied");
        return balances[studentAddress];
    }
    //設定owner為創立合約的人
    constructor () public payable{
        owner = msg.sender;
    }
    //當觸發fallback時，檢查觸發者是否為owner，是則自殺合約，把合約剩餘的錢轉給owner
    fallback() external {
        require(owner == msg.sender, "Permission denied");
        selfdestruct(owner);
    }
    
}
