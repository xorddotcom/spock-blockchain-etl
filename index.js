#! /usr/bin/env node

const csv = require("csvtojson");
const fs = require("fs");
const { Command } = require("commander");

const program = new Command();

program.name("json-to-csv").description("json to csv").version("1.0.0");

program
  .command("path")
  .description("path to csv")
  .argument("<string>", "pathToCSV")
  .action(async (input) => {
    await main(input);
  });

program.parse();

async function main(csvFilePath) {
  // const csvFilePath = "./test.csv";
  const jsonArray = await csv().fromFile(csvFilePath);
  console.log(jsonArray);

  // Convert the resultant array to json and
  // generate the JSON output file.
  let json = JSON.stringify(jsonArray, null, 2);
  const outputName = csvFilePath.replace(".csv", ".json");
  fs.writeFileSync(outputName, json);
}

// main().catch((e) => console.log(e));
