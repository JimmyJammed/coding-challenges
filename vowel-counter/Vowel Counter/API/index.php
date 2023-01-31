<?PHP
//File: index.php
//Created By: James Hickman
//Created Date: 8/7/2014
//Last Updated: 8/7/2014
//Copyright 2014 NitWit Studios
//Description: This file contains the API endpoints for the Vowels app.


	
	//Check connection
	if ($conn->connect_error) {
	  trigger_error('Database connection failed: '  . $conn->connect_error, E_USER_ERROR);
	}

	//Create JSON Decoded Object from HTTPBody
	$handle = fopen('php://input','r');
	$jsonInput = fgets($handle);
	// Decoding JSON into an Array
	$data = json_decode($jsonInput,true);

	/******WEB TESTS******/
	if(empty($data)){

		//getAllEntries
		$data["request"] = "getAllEntries";
		/*
		//getEntry
		$data["request"] = "getEntry";
		$data["idVowels"] = "05552f7e-1cff-11e4-a627-bc764e049579";
		//insertEntry
		$data["request"] = "postEntry";
		$data["idUsers"] = "james.hickman@nitwitstudios.com";
		$data["text"] = "Line one\nLine two";
		$data["totalVowels"] = 7;
		$json[0]["idLines"] = 1;
		$json[0]["vowels"] = 4;
		$json[1]["idLines"] = 2;
		$json[1]["vowels"] = 3;
		$data["lineData"] = json_encode($json);
		*/
	}
	/****END TESTS****/
	
	//Get request type and call appropriate method
	$request = $data["request"];
	switch($request){
		case 'getAllEntries':
			echo getAllEntries();
			break;
		case 'getEntry':
			echo getEntry($data);
			break;
		case 'postEntry':
			echo postEntry($data);
			break;
	}

	function getAllEntries(){
		global $DBServer;
		global $DBUser;
		global $DBPass;
		global $DBName;
		$conn = new mysqli($DBServer, $DBUser, $DBPass, $DBName);
		$query = "CALL spGetAllEntries()";
		$results = $conn->query($query);
		if($results->num_rows == 0) {//No error, but no entries
			$response["status"] = true;
			$response["response"] = NULL;
		}else if($results->num_rows > 0) {//Entries found
			//Total Counters
			$totalVowels = 0;
			$totalSubmissions = 0;
			$totalLines = 0;
			while($row = $results->fetch_assoc()){
				$entry = array();
				$entry["idVowels"] = $row["idVowels"];
				$entry["idUsers"] = $row["idUsers"];
				$entry["text"] = $row["text"];
				$entry["totalVowels"] = $row["totalVowels"];
				$entry["lineData"] = $row["lineData"];
				$data[] = $entry;
				//Totals
				$totalVowels += $row["totalVowels"];
				$totalSubmissions++;
				$lineData = json_decode($row["lineData"]);				
				$totalLines += count($lineData);
			}
			$response["status"] = true;
			$response["response"] = $data;
			$response["totalVowels"] = $totalVowels;
			$response["totalSubmissions"] = $totalSubmissions;
			$response["totalLines"] = $totalLines;
		}else{//Database Error
			$response["status"] = false;
			$response["response"] = NULL;	
		}
		$conn->close();
		return json_encode($response);
	}

	function getEntry($data){
		global $DBServer;
		global $DBUser;
		global $DBPass;
		global $DBName;
		$conn = new mysqli($DBServer, $DBUser, $DBPass, $DBName);
		$query = "CALL spGetEntry('$data[idVowels]')";
		$results = $conn->query($query);
		if($results->num_rows > 0) {
			$totalVowels = 0;
			$totalSubmissions = 0;
			$totalLines = 0;
			$row = $results->fetch_assoc();
			$data = array();
			$data["idVowels"] = $row["idVowels"];
			$data["idUsers"] = $row["idUsers"];
			$data["text"] = $row["text"];
			$data["totalVowels"] = $row["totalVowels"];
			$data["totalLines"] = count(json_decode($row["lineData"]));
			$data["lineData"] = json_decode($row["lineData"]);
			
			$response["status"] = true;
			$response["response"] = $data;
		}else{
			$response["status"] = false;
			$response["response"] = NULL;	
		}
		$conn->close();
		return json_encode($response);
	}

	function postEntry($data){
		global $DBServer;
		global $DBUser;
		global $DBPass;
		global $DBName;
		$conn = new mysqli($DBServer, $DBUser, $DBPass, $DBName);
		//Encode Array for Database
		$json = json_encode($data[lineData]);
		$query = "CALL spInsertEntry('$data[idUsers]','$data[text]',$data[totalVowels],'$json')";
		if($conn->query($query)){
			$response["status"] = true;
		}else{
			$response["status"] = false;
		}
		$conn->close();
		return json_encode($response);
	}
