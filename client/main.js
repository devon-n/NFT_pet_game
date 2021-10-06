Moralis.initialize("MORALIS APP ID GOES HERE"); // Application id from moralis.io
Moralis.serverURL = "MORALIS SERVER GOES HERE"; //Server url from moralis.io
const CONTRACT_ADDRESS = '0x31c58D772b6CB007649DB2D6a9cc0EA7070C6f1e'


async function init() {
    try {
        let user = Moralis.User.current(); // Grab current metamask account
        if(!user){ // If there is not a current metamask account
            $("#login_button").click( async () => { // When login button is clicked
                user = await Moralis.Web3.authenticate(); // Wait for account to connect
            })
        }
        renderGame(); // Render the game
    } catch (error) {
        console.log(error);
    }
}

async function renderGame() {
    
    $("#login_button").hide(); // Hide the login button
    $("#pet_row").html("");
    // Render Pet Attributes
    window.web3 = await Moralis.Web3.enable();
    let abi = await getAbi();
    let contract = new web3.eth.Contract(abi, CONTRACT_ADDRESS);
    let allPetsArray = await contract.methods.getAllOwnersPets(ethereum.selectedAddress).call({from: ethereum.selectedAddress});
    for (petId = 0; petId < allPetsArray.length; petId++) {
        let details = await contract.methods.getTokenDetails(petId).call({from: ethereum.selectedAddress});
        renderPet(petId, details);
    }
    // if(allpetsArray.length == 0) return;
    // allpetsArray.forEach(async petId => {
        // let data = await contract.methods.getTokenDetails(petId).call({from: ethereum.selectedAddress});
        // renderPet(petId, data);
    // });
    
    $("#game").show(); // Show the game
}

function renderPet(id, data){

    let deathTime = new Date( (parseInt(data.lastMeal) + parseInt(data.endurance)) * 1000);
    let now = new Date();
    if(now > deathTime) {
        deathTime = "<b>DEAD</b>"
    }
    let htmlString = `
        <div class="col-md-4 card" id="pet_${id}>
        <img class="card-img-top pet_img" src="./pet.png">
            <div class="card-body">
                <div>Name: <span class="pet_name">${data.name}</div>
                <div>Level: <span class="pet_level">${data.level}</div>
                <div>Health: <span class="pet_health">${data.health}</div>
                <div>Last Meal: <span class="pet_last_meal">${data.lastMeal}</div>
                <div>Damage: <span class="pet_damage">${data.damage}</div>
                <div>ID: <span class="pet_id">${id}</div>
                <br>
                <button data-pet-id="${id}" class="feed_button btn btn-primary btn-block">Feed Pet</button>
            </div>
        </div>`
    let element = $.parseHTML(htmlString);
    $("#pet_row").append(element);

    $(`#pet_${id} .feed_button`).click( () => {
        feed(id);
        renderGame();
    });
}


function getAbi() {
    return new Promise( (res) => {
        $.getJSON("../build/contracts/Token.json", ( (json) => {
            res(json.abi);
        }));
    })
}

async function feed(petId) {
    let abi = await getAbi();
    let contract = new web3.eth.Contract(abi, CONTRACT_ADDRESS);
    contract.methods.feed(petId).send({from: ethereum.selectedAddress}).on("receipt", ( () => {
        renderGame();
    }))
    
}




init();