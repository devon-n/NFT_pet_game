// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC721, Ownable {

    constructor (string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    struct Pet {
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


    mapping (address => uint256) public OwnerToPetId;
    mapping (address => Pet[]) public OwnerToAllPets;
    mapping (uint256 => Pet) public PetIdToPetDetails;
    


    function mint(string memory _name) public payable onlyOwner {
        // require(msg.value >= creationFee, "Insufficient funds to create pet");
        Pet memory newPet = Pet(_name, startingLevel, startingHealth, block.timestamp, startingDamage, petIdCounter);
        _safeMint(msg.sender, petIdCounter, "");
        PetIdToPetDetails[petIdCounter] = newPet;
        OwnerToAllPets[msg.sender].push(newPet);
        OwnerToPetId[msg.sender] = petIdCounter;
        petIdCounter++;
    }

    function feed (uint256 _petId) public {
        require(OwnerToPetId[msg.sender] == _petId, "You are not the owner of this pet.");
        require((PetIdToPetDetails[_petId].lastMeal + PetIdToPetDetails[_petId].health) > block.timestamp); // Check if the pet has not feed in too long
        Pet storage pet = PetIdToPetDetails[_petId];
        pet.lastMeal = block.timestamp;
    }

    function getTokenDetails(uint256 _tokenId) public view returns (Pet memory) {
        return PetIdToPetDetails[_tokenId];
    }

    function getAllOwnersPets(address _owner) public view returns (Pet[] memory) {
        return OwnerToAllPets[_owner];
    }



    // OVERRIDE THE TRANSFER (public) FUNCTION TO CALL THE CHANGE MAPPINGS FUNCTION (internal) WHICH UPDATES THE MAPPINGS
    // function _beforeTokenTransfer(address from, address to, uint256 _petId) internal override {
    //     require(OwnerToPetId[msg.sender] == _petId, "You are not the owner of this pet.");
    //     require(PetIdToPetDetails[_petId].lastMeal + PetIdToPetDetails[_petId].health > block.timestamp);
        
    //     // Move to new owner
    //     OwnerToAllPets[to].push(PetIdToPetDetails[_petId]);
    //     OwnerToPetId[to] = petIdCounter;

    //     // Delete from old owner
    //     delete OwnerToAllPets[from]._petId; // Not sure why its underlined
    //     delete OwnerToPetId[from]._petId;

    //     _transfer(from, to, _petId);
    // }
}