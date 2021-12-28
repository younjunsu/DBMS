ALTER SESSION SET CURRENT_SCHEMA=TIBERO;

/*******************************************************************************/
/* VIEW                                                                        */
/*******************************************************************************/
CREATE OR REPLACE VIEW V_EMPSAL 
AS
SELECT EMP_NAME, SALARY 
  FROM EMPLOYEE;


/*******************************************************************************/
/* SYNONYM                                                                     */
/*******************************************************************************/
CREATE OR REPLACE SYNONYM TB_DEPT     FOR DEPARTMENT;
CREATE OR REPLACE SYNONYM TB_EMP      FOR EMPLOYEE;
CREATE OR REPLACE SYNONYM TB_PROD     FOR PRODUCT;
CREATE OR REPLACE SYNONYM TB_PROD_DTL FOR PRODUCT_DTL;
CREATE OR REPLACE SYNONYM TB_CUST     FOR CUSTOMER;
CREATE OR REPLACE SYNONYM TB_ORD      FOR ORDERS;


/*******************************************************************************/
/* SYNONYM                                                                     */
/*******************************************************************************/
DROP SEQUENCE SEQ_ORDER
/

CREATE SEQUENCE SEQ_ORDER 
START WITH 36 
INCREMENT BY 1
MAXVALUE 99999999
MINVALUE 1
NOCYCLE
NOCACHE
/


/*******************************************************************************/
/* PROCEDURE                                                                   */
/*******************************************************************************/
CREATE OR REPLACE PROCEDURE P_1 (V_ENO IN NUMBER)
 IS
 V_ENAME VARCHAR(10);
 V_SAL NUMBER(7);
BEGIN
  SELECT EMP_NAME, SALARY INTO  V_ENAME,  V_SAL
   FROM EMPLOYEE
 WHERE EMP_NO=V_ENO;

DBMS_OUTPUT.PUT_LINE('=====================');
DBMS_OUTPUT.PUT_LINE('EMPLOYEE      SALARY');
DBMS_OUTPUT.PUT_LINE('=====================');
DBMS_OUTPUT.PUT_LINE(RPAD(V_ENAME,8,' ') || '        ' ||  V_SAL);
DBMS_OUTPUT.PUT_LINE('=====================');
END;
/

SET SERVEROUTPUT ON
EXEC P_1(20063428);


/*******************************************************************************/
/* FUNCTION                                                                    */
/*******************************************************************************/
CREATE OR REPLACE FUNCTION F_TAX
(V_ENO IN EMPLOYEE.EMP_NO%TYPE)
RETURN NUMBER
IS
 V_SAL NUMBER;
 V_TAX NUMBER;
BEGIN
 SELECT SALARY INTO V_SAL
  FROM EMPLOYEE
 WHERE EMP_NO = V_ENO;
IF V_SAL >=5000 THEN V_TAX := V_SAL*0.1 ;
 ELSIF V_SAL >=4000 THEN V_TAX := V_SAL*0.08 ;
 ELSIF V_SAL >=3000 THEN V_TAX := V_SAL*0.05 ;
 ELSIF V_SAL >=2000 THEN V_TAX := V_SAL*0.04 ;
 ELSIF V_SAL >=1000 THEN V_TAX := V_SAL*0.03 ;
 ELSE V_TAX := V_SAL*0.01 ;
END IF;
 RETURN V_TAX;
END;
/

SELECT F_TAX(2001043) FROM DUAL
/


/*******************************************************************************/
/* PACKAGE                                                                     */
/*******************************************************************************/
CREATE OR REPLACE PACKAGE PACK_1
IS
PROCEDURE PROC_1;
END; 
/

CREATE OR REPLACE PACKAGE BODY PACK_1
IS
 PROCEDURE PROC_1
IS
 BEGIN
 DBMS_OUTPUT.PUT_LINE('THIS IS PACKAGE PROCEURE CALL');
END;
END;
/

SET SERVEROUTPUT ON
EXEC PACK_1.PROC_1;


/*******************************************************************************/
/* TRIGGER                                                                     */
/*******************************************************************************/
CREATE OR REPLACE TRIGGER TRI_PROD_DTL_INS
AFTER INSERT
ON PRODUCT
FOR EACH ROW
BEGIN
    INSERT INTO PRODUCT_DTL (PROD_ID) VALUES (:NEW.PROD_ID);
END;
/


/*******************************************************************************/
/* P_NOARGUMENT PROCEDURE                                                      */
/*******************************************************************************/
CREATE OR REPLACE PROCEDURE P_NOARGUMENT
IS
BEGIN
    INSERT INTO DEPARTMENT(
           DEPT_CD
          ,DEPT_NAME
          ,PDEPT_CD
        ) VALUES (
           (SELECT NVL(MAX(DEPT_CD),0)+10 FROM DEPARTMENT)
          ,'DB'
          ,'0000'
        );

      COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERR CODE : ' || TO_CHAR(SQLCODE));
        DBMS_OUTPUT.PUT_LINE('ERR MESSAGE : ' || SQLERRM);

END P_NOARGUMENT;
/


/*******************************************************************************/
/* P_NORETURN PROCEDURE                                                        */
/*******************************************************************************/
CREATE OR REPLACE PROCEDURE P_NORETURN(dept_name in varchar)
IS
BEGIN
    INSERT INTO DEPARTMENT (
           DEPT_CD
          ,DEPT_NAME
          ,PDEPT_CD
        ) VALUES (
           (SELECT NVL(MAX(DEPT_CD), 0)+10 FROM DEPARTMENT)
          ,DEPT_NAME
          ,'0000'
        );

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERR CODE : ' || TO_CHAR(SQLCODE));
        DBMS_OUTPUT.PUT_LINE('ERR MESSAGE : ' || SQLERRM);

END P_NORETURN;
/


/*******************************************************************************/
/* P_SINGLEROW PROCEDURE                                                       */
/*******************************************************************************/
CREATE OR REPLACE PROCEDURE P_SINGLEROW
(
    v_dept_cd    IN VARCHAR,
    v_dept_name   OUT VARCHAR,
    v_pdept_cd    OUT VARCHAR
)
IS
BEGIN

    SELECT DEPT_NAME, PDEPT_CD
      INTO v_dept_name, v_pdept_cd
      FROM DEPARTMENT
     WHERE DEPT_CD = v_dept_cd;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERR CODE : ' || TO_CHAR(SQLCODE));
        DBMS_OUTPUT.PUT_LINE('ERR MESSAGE : ' || SQLERRM);

END P_SINGLEROW;
/


/*******************************************************************************/
/* Multi Row Return (Ref CURSOR)                                               */
/*******************************************************************************/
-- 패키지 헤더 생성
CREATE OR REPLACE PACKAGE PKG_MULTIROW AS
    TYPE ref_type IS REF CURSOR;
    PROCEDURE MULTI (h_pdept_cd IN VARCHAR, h_cursor OUT ref_type);
END;
/

-- 패키지 본문 생성
CREATE OR REPLACE PACKAGE BODY PKG_MULTIROW AS

    PROCEDURE MULTI
    (
        h_pdept_cd  IN  VARCHAR,
        h_cursor    OUT ref_type
    )
    IS
    BEGIN
       
        OPEN h_cursor  FOR
        SELECT DEPT_CD
              ,DEPT_NAME
          FROM DEPARTMENT
         WHERE PDEPT_CD = h_pdept_cd
         ORDER BY DEPT_CD, DEPT_NAME;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERR CODE : ' || TO_CHAR(SQLCODE));
            DBMS_OUTPUT.PUT_LINE('ERR MESSAGE : ' || SQLERRM);

    END MULTI;
END;
/
