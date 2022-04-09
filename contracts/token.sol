// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./loancontract.sol";

contract Token is ERC20 {

    constructor() ERC20("BANK", "BANK") {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }

    function decimals() public view virtual override returns (uint8) {
        return 2;
    }

    // Хранит список всех кредитных контрактов и их номера (индекс контракта => адрес контракта)
    mapping(uint256 => address) loanContractsList;
    uint256 loanContractsIndex = 0;

    // Хранит черный список
    mapping(address => bool) blackList;

    function createContract(address _borrower, address _lender, uint256 _amount, uint256 _period, uint256[] memory _montlyPayments, uint256 _interestRate) public{
        require(blackList[_borrower] != true, "This guy is in blacklisted");
        loanContract x = new loanContract(_borrower, _lender, _amount, _period, _montlyPayments, _interestRate, address(this));
        loanContractsList[loanContractsIndex] = address(x);
        loanContractsIndex += 1;
    }

    function addToBlackList(address badGuy) public{
        blackList[badGuy] = true;
    }
 
}