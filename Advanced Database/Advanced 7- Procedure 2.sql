-- procedure with no return value (display result within the procedure)
-- No OUT parameter → result stays inside the procedure(void procedure)
-- Used when you just want to display the result.

CREATE OR REPLACE PROCEDURE pow (
    num1 IN NUMBER,
    num2 IN NUMBER
)
IS
   pow_result NUMBER;
BEGIN
    pow_result:= POWER(num1, num2);
    DBMS_OUTPUT.PUT_LINE('Result: ' || pow_result);
END pow;

EXEC pow(7,2);

-- OUT parameter example (procedure that returns values via OUT parameters)
CREATE OR REPLACE PROCEDURE pow1 (
    num1 IN NUMBER,
    num2 IN NUMBER,
    pow_result OUT NUMBER
)
IS
BEGIN
    pow_result:= num1**num2;
    DBMS_OUTPUT.PUT_LINE(pow_result);
END pow1; 

EXEC pow1(3,3,:pow_result1); 
-- bind variable name does not necessarily have to match with (OUT) variable
-- this variable stores the value returned by the procedure


-- OUT parameter type: passing parameter
-- Useful when the result must be used later 
-- (stored in a variable, inserted in a table, passed to another function).
CREATE OR REPLACE PROCEDURE pow2 (
    num1 IN NUMBER,
    num2 IN NUMBER,
    pow_result OUT NUMBER
)
IS
BEGIN
    pow_result:= num1**num2; 
END pow2;

-- anonymous PL/SQL block (Exists only while it executes and is not stored in the database)
DECLARE 
   result NUMBER;
BEGIN
    pow2(8,3,result);
    DBMS_OUTPUT.PUT_LINE(result);
END;


CREATE OR REPLACE FUNCTION calc_power(num1 IN NUMBER, num2 IN NUMBER)
RETURN NUMBER
IS 
BEGIN 
    RETURN num1**num2;
END;

-- functions in sql must be called from a command or assigned to a variable

-- called from a sql command (hence dual)
SELECT calc_power(9,2) FROM dual;

-- assigned to a variable
DECLARE 
x NUMBER;
BEGIN
    x := calc_power(8,2) ;
    DBMS_OUTPUT.PUT_LINE(x);
END;

SELECT * FROM dual;