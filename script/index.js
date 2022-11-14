const util = require("util");
const exec = util.promisify(require("child_process").exec);
const csv = require("csvtojson");
const fs = require("fs");
const axios = require("axios");

const START_BLOCK = 15924347; // 15914348 (10,000) & 15923348 (1000)
const END_BLOCK = 15924348;
const BATCH_SIZE = 1;

async function main() {
  if (END_BLOCK - START_BLOCK <= 0) {
    throw Error("Please give correct start and end blocks");
  }

  const totalBlocks = END_BLOCK - START_BLOCK;
  console.log("totalBlocks: ", totalBlocks);

  const cycles = totalBlocks / BATCH_SIZE;
  console.log("cycles: ", cycles);

  let startBlock = START_BLOCK;
  let endBlock;

  for (let i = 0; i < cycles; i++) {
    endBlock = startBlock + BATCH_SIZE;

    // console.log(startBlock, endBlock);

    /// 1. run shell script for blocks
    console.log(`running "shell/process.sh ${startBlock} ${endBlock}"`);
    const { stdout, stderr } = await exec(
      `shell/process.sh ${startBlock} ${endBlock}`
    );
    console.log("stdout:", stdout);
    console.error("stderr:", stderr);

    /// 2. read csv files from data folder

    // 2a. list all files
    const files = fs.readdirSync("./data");
    // console.log("files: ", files);

    // 2b. filter only csv files
    const filteredFiles = files.filter((f) => f.includes("csv"));
    console.log("filteredFiles: ", filteredFiles);

    /// 3. convert to json file
    let jsonFiles = {};
    for (const filename of filteredFiles) {
      console.log("filename: ", filename);
      const jsonArray = await csv().fromFile(`data/${filename}`);
      // console.log("jsonArray: ", jsonArray);
      jsonFiles[filename] = jsonArray;
    }

    Object.keys(jsonFiles).forEach((f) => console.log(f));

    console.log("-----------------------------------------------------");
    // console.log("jsonFiles: ", jsonFiles);
    fs.writeFileSync("data/output.json", JSON.stringify(jsonFiles, null, 2));

    /// 4. send json files to server
    const res = await axios.post(
      "http://172.18.1.5:5000/process/blocks",
      JSON.stringify(jsonFiles)
    );
    console.log("res: ", res.data);

    startBlock = endBlock;
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
