const Token = artifacts.require("Token");

module.exports = async function (deployer) {
  await deployer.deploy(Token, "Pet", "PET");
  let tokenInstance = await Token.deployed();
  await tokenInstance.mint("Test1");
  await tokenInstance.mint("Test2");
  await tokenInstance.mint("Test3");
  let petDetails = await tokenInstance.getTokenDetails(0);
  // console.log("First Pet Details: ",petDetails);
};