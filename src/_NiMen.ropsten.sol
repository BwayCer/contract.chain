pragma solidity ^0.7.1;

// SPDX-License-Identifier: CC0-1.0

contract NiMen {
    uint160 private _owner;

    bytes32 private _solSaltA;
    bytes32 private _solSaltB;

    modifier onlyOwner() {
        require(msg.sender == address(_owner), "NiMen: caller is not the owner.");
        _;
    }

    modifier onlyPlayer() {
        require(msg.sender == tx.origin, "NiMen: caller is not the player.");
        _;
    }

    // 合約轉讓
    function transfer(uint160 newOwner) external {
        uint160 noone;
        if (_owner != noone) {
            require(msg.sender == address(_owner), "NiMen: caller is not the owner.");
        }
        _owner = newOwner;
    }

    // 取得餘額
    // `web3.eth.getBalance()`
    // function balance() public view returns(uint256) {
    //     return address(this).balance;
    // }

    // 存款
    function deposit() external payable {}

    // 提款
    function withdraw() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    // 自毀合約
    // https://medium.com/taipei-ethereum-meetup/7bd2503409d4
    function kill() external onlyOwner {
        selfdestruct(address(_owner));
    }

    uint160 public contractRandMeido;

    // 設定 RandMeido 合約地址
    function setRandMeidoAddress(uint160 RandMeidoAddress) external onlyOwner {
        contractRandMeido = RandMeidoAddress;
    }

    // 取得隨機數
    // 參考 RandMeido.sol 取隨機數的方法
    function getRand(uint128 total) internal returns(uint128) {
        // NOTE: 外部合約失敗與否並不會有提示
        require(msg.value >= 1000 gwei, "NiMen: Please pay 1000 gwei.");
        (bool isOk, bytes memory data) = address(contractRandMeido)
            .call{value: 1000 gwei}(
                abi.encodeWithSignature("getRand(uint128)", total)
            );
        require(isOk, "NiMen: Failed to take random number.");
        return abi.decode(data, (uint128));
    }
}
