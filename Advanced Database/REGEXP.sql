SELECT * FROM HR.EMPLOYEES;

-- REGEXP = regular expression functions
-- 4 main REGEXP functions in oracle: LIKE, SUBSTR, INSTR, REPLACE

-- REGEXP_LIKE() : detect pattern

-- employee names beginning with J and ending with n
SELECT employee_id, first_name 
FROM HR.Employees 
WHERE REGEXP_LIKE(first_name, '^J.*n$'); 
-- ^J → string must begin with J
-- .* → any characters in between
-- n$ → string must end with n

-- employees whose name contains a digit 
SELECT name 
FROM (
    SELECT 'Donald2' AS name FROM dual
    UNION ALL
    SELECT 'John44' FROM dual
    UNION ALL 
    SELECT 'Jonathan' FROM dual
)
WHERE REGEXP_LIKE(name, '[0-9]'); -- [0-9] → any digits between 0 to 9


-- REGEXP_SUBSTR() : extract text based on a pattern

-- extract the first character of first_name
SELECT first_name, 
       REGEXP_SUBSTR(first_name, '^[A-Za-z]') AS first_char 
       -- first character of first_name, but only if it is a letter (value = null if not a letter)
       -- '^.' would return the first character, whether its an alphabet or digit or others
       -- '.$' would return the last character
FROM hr.employees;

-- extract first name from full name
SELECT full_name,
       REGEXP_SUBSTR(full_name, '^\S+') AS extracted_first_name,
       -- ^ → start of the string
       -- \S → any non-space character (opposite of \s, which matches whitespace)
       -- + → Means 1 or more repetitions of the previous thing (i.e. \S)
       -- So it will keep matching all consecutive non-space characters until it hits a space.
       -- ^\S+ → continuous non-space characters from start (first word)
       REGEXP_SUBSTR(full_name, '\S+$')  AS extracted_last_name
FROM (
    SELECT first_name || ' ' || last_name AS full_name 
    FROM HR.EMPLOYEES
);

-- extract domain from email
SELECT email,
       REGEXP_SUBSTR(email, '@\S+$') AS domain
FROM (
    SELECT 'nepalsuyasha@gmail.com' AS email FROM dual
    UNION ALL
    SELECT 'oracle@yahoo.com' FROM dual
    UNION ALL 
    SELECT 'donald@hotmail.com' FROM dual
);

-- REGEXP_REPLACE() : replace text based on a pattern

-- mask email
SELECT email,
       REGEXP_REPLACE(email, '^[^@]+', '*****') AS masked_email
       -- '^[^@]+' → everything from the start until @
FROM (
    SELECT 'nepalsuyasha@gmail.com' AS email FROM dual
    UNION ALL
    SELECT 'oracle@yahoo.com' FROM dual
    UNION ALL 
    SELECT 'donald@hotmail.com' FROM dual
);

-- REGEXP_INSTR() : get the position of a pattern

-- find the position of the first digit appearing on the string
SELECT REGEXP_INSTR('abc123xyz', '[0-9]') FROM dual; 

-- position of @ in email
SELECT email,
       REGEXP_INSTR(email, '@') AS at_position
FROM (
    SELECT 'nepalsuyasha@gmail.com' AS email FROM dual
    UNION ALL
    SELECT 'oracle@yahoo.com' FROM dual
    UNION ALL 
    SELECT 'donald@hotmail.com' FROM dual
);