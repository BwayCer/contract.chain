pragma solidity ^0.7.1;

// SPDX-License-Identifier: CC0-1.0

contract RandMeido {
    uint160 private _owner;

    bytes32 private _solSaltA;
    bytes32 private _solSaltB;

    modifier onlyOwner() {
        require(msg.sender == address(_owner), "NiMen: caller is not the owner.");
        _;
    }

    function transfer(uint160 newOwner) external {
        uint160 noone;
        if (_owner != noone) {
            require(msg.sender == address(_owner), "NiMen: caller is not the owner.");
        }
        _owner = newOwner;
    }

    function withdraw() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    function kill() external onlyOwner {
        selfdestruct(address(_owner));
    }

    function updateSalt() private {
        _solSaltB = sha256(abi.encodePacked(block.timestamp, _solSaltB));
        _solSaltA = keccak256(abi.encodePacked(_solSaltA, _solSaltB));
    }

    function setSalt(bytes calldata salt) external onlyOwner {
        _solSaltB = sha256(abi.encodePacked(_solSaltB, salt));
        updateSalt();
    }

    event GetRandLog(
      uint128 indexed total,
      uint128 rand,
      bytes16 salt
    );

    function getRand(uint128 total) external payable returns(uint128 rand) {
        require(msg.value >= 1000 gwei, "RandMeido: Please pay 1000 gwei.");

        updateSalt();
        bytes16 useSalt = bytes16(_solSaltA);
        uint256 seed = uint256(uint128(useSalt));
        uint256 uint128Max = 340282366920938463463374607431768211455;
        // NOTE:
        // 1. 當 seed 與 max 量級差異愈大，隨機數愈平均。
        // 2. 先取十倍於自己的量在取餘數得到結果
        //    是因為出現 0 及最大值的機率似乎略少而做的改變。
        //    (2159 筆 0~99 的實驗中 0 有 17 次，99 有 8 次。)
        // NOTE:
        // 為避免整數類型自動忽略小數而調整算式算法, 其原型如下: (以 JS 非大數類型表達)
        // `Math.round((seed / uint128Max) * (total * 10 - 1)) % total`
        rand = uint128(
          (seed  * (total * 10 - 1) * 10 / uint128Max + 5) / 10 % total
        );
        emit GetRandLog(total, rand, useSalt);
        return rand;
    }
    // 以 JS 驗證
    // function getRand(seed, total) {
    //   let uint128Max = BigInt('0xffffffffffffffffffffffffffffffff');
    //   return (BigInt(seed) * (BigInt(total) * BigInt(10) - BigInt(1)) * BigInt(10) / uint128Max + BigInt(5)) / BigInt(10) % BigInt(total);
    // }
}
