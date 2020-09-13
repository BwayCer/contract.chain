pragma solidity ^0.5.1;

contract RandMeido {
    address payable private _ownerPayable;
    address private _owner = _ownerPayable;

    bytes32 private _solSaltA;
    bytes32 private _solSaltB;

    modifier onlyOwner() {
        require(msg.sender == _owner, "NiMen: caller is not the owner");
        _;
    }

    // 合約轉讓
    function transfer(address payable newOwner) external {
        address noone;
        if (_owner != noone) {
            require(msg.sender == _owner, "NiMen: caller is not the owner");
        }
        _ownerPayable = newOwner;
        _owner = newOwner;
    }

    // 提款
    function withdraw() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    // 自毀合約
    function kill() external onlyOwner {
        selfdestruct(_ownerPayable);
    }

    function updateSalt() private {
        _solSaltB = sha256(abi.encodePacked(now, _solSaltB));
        _solSaltA = keccak256(abi.encodePacked(_solSaltA, _solSaltB));
    }

    // 設定新鹽
    function setSalt(bytes calldata salt) external onlyOwner {
        _solSaltB = sha256(abi.encodePacked(_solSaltB, salt));
        updateSalt();
    }

    event GetRandLog(
      uint128 indexed total,
      uint128 rand,
      bytes32 salt
    );

    // 取得隨機數
    function getRand(uint128 total) external payable returns(uint128 rand) {
        require(msg.value >= 0.01 szabo, "RandMeido: Please pay 10 gwei");

        updateSalt();
        uint256 seed = uint256(uint128(bytes16(_solSaltA)));
        uint256 uint128Max = 340282366920938463463374607431768211455;
        // NOTE:
        //   1. 當 seed 與 max 量級差異愈大，隨機數愈平均。
        //   2. 先取十倍於自己的量在取餘數得到結果
        //      是因為出現 0 及最大值的機率似乎略少而做的改變。
        //      (2159 筆 0~99 的實驗中 0 有 17 次，99 有 8 次。)
        // (((seed / uint128Max) * (total * 10 - 1) * 10 + 5) / 10) % total;
        rand = uint128(
          (seed  * (total * 10 - 1) * 10 / uint128Max + 5) / 10 % total
        );
        emit GetRandLog(total, rand, _solSaltA);
        return rand;
    }
}
