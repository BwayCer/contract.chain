pragma solidity ^0.7.1;

// SPDX-License-Identifier: CC0-1.0

import "./_NiMen.ropsten.sol";

contract GemuPlay is NiMen {
    // --- 終極密碼 ---

    uint8 private ultiPw;
    uint8 private smallerNumber;
    uint8 private largerNumber;

    function getUltiPwState() external view returns(uint8, uint8) {
        return (smallerNumber, largerNumber);
    }

    event PlayUltimatePasswordLog(
        bool indexed isWin,
        address indexed player,
        uint256 bonus,
        uint8 pw,
        uint8[] bets,
        uint256 amount
    );

    function PlayUltimatePassword(uint8[] calldata bets) external payable onlyPlayer {
        bool isWin = false;
        uint8 rangeCount = largerNumber - smallerNumber + 1;
        uint256 betsLen = bets.length;
        uint256 payRate = rangeCount / betsLen;
        uint256 bonus = msg.value * payRate * 98 / 100;
        uint256 canPay = address(this).balance / 2;

        require(bonus < canPay, "UltimatePassword: Please reduce the bet amount.");

        for (uint8 idx = 0; idx < betsLen; idx++) {
            uint8 bet = bets[idx];

            if (bet == ultiPw) {
                isWin = true;
                break;
            } else if (bet < ultiPw && bet > smallerNumber) {
                smallerNumber = bet;
            } else if (bet > ultiPw && bet < largerNumber) {
                largerNumber = bet;
            }
        }

        uint8 showUltiPw = 0;
        if (isWin) {
            showUltiPw = ultiPw;
            smallerNumber = 0;
            largerNumber = 100;
            ultiPw = uint8(getRand(98)) + 1;
            msg.sender.transfer(bonus);
        }

        emit PlayUltimatePasswordLog(
            isWin,
            msg.sender,
            bonus,
            showUltiPw,
            bets,
            msg.value
        );
    }
}
