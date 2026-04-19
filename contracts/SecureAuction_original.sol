// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SecureAuction {
    address public owner;
    address public highestBidder;
    uint public highestBid;
    bool public ended;

    mapping(address => uint) private pendingReturns;

    event OwnerChanged(address indexed previousOwner, address indexed newOwner);
    event BidPlaced(address indexed bidder, uint amount);
    event AuctionEnded(address indexed winner, uint amount);
    event Withdrawal(address indexed bidder, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier auctionActive() {
        require(!ended, "Auction has ended");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address not allowed");
        emit OwnerChanged(owner, newOwner);
        owner = newOwner;
    }

    function bid() external payable auctionActive {
        require(msg.value > highestBid, "Bid too low");
        if (highestBidder != address(0)) {
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit BidPlaced(msg.sender, msg.value);
    }

    function withdraw() external {
        uint amount = pendingReturns[msg.sender];
        require(amount > 0, "Nothing to withdraw");
        pendingReturns[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        emit Withdrawal(msg.sender, amount);
    }

    function endAuction() external onlyOwner auctionActive {
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
        uint amount = highestBid;
        highestBid = 0;
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Transfer failed");
    }
}
