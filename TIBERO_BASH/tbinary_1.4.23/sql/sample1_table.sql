ALTER SESSION SET CURRENT_SCHEMA=TIBERO;

/*******************************************************************************/
/* TABLE NAME : �μ�����                                                       */
/*******************************************************************************/
DROP TABLE DEPARTMENT;

CREATE TABLE DEPARTMENT (
     DEPT_CD        VARCHAR(4)      NOT NULL,   /* �μ��ڵ�     */
     DEPT_NAME      VARCHAR(20)     ,           /* �μ���       */
     PDEPT_CD       VARCHAR(4)      ,           /* �����μ��ڵ� */
     CONSTRAINT DEPARTMENT_PK
        PRIMARY KEY (DEPT_CD)
        USING INDEX
        PCTFREE      20
        TABLESPACE   USR
)
     PCTFREE    10
     TABLESPACE USR;

/* COMMENT */
COMMENT ON TABLE  DEPARTMENT              IS '�μ�����';
COMMENT ON COLUMN DEPARTMENT.DEPT_CD      IS '�μ��ڵ�';
COMMENT ON COLUMN DEPARTMENT.DEPT_NAME    IS '�μ���';
COMMENT ON COLUMN DEPARTMENT.PDEPT_CD     IS '�����μ��ڵ�';



/*******************************************************************************/
/* TABLE NAME : �������                                                       */
/*******************************************************************************/
DROP TABLE EMPLOYEE;

CREATE TABLE EMPLOYEE (
     EMP_NO         VARCHAR(8)      NOT NULL,   /* ������̵� */
     EMP_NAME       VARCHAR(20)     ,           /* �̸�       */
     HIREDATE       DATE            ,           /* �Ի���     */
     SALARY         NUMBER(8,3)     ,           /* ����       */
     BONUS          NUMBER(8,3)     ,           /* ������     */
     DEPT_CD        VARCHAR(4)      ,           /* �μ��ڵ�   */
     MANAGER      VARCHAR(8)     ,            /* ������ */
     CONSTRAINT EMPLOYEE_PK
        PRIMARY KEY (EMP_NO)
        USING INDEX
        PCTFREE      20
        TABLESPACE   USR
)
     PCTFREE    10
     TABLESPACE USR;

/* COMMENT */
COMMENT ON TABLE  EMPLOYEE              IS '�������';
COMMENT ON COLUMN EMPLOYEE.EMP_NO       IS '�����ȣ';
COMMENT ON COLUMN EMPLOYEE.EMP_NAME     IS '�̸�';
COMMENT ON COLUMN EMPLOYEE.HIREDATE     IS '�Ի���';
COMMENT ON COLUMN EMPLOYEE.SALARY       IS '����';
COMMENT ON COLUMN EMPLOYEE.BONUS        IS '������';
COMMENT ON COLUMN EMPLOYEE.DEPT_CD      IS '�μ��ڵ�';
COMMENT ON COLUMN EMPLOYEE.MANAGER     IS '������';

/*******************************************************************************/
/* TABLE NAME : �޿� ���                                                       */
/*******************************************************************************/
DROP TABLE SALARY_GRADE;

CREATE TABLE SALARY_GRADE (
     SAL_GRADE        VARCHAR(2)      NOT NULL,   /* �޿� ���     */
     LOW_SALARY      NUMBER(8,3) ,                 /* �޿� ���Ѱ�  */
     HIGH_SALARY      NUMBER(8,3),          /* �޿� ���Ѱ� */
     CONSTRAINT SALARY_GRADE_PK
        PRIMARY KEY (SAL_GRADE)
        USING INDEX
        PCTFREE      20
        TABLESPACE   USR
)
     PCTFREE    10
     TABLESPACE USR;

/* COMMENT */
COMMENT ON TABLE  SALARY_GRADE              IS '�޿����';
COMMENT ON COLUMN SALARY_GRADE .SAL_GRADE     IS '�޿����';
COMMENT ON COLUMN SALARY_GRADE .LOW_SALARY    IS '�޿� ���Ѱ�';
COMMENT ON COLUMN SALARY_GRADE .HIGH_SALARY  IS '�޿� ���Ѱ�';

/*******************************************************************************/
/* TABLE NAME : ������                                                       */
/*******************************************************************************/
DROP TABLE CUSTOMER;

CREATE TABLE CUSTOMER (
     CUST_ID        VARCHAR(4)      NOT NULL,         /* �����̵�   */
     CUST_NAME      VARCHAR(20)     ,                 /* ����       */
     CUST_ADDR      VARCHAR(40)     ,                 /* ���ּ�     */
     CUST_TEL       VARCHAR(20)     ,                 /* ����ȭ��ȣ */
     REG_DATE       DATE            DEFAULT SYSDATE,  /* �����       */
     CONSTRAINT CUSTOMER_PK
        PRIMARY KEY (CUST_ID)
        USING INDEX
        PCTFREE      20
        TABLESPACE   USR
)
     PCTFREE    10
     TABLESPACE USR;

/* COMMENT */
COMMENT ON TABLE  CUSTOMER              IS '������';
COMMENT ON COLUMN CUSTOMER.CUST_ID      IS '�����̵�';
COMMENT ON COLUMN CUSTOMER.CUST_NAME    IS '����';
COMMENT ON COLUMN CUSTOMER.CUST_ADDR    IS '���ּ�';
COMMENT ON COLUMN CUSTOMER.CUST_TEL     IS '����ȭ��ȣ';
COMMENT ON COLUMN CUSTOMER.REG_DATE     IS '�����';



/*******************************************************************************/
/* TABLE NAME : ��ǰ����                                                       */
/*******************************************************************************/
DROP TABLE PRODUCT CASCADE CONSTRAINTS;

CREATE TABLE PRODUCT (
     PROD_ID        VARCHAR(4)      NOT NULL,    /* ��ǰ���̵� */
     PROD_NAME      VARCHAR(20)     ,            /* ��ǰ��     */
     PROD_GROUP     VARCHAR(10)     ,            /* ��ǰ��     */
     PROD_COST      NUMBER(8,3)     ,            /* ��ǰ����   */
     CONSTRAINT PRODUCT_PK
        PRIMARY KEY (PROD_ID)
        USING INDEX
        PCTFREE      20
        TABLESPACE   USR
)
     PCTFREE    10
     TABLESPACE USR;

/* COMMENT */
COMMENT ON TABLE  PRODUCT              IS '��ǰ����';
COMMENT ON COLUMN PRODUCT.PROD_ID      IS '��ǰ���̵�';
COMMENT ON COLUMN PRODUCT.PROD_NAME    IS '��ǰ��';
COMMENT ON COLUMN PRODUCT.PROD_GROUP   IS '��ǰ��';
COMMENT ON COLUMN PRODUCT.PROD_COST    IS '��ǰ����';



/*******************************************************************************/
/* TABLE NAME : ��ǰ������                                                   */
/*******************************************************************************/
DROP TABLE PRODUCT_DTL;

CREATE TABLE PRODUCT_DTL (
     PROD_ID        VARCHAR(4)      NOT NULL,   /* ��ǰ���̵� */
     DESCRIPTION    CLOB            ,           /* ��ǰ�Ұ�   */
     ILLUSTRATION   BLOB            ,           /* ��ǰ������ */
     CONSTRAINT PRODUCT_DTL_PK
        PRIMARY KEY (PROD_ID)
        USING INDEX
        PCTFREE      20
        TABLESPACE   USR
)
     PCTFREE    10
     TABLESPACE USR;

/* COMMENT */
COMMENT ON TABLE  PRODUCT_DTL              IS '��ǰ������';
COMMENT ON COLUMN PRODUCT_DTL.PROD_ID      IS '��ǰ���̵�';
COMMENT ON COLUMN PRODUCT_DTL.DESCRIPTION  IS '��ǰ�Ұ�';
COMMENT ON COLUMN PRODUCT_DTL.ILLUSTRATION IS '��ǰ������';

ALTER TABLE PRODUCT_DTL
    ADD CONSTRAINT PRODUCT_DTL_FK 
    FOREIGN KEY(PROD_ID)
    REFERENCES PRODUCT(PROD_ID);




/*******************************************************************************/
/* TABLE NAME : �ֹ�����                                                       */
/*******************************************************************************/
DROP TABLE ORDERS;

CREATE TABLE ORDERS (
     ORD_NO         NUMBER(8)       NOT NULL,    /* �ֹ���ȣ       */
     PROD_ID        VARCHAR(4)      ,            /* ��ǰ���̵�     */
     ORD_AMOUNT     NUMBER(4)       ,            /* ����           */
     ORD_DATE       DATE            ,            /* �������       */
     CUST_ID        VARCHAR(8)      ,            /* ���Ű����̵� */
     EMP_NO         VARCHAR(8)      ,            /* �ǸŻ�����̵� */
     CONSTRAINT ORDERS_PK
        PRIMARY KEY (ORD_NO)
        USING INDEX
        PCTFREE      20
        TABLESPACE   USR
)
     PCTFREE    10
     TABLESPACE USR;

/* COMMENT */
COMMENT ON TABLE  ORDERS               IS '�ֹ�����';
COMMENT ON COLUMN ORDERS.ORD_NO        IS '�ֹ���ȣ';
COMMENT ON COLUMN ORDERS.PROD_ID       IS '��ǰ���̵�';
COMMENT ON COLUMN ORDERS.ORD_AMOUNT    IS '����';
COMMENT ON COLUMN ORDERS.ORD_DATE      IS '�������';
COMMENT ON COLUMN ORDERS.CUST_ID       IS '���Ű����̵�';
COMMENT ON COLUMN ORDERS.EMP_NO        IS '�ǸŻ�����̵�';

CREATE INDEX TIBERO.ORDERS_IDX1 ON TIBERO.ORDERS (
	EMP_NO ASC
)
NOLOGGING
TABLESPACE USR
PCTFREE 10
INITRANS 2;
