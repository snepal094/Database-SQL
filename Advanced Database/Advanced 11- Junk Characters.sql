CREATE TABLE junk_test(
    id NUMBER PRIMARY KEY,
    description NVARCHAR2(50)
);

INSERT INTO junk_test VALUES
(1, 'Harry Potter'),
(2, 'Ronald%Bilius#Weasley'),
(3, 'Hermione Granger'),
(4, 'Minerva McGonagall'),
(5, 'Severus Snape'),
(6, 'Albus#Percival^Wulfric)Brian(Dumbledore');

SELECT * FROM junk_test;

SELECT description, REGEXP_LIKE(description, '[^A-Za-z0-9 ]') AS isJunk, REGEXP_REPLACE(description, '[^A-Za-z0-9 ]', ' ') AS cleaned_text
FROM junk_test;

-- catch junk characters using function
CREATE OR REPLACE FUNCTION catch_junk_chars(f_desc IN VARCHAR2)
RETURN BOOLEAN
AS
BEGIN
    RETURN REGEXP_LIKE(f_desc, '[^A-Za-z0-9 ]');
END;

SELECT id, description, catch_junk_chars(description) AS has_junk
FROM JUNK_TEST;