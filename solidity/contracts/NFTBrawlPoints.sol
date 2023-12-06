// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/**
 :::= === :::===== :::====      :::====  :::====  :::====  :::  ===  === :::     
 :::===== :::      :::====      :::  === :::  === :::  === :::  ===  === :::     
 ======== ======     ===        =======  =======  ======== ===  ===  === ===     
 === ==== ===        ===        ===  === === ===  ===  ===  ===========  ===     
 ===  === ===        ===        =======  ===  === ===  ===   ==== ====   ========
*/

/// @title NFT Brawl Points
/// @author Maerlin
/// @notice This contract manages the ERC20 NFT Brawl ecosystem token.
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/INFTBrawlPoints.sol";

contract NFTBrawlPoints is INFTBrawlPoints, ERC20Burnable, Ownable {
    /// @notice Mapping of addresses that are authorized to perform certain operations.
    mapping(address => bool) public authList;

    /// @param _name The name of the token.
    /// @param _symbol The symbol of the token.
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {}

    /// @dev Throws if called by an unauthorized address
    modifier onlyAuthorized() {
        require(
            authList[msg.sender],
            "NFTBrawlPoints: caller is not authorized"
        );
        _;
    }

    /// @notice Mints new tokens.
    /// @dev Can only be called by authorized addresses.
    /// @param to Address to which tokens will be minted.
    /// @param amount Amount of tokens to mint.
    function mint(address to, uint256 amount) public onlyAuthorized {
        _mint(to, amount);
    }

    /// @notice Adds an address to the authorized list.
    /// @param _auth Address to be authorized.
    /// @dev Can only be called by the contract owner.
    function addAuthorized(address _auth) external onlyOwner {
        authList[_auth] = true;
    }

    /// @notice Removes an address from the authorized list.
    /// @param _auth Address to be de-authorized.
    /// @dev Can only be called by the contract owner.
    function removeAuthorized(address _auth) external onlyOwner {
        authList[_auth] = false;
    }

    /// @notice Checks if an address is authorized.
    /// @param _auth Address to check.
    /// @return isAuth Returns true if the address is authorized, false otherwise.
    function isAuthorized(address _auth) external view returns (bool) {
        return authList[_auth];
    }
}
