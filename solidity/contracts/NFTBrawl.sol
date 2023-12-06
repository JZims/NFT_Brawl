// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/**
 :::= === :::===== :::====      :::====  :::====  :::====  :::  ===  === :::     
 :::===== :::      :::====      :::  === :::  === :::  === :::  ===  === :::     
 ======== ======     ===        =======  =======  ======== ===  ===  === ===     
 === ==== ===        ===        ===  === === ===  ===  ===  ===========  ===     
 ===  === ===        ===        =======  ===  === ===  ===   ==== ====   ========
*/

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/INFTBrawlPoints.sol";

/// @title NFT Brawl
/// @author Maerlin
/// @notice This contract manages the staking of NFTs and rewards users with "Brawl Points".
/// Users can stake their NFTs to earn rewards over time.
contract NFTBrawl is ERC721Holder, Ownable {
    using SafeERC20 for IERC20;

    struct StakingData {
        uint16 _multiplier;
        uint32 _lastClaimTimestamp;
    }

    /// @notice The ERC20 rewards' contract address
    INFTBrawlPoints public nftBrawlPoints;
    /// @notice The staked NFTs contract
    IERC721 public nftBrawlers;
    /// @notice How many rewards are distributed to every staked NFT each second.
    uint256 public rewardRate;

    /// @notice When did the address last staked an NFT, and how many (multiplier).
    mapping(address => StakingData) public addressStakingData;
    /// @notice Returns the address that originally staked the NFT.
    mapping(uint256 => address) public ownerOf;
    /// @notice Timestamp of when the emissions were stopped.
    uint256 public rewardEmissionsStoppedAt;

    /// @param _nftBrawlers Address of the ERC721 NFT contract.
    /// @param _nftBrawlPoints Address of the ERC20 Brawl Points contract.
    /// @param _rewardRate Initial reward rate for the staking.
    constructor(
        address _nftBrawlers,
        address _nftBrawlPoints,
        uint256 _rewardRate
    ) {
        nftBrawlers = IERC721(_nftBrawlers);
        nftBrawlPoints = INFTBrawlPoints(_nftBrawlPoints);
        rewardRate = _rewardRate;
    }

    /// @notice Claim caller's accumulated rewards.
    function claimRewards() public {
        uint256 _accruedRewards = _calculateRewards(msg.sender);

        addressStakingData[msg.sender]._lastClaimTimestamp = uint32(
            block.timestamp
        );

        if (_accruedRewards == 0) {
            return;
        }

        nftBrawlPoints.mint(msg.sender, _accruedRewards);
    }

    /// @notice Stake the provided token IDs
    /// @param _tokenIds array of Token IDs of the NFTs to be staked
    /// @dev The Token IDs have to be previously approved in the ERC721 contract
    function stake(uint256[] calldata _tokenIds) external {
        require(_tokenIds.length > 0, "NFTBrawl: No tokens provided");
        require(
            rewardEmissionsStoppedAt == 0,
            "NFTBrawl: Staking is disabled"
        );

        // Claim rewards before staking more tokens
        claimRewards();

        // There's only 10 000 tokens, so no risk of overflow here.
        unchecked {
            // Update staking data for this address
            addressStakingData[msg.sender]._multiplier += uint16(
                _tokenIds.length
            );
        }

        for (uint256 _i = 0; _i < _tokenIds.length; ++_i) {
            uint256 _tokenId = _tokenIds[_i];
            ownerOf[_tokenId] = msg.sender;
            nftBrawlers.safeTransferFrom(msg.sender, address(this), _tokenId);
        }
    }

    /// @notice Withdraw NFTs from staking
    /// @param _tokenIds array of Token IDs of the NFTs to be withdrawn
    function withdraw(uint256[] calldata _tokenIds) external {
        require(_tokenIds.length > 0, "NFTBrawl: No tokens provided");

        claimRewards();

        // Clean storage data before sending the NFTs back to the owner
        _cleanStorageBeforeUnstaking(_tokenIds);

        for (uint256 _i = 0; _i < _tokenIds.length; ++_i) {
            nftBrawlers.safeTransferFrom(address(this), msg.sender, _tokenIds[_i]);
        }
    }

    /// @notice Set the reward rate
    /// @param _rewardRate Monthly reward amount
    function setRewardRate(uint256 _rewardRate) external onlyOwner {
        rewardRate = _rewardRate;
    }

    /// @notice Check available rewards for an address
    /// @param _address The address whose rewards are to be checked
    function getAvailableRewards(
        address _address
    ) external view returns (uint256) {
        return _calculateRewards(_address);
    }

    /// @dev Clean up before unstaking tokens.
    /// @param _tokenIdsToUnstake The Token IDs to unstake
    function _cleanStorageBeforeUnstaking(
        uint256[] calldata _tokenIdsToUnstake
    ) internal {
        for (uint256 _i = 0; _i < _tokenIdsToUnstake.length; ++_i) {
            uint256 _tokenId = _tokenIdsToUnstake[_i];
            // Check for duplicates in the provided array
            for (uint256 _j = _i + 1; _j < _tokenIdsToUnstake.length; ++_j) {
                uint256 _tokenIdDuplicate = _tokenIdsToUnstake[_j];
                require(
                    _tokenId != _tokenIdDuplicate,
                    "NFTBrawl: No duplicates allowed"
                );
            }

            // Check if the caller is the address that originally staked the token
            require(
                ownerOf[_tokenId] == msg.sender,
                "NFTBrawl: Caller is not the token owner"
            );
            delete ownerOf[_tokenId];
        }

        unchecked {
            addressStakingData[msg.sender] = StakingData(
                addressStakingData[msg.sender]._multiplier -
                    uint16(_tokenIdsToUnstake.length),
                uint32(block.timestamp)
            );
        }
    }

    /// @notice Returns the token IDs staked by this address
    /// @dev Loops and read the storage until all of the tokens are found, ONLY USE OFF-CHAIN
    function tokensOfOwner(
        address _address
    ) external view returns (uint256[] memory) {
        uint256 _amountOwnedByAddress = addressStakingData[_address]
            ._multiplier;
        uint256 _tokensFound = 0;
        uint256[] memory _tokensOfOwner = new uint256[](_amountOwnedByAddress);

        // highest token ID is 9 999
        for (uint256 _i = 0; _amountOwnedByAddress != _tokensFound; _i++) {
            if (ownerOf[_i] != _address) {
                continue;
            }

            _tokensOfOwner[_tokensFound] = _i;
            ++_tokensFound;
        }

        return _tokensOfOwner;
    }

    /// @notice Calculate rewards for a given address.
    /// @param _address Address we need to calculate the rewards for
    function _calculateRewards(
        address _address
    ) internal view returns (uint256 totalReward) {
        StakingData memory _stakingData = addressStakingData[_address];
        uint256 __rewardEmissionsStoppedAt = rewardEmissionsStoppedAt;

        // If the emission of rewards was stopped before the last claim, return 0
        if (
            __rewardEmissionsStoppedAt != 0 &&
            __rewardEmissionsStoppedAt <= _stakingData._lastClaimTimestamp
        ) {
            return 0;
        }

        uint256 _latestTimestamp = __rewardEmissionsStoppedAt > 0
            ? __rewardEmissionsStoppedAt
            : block.timestamp;

        unchecked {
            return
                (_latestTimestamp - _stakingData._lastClaimTimestamp) *
                _stakingData._multiplier *
                rewardRate;
        }
    }

    /// @notice Stops staked NFTs from accruing more rewards.
    /// @dev ONLY FOR EMERGENCIES, cannot be reverted as it will break the rewards calculation's logic
    function stopRewardsEmission() external onlyOwner {
        rewardEmissionsStoppedAt = block.timestamp;
    }
}
