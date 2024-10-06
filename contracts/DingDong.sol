// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "https://github.com/LayerZero-Labs/solidity-examples/blob/main/contracts/lzApp/NonblockingLzApp.sol";

contract DingDong is NonblockingLzApp {
    string public message = "waiting to ding";

    constructor(address _lzEndpoint) NonblockingLzApp(_lzEndpoint) Ownable() {}

    function _nonblockingLzReceive(
        uint16,
        bytes memory,
        uint64,
        bytes memory _payload
    ) internal override {
        message = abi.decode(_payload, (string));
    }

    function sendDing(uint16 destChainId) public payable {
        bytes memory payload = abi.encode("Ding");
        _lzSend(
            destChainId,
            payload,
            payable(msg.sender),
            address(0x0),
            bytes(""),
            msg.value
        );
    }

    function sendDong(uint16 destChainId) public payable {
        bytes memory payload = abi.encode("Dong");
        _lzSend(
            destChainId,
            payload,
            payable(msg.sender),
            address(0x0),
            bytes(""),
            msg.value
        );
    }

    function trustDingDong(
        uint16 destChainId,
        address _otherContract
    ) public onlyOwner {
        trustedRemoteLookup[destChainId] = abi.encodePacked(
            _otherContract,
            address(this)
        );
    }

    function estimateFeesForDingDong(
        uint16 dstChainId,
        bytes calldata adapterParams,
        string memory _message
    ) public view returns (uint256 nativeFee, uint256 zroFee) {
        bytes memory payload = abi.encode(_message);
        return
            lzEndpoint.estimateFees(
                dstChainId,
                address(this),
                payload,
                false,
                adapterParams
            );
    }
}
