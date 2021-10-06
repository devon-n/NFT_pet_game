// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC721, Ownable {

    constructor (string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    struct Pet { // Pet attributes
        string name;
        uint256 level;
        uint256 health;
        uint256 lastMeal;
        uint256 damage;
        uint256 petId;
    }

    // Starting variables
    uint256 startingLevel = 0;
    uint256 startingHealth = 100000;
    uint256 startingDamage = 1;
    
    uint256 creationFee = 0.0001 ether;
    uint256 petIdCounter;

    // Mappings to keep track of owners
    mapping (address => uint256) public OwnerToPetId;
    mapping (address => Pet[]) public OwnerToAllPets;
    mapping (uint256 => Pet) public PetIdToPetDetails;
    


    function mint(string memory _name) public payable onlyOwner {
        require(msg.value >= creationFee, "Insufficient funds to create pet");
        Pet memory newPet = Pet(_name, startingLevel, startingHealth, block.timestamp, startingDamage, petIdCounter); // Create a pet details
        _safeMint(msg.sender, petIdCounter, ""); // Mint the pet
        PetIdToPetDetails[petIdCounter] = newPet; // Pet Id to pet details
        OwnerToAllPets[msg.sender].push(newPet); // Add pet to all owners pets array
        OwnerToPetId[msg.sender] = petIdCounter; // Add pet id to owner mapping
        petIdCounter++; // increment pet id
    }

    function feed (uint256 _petId) public { // Feed function
        require(OwnerToPetId[msg.sender] == _petId, "You are not the owner of this pet."); // Only the owner of a pet can feed it
        require((PetIdToPetDetails[_petId].lastMeal + PetIdToPetDetails[_petId].health) > block.timestamp); // Check if the pet has not feed in too long and is dead
        Pet storage pet = PetIdToPetDetails[_petId]; // Get the pet to change details
        pet.lastMeal = block.timestamp; // Set the last meal to now
    }

    function getTokenDetails(uint256 _tokenId) public view returns (Pet memory) {
        return PetIdToPetDetails[_tokenId]; // Getter function to retrieve a pets details
    }

    function getAllOwnersPets(address _owner) public view returns (Pet[] memory) {
        return OwnerToAllPets[_owner]; // Getter function to retrieve all of an owners pets
    }

}