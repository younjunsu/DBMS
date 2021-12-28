ALTER SESSION SET CURRENT_SCHEMA=TIBERO;

/*******************************************************************************/
/* TABLE NAME : 부서정보                                                       */
/*******************************************************************************/
DROP TABLE DEPARTMENT;

CREATE TABLE DEPARTMENT (
     DEPT_CD        VARCHAR(4)      NOT NULL,   /* 부서코드     */
     DEPT_NAME      VARCHAR(20)     ,           /* 부서명       */
     PDEPT_CD       VARCHAR(4)      ,           /* 상위부서코드 */
     CONSTRAINT DEPARTMENT_PK
        PRIMARY KEY (DEPT_CD)
        USING INDEX
        PCTFREE      20
        TABLESPACE   USR
)
     PCTFREE    10
     TABLESPACE USR;

/* COMMENT */
COMMENT ON TABLE  DEPARTMENT              IS '부서정보';
COMMENT ON COLUMN DEPARTMENT.DEPT_CD      IS '부서코드';
COMMENT ON COLUMN DEPARTMENT.DEPT_NAME    IS '부서명';
COMMENT ON COLUMN DEPARTMENT.PDEPT_CD     IS '상위부서코드';



/*******************************************************************************/
/* TABLE NAME : 사원정보                                                       */
/*******************************************************************************/
DROP TABLE EMPLOYEE;

CREATE TABLE EMPLOYEE (
     EMP_NO         VARCHAR(8)      NOT NULL,   /* 사원아이디 */
     EMP_NAME       VARCHAR(20)     ,           /* 이름       */
     HIREDATE       DATE            ,           /* 입사일     */
     SALARY         NUMBER(8,3)     ,           /* 연봉       */
     BONUS          NUMBER(8,3)     ,           /* 성과급     */
     DEPT_CD        VARCHAR(4)      ,           /* 부서코드   */
     MANAGER      VARCHAR(8)     ,            /* 관리자 */
     CONSTRAINT EMPLOYEE_PK
        PRIMARY KEY (EMP_NO)
        USING INDEX
        PCTFREE      20
        TABLESPACE   USR
)
     PCTFREE    10
     TABLESPACE USR;

/* COMMENT */
COMMENT ON TABLE  EMPLOYEE              IS '사원정보';
COMMENT ON COLUMN EMPLOYEE.EMP_NO       IS '사원번호';
COMMENT ON COLUMN EMPLOYEE.EMP_NAME     IS '이름';
COMMENT ON COLUMN EMPLOYEE.HIREDATE     IS '입사일';
COMMENT ON COLUMN EMPLOYEE.SALARY       IS '연봉';
COMMENT ON COLUMN EMPLOYEE.BONUS        IS '성과급';
COMMENT ON COLUMN EMPLOYEE.DEPT_CD      IS '부서코드';
COMMENT ON COLUMN EMPLOYEE.MANAGER     IS '관리자';

/*******************************************************************************/
/* TABLE NAME : 급여 등급                                                       */
/*******************************************************************************/
DROP TABLE SALARY_GRADE;

CREATE TABLE SALARY_GRADE (
     SAL_GRADE        VARCHAR(2)      NOT NULL,   /* 급여 등급     */
     LOW_SALARY      NUMBER(8,3) ,                 /* 급여 하한값  */
     HIGH_SALARY      NUMBER(8,3),          /* 급여 상한값 */
     CONSTRAINT SALARY_GRADE_PK
        PRIMARY KEY (SAL_GRADE)
        USING INDEX
        PCTFREE      20
        TABLESPACE   USR
)
     PCTFREE    10
     TABLESPACE USR;

/* COMMENT */
COMMENT ON TABLE  SALARY_GRADE              IS '급여등급';
COMMENT ON COLUMN SALARY_GRADE .SAL_GRADE     IS '급여등급';
COMMENT ON COLUMN SALARY_GRADE .LOW_SALARY    IS '급여 하한값';
COMMENT ON COLUMN SALARY_GRADE .HIGH_SALARY  IS '급여 상한값';

/*******************************************************************************/
/* TABLE NAME : 고객정보                                                       */
/*******************************************************************************/
DROP TABLE CUSTOMER;

CREATE TABLE CUSTOMER (
     CUST_ID        VARCHAR(4)      NOT NULL,         /* 고객아이디   */
     CUST_NAME      VARCHAR(20)     ,                 /* 고객명       */
     CUST_ADDR      VARCHAR(40)     ,                 /* 고객주소     */
     CUST_TEL       VARCHAR(20)     ,                 /* 고객전화번호 */
     REG_DATE       DATE            DEFAULT SYSDATE,  /* 등록일       */
     CONSTRAINT CUSTOMER_PK
        PRIMARY KEY (CUST_ID)
        USING INDEX
        PCTFREE      20
        TABLESPACE   USR
)
     PCTFREE    10
     TABLESPACE USR;

/* COMMENT */
COMMENT ON TABLE  CUSTOMER              IS '고객정보';
COMMENT ON COLUMN CUSTOMER.CUST_ID      IS '고객아이디';
COMMENT ON COLUMN CUSTOMER.CUST_NAME    IS '고객명';
COMMENT ON COLUMN CUSTOMER.CUST_ADDR    IS '고객주소';
COMMENT ON COLUMN CUSTOMER.CUST_TEL     IS '고객전화번호';
COMMENT ON COLUMN CUSTOMER.REG_DATE     IS '등록일';



/*******************************************************************************/
/* TABLE NAME : 제품정보                                                       */
/*******************************************************************************/
DROP TABLE PRODUCT CASCADE CONSTRAINTS;

CREATE TABLE PRODUCT (
     PROD_ID        VARCHAR(4)      NOT NULL,    /* 제품아이디 */
     PROD_NAME      VARCHAR(20)     ,            /* 제품명     */
     PROD_GROUP     VARCHAR(10)     ,            /* 제품군     */
     PROD_COST      NUMBER(8,3)     ,            /* 제품가격   */
     CONSTRAINT PRODUCT_PK
        PRIMARY KEY (PROD_ID)
        USING INDEX
        PCTFREE      20
        TABLESPACE   USR
)
     PCTFREE    10
     TABLESPACE USR;

/* COMMENT */
COMMENT ON TABLE  PRODUCT              IS '제품정보';
COMMENT ON COLUMN PRODUCT.PROD_ID      IS '제품아이디';
COMMENT ON COLUMN PRODUCT.PROD_NAME    IS '제품명';
COMMENT ON COLUMN PRODUCT.PROD_GROUP   IS '제품군';
COMMENT ON COLUMN PRODUCT.PROD_COST    IS '제품가격';



/*******************************************************************************/
/* TABLE NAME : 제품상세정보                                                   */
/*******************************************************************************/
DROP TABLE PRODUCT_DTL;

CREATE TABLE PRODUCT_DTL (
     PROD_ID        VARCHAR(4)      NOT NULL,   /* 제품아이디 */
     DESCRIPTION    CLOB            ,           /* 제품소개   */
     ILLUSTRATION   BLOB            ,           /* 제품구성도 */
     CONSTRAINT PRODUCT_DTL_PK
        PRIMARY KEY (PROD_ID)
        USING INDEX
        PCTFREE      20
        TABLESPACE   USR
)
     PCTFREE    10
     TABLESPACE USR;

/* COMMENT */
COMMENT ON TABLE  PRODUCT_DTL              IS '제품상세정보';
COMMENT ON COLUMN PRODUCT_DTL.PROD_ID      IS '제품아이디';
COMMENT ON COLUMN PRODUCT_DTL.DESCRIPTION  IS '제품소개';
COMMENT ON COLUMN PRODUCT_DTL.ILLUSTRATION IS '제품구성도';

ALTER TABLE PRODUCT_DTL
    ADD CONSTRAINT PRODUCT_DTL_FK 
    FOREIGN KEY(PROD_ID)
    REFERENCES PRODUCT(PROD_ID);




/*******************************************************************************/
/* TABLE NAME : 주문정보                                                       */
/*******************************************************************************/
DROP TABLE ORDERS;

CREATE TABLE ORDERS (
     ORD_NO         NUMBER(8)       NOT NULL,    /* 주문번호       */
     PROD_ID        VARCHAR(4)      ,            /* 제품아이디     */
     ORD_AMOUNT     NUMBER(4)       ,            /* 수량           */
     ORD_DATE       DATE            ,            /* 계약일자       */
     CUST_ID        VARCHAR(8)      ,            /* 구매고객아이디 */
     EMP_NO         VARCHAR(8)      ,            /* 판매사원아이디 */
     CONSTRAINT ORDERS_PK
        PRIMARY KEY (ORD_NO)
        USING INDEX
        PCTFREE      20
        TABLESPACE   USR
)
     PCTFREE    10
     TABLESPACE USR;

/* COMMENT */
COMMENT ON TABLE  ORDERS               IS '주문정보';
COMMENT ON COLUMN ORDERS.ORD_NO        IS '주문번호';
COMMENT ON COLUMN ORDERS.PROD_ID       IS '제품아이디';
COMMENT ON COLUMN ORDERS.ORD_AMOUNT    IS '수량';
COMMENT ON COLUMN ORDERS.ORD_DATE      IS '계약일자';
COMMENT ON COLUMN ORDERS.CUST_ID       IS '구매고객아이디';
COMMENT ON COLUMN ORDERS.EMP_NO        IS '판매사원아이디';

CREATE INDEX TIBERO.ORDERS_IDX1 ON TIBERO.ORDERS (
	EMP_NO ASC
)
NOLOGGING
TABLESPACE USR
PCTFREE 10
INITRANS 2;
