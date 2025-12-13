// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MyFamilyNft} from "../../src/MyFamilyNft.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract MintMyFamilyNft is Script {
    function mintMyFamilyNft() public {
        address myFamilyNft = DevOpsTools.get_most_recent_deployment(
            "MyFamilyNft",
            block.chainid
        );
        vm.startBroadcast();
        MyFamilyNft(myFamilyNft).mintNft(
            "ipfs://QmV5xhS9XtpJYhV78WCnNAn9RoVwcv1isB9cj9Vb2n581u"
        );
        vm.stopBroadcast();
    }

    function run() external {
        mintMyFamilyNft();
    }
}

contract MeatDataUploadDeploy is Script {
    function uploadImageToPinata(
        string memory imagePath
    ) public returns (bytes memory) {
        string[] memory inputs = new string[](8);
        inputs[0] = "curl";
        inputs[1] = "-X";
        inputs[2] = "POST";
        inputs[3] = "https://api.pinata.cloud/pinning/pinFileToIPFS";
        inputs[4] = "-H";
        inputs[5] = string.concat(
            "Authorization: Bearer ",
            vm.envString("PINATA_JWT")
        );
        inputs[6] = "-F";
        inputs[7] = string.concat("file=@", imagePath);

        bytes memory result = vm.ffi(inputs);
        string memory jsonResponse = string(result);
        bytes memory cId = vm.parseJson(jsonResponse, ".IpfsHash");
        return cId;
    }

    // 核心函数：bytes 转 string，去除所有空格和点号
    function cleanBytesToString(
        bytes memory data
    ) internal pure returns (string memory) {
        // 1. 计算有效字符数量（非空格、非点号）
        uint256 validCount = 0;
        for (uint256 i = 0; i < data.length; i++) {
            if (data[i] != 0x20 && data[i] != 0x2E && data[i] != 0) {
                // 0x20=空格, 0x2E=点号, 0=空字节
                validCount++;
            }
        }

        // 2. 创建只包含有效字符的字符串
        bytes memory result = new bytes(validCount);
        uint256 index = 0;

        for (uint256 i = 0; i < data.length; i++) {
            bytes1 char = data[i];
            if (char != 0x20 && char != 0x2E && char != 0) {
                result[index] = char;
                index++;
            }
        }

        return string(result);
    }

    function uploadMetaDataJsonToPinata(
        string memory name,
        string memory desc,
        string memory cId
    ) public {
        string memory json = string.concat(
            '{"name": "',
            name,
            '", "description": "',
            desc,
            '", "image": "ipfs://',
            cId,
            '","attributes":[{"trait_type":"cuteness","value":100}]}'
        );
        console.log("json:", json);
        string memory tempFile = string.concat(
            vm.projectRoot(),
            "/",
            name,
            ".json"
        );
        console.log("path:", tempFile);
        vm.writeFile(tempFile, json);

        string[] memory inputs = new string[](8);
        inputs[0] = "curl";
        inputs[1] = "-X";
        inputs[2] = "POST";
        inputs[3] = "https://api.pinata.cloud/pinning/pinFileToIPFS";
        inputs[4] = "-H";
        inputs[5] = string.concat(
            "Authorization: Bearer ",
            vm.envString("PINATA_JWT")
        );
        inputs[6] = "-F";
        inputs[7] = string.concat("file=@", tempFile);

        bytes memory result = vm.ffi(inputs);
        string memory jsonResponse = string(result);
        console.log("JSON Response: ", jsonResponse);
    }

    function run() external {
        bytes memory cId = uploadImageToPinata(
            "/home/hinkpad/web3-demo/solidity-foundry/images/mylittledaughter.jpg"
        );
        uploadMetaDataJsonToPinata(
            "mylittledaughter",
            unicode"This is 徐甜酒！",
            cleanBytesToString(cId)
        );
    }
}
