// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./token.sol";

contract loanContract{
    
    // Cмартконтракт банка
    address tokenAddress;
    Token bankContract = Token(tokenAddress);

    // Сообщает о том что платеж за месяц закрыт
    event monthClosed(uint256 monthNumber, uint256 time);
    // Сообщает о получение платежа
    event paymentReceived(uint256 amount, uint256 time);
    // При вызове данной функции парсер немедленно обратит на нее внимание
    // И сообщит информацию в банк
    event didntReceiveMyPayment(address thisContractAddress, uint256 timestamp);

    address public borrower;
    address public lender;
    uint256 public amount;
    uint256 public period;
    uint256 public interestRate;

    //Хранит данные о ежемесячных платежах
    uint256[] public monthlyPayments;
    // Дата инициализации договора
    uint256 public contractStartTime;
    // Хранит таймстэмпы в которые должен производиться платёж для каждого месяца
    uint256[] public paymentCalendar;

    // Таблица содержит месяцы и информацию о том какой долг по каждому из них
    mapping(uint256 => uint256) public howMuchToPay;

    // Счетчик платежей
    uint256 public paymentsCounter = 0;

    // История платежей ( таймстэмп => сумма)
    mapping(uint256 => uint256) public paymentHistory;

    // Текущий платеж(месяц)
    uint256 public currentPayment = 0;

    constructor(address _borrower, address _lender, uint256 _amount, uint256 _period, uint256[] memory _montlyPayments, uint256 _interestRate, address _tokenAddress){
        borrower = _borrower;
        lender = _lender;
        amount = _amount * 100;
        period = _period * 12;
        monthlyPayments = _montlyPayments;
        interestRate = _interestRate;
        contractStartTime = block.timestamp;
        tokenAddress = _tokenAddress;
        createPaymentsCalendar();
        matchPaymentsAndMonths();
    }

    function createPaymentsCalendar() public {
        uint256 temp = 0;
        for(uint256 i = 0; i < period; i++){
            paymentCalendar.push(block.timestamp + temp + 2629800);
            temp += 2629800;
        }
    }

    function matchPaymentsAndMonths() public {
        for(uint i = 0; i < period; i++){
            howMuchToPay[i] = monthlyPayments[i];
        }    
    }


    function pay(uint256 paymentAmount) public {
        bool flag = bankContract.transferFrom(borrower, lender, paymentAmount);
        if(flag == true){
            paymentHistory[block.timestamp] = paymentAmount;
            paymentsCounter += 1;
            while(paymentAmount > 0){
                if(howMuchToPay[currentPayment] > paymentAmount){
                    howMuchToPay[currentPayment] -= paymentAmount;
                    paymentAmount = 0;
                } else {
                    howMuchToPay[currentPayment] -= howMuchToPay[currentPayment];
                    currentPayment += 1;
                    paymentAmount -= howMuchToPay[currentPayment];    
                }
            }
            emit paymentReceived(paymentAmount, block.timestamp);
        }
      }

    function alert() public {
        emit didntReceiveMyPayment(address(this), block.timestamp);
    }

   
}