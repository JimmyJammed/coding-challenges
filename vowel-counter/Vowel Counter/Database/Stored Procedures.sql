#spGetAllEntries
DROP PROCEDURE IF EXISTS spGetAllEntries;
DELIMITER //
CREATE PROCEDURE spGetAllEntries()
BEGIN
  SELECT * FROM Vowels;
END //
DELIMITER ;

#spGetEntry
DROP PROCEDURE IF EXISTS spGetEntry;
DELIMITER //
CREATE PROCEDURE spGetEntry(IN idVowels VARCHAR(256))
BEGIN
  SELECT * FROM Vowels WHERE Vowels.idVowels = idVowels;
END //
DELIMITER ;

#spInsertEntry
DROP PROCEDURE IF EXISTS spInsertEntry;
DELIMITER //
CREATE PROCEDURE spInsertEntry(IN idUsers VARCHAR(256),IN text VARCHAR(256),IN totalVowels INT,IN lineData VARCHAR(5000))
BEGIN
  INSERT INTO Vowels (Vowels.idVowels,Vowels.idUsers, Vowels.text, Vowels.totalVowels, Vowels.lineData, Vowels.dateUpdated)
	VALUES ((SELECT UUID()),idUsers, text, totalVowels, lineData, NOW())
	ON DUPLICATE KEY UPDATE Vowels.text = text, Vowels.totalVowels = totalVowels, Vowels.lineData = lineData, Vowels.dateUpdated = NOW();
END //
DELIMITER ;
