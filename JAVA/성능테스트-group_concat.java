< CUBRID >
package test;
import java.lang.Math;
import java.sql.*;
import java.io.*;
import cubrid.jdbc.driver.*;
import cubrid.sql.*;
import java.util.*;

public class insert {
	public static void main(String[] args) throws SQLException, ClassNotFoundException {
		Class.forName("oracle.jdbc.driver.OracleDriver");
		Connection conn = null;
		conn = DriverManager.getConnection("jdbc:oracle:thin:@172.17.0.3:1521:ORCLCDB",
                "c##junsu","oracle");
        
		PreparedStatement pstmt = null;

		try {
			Random ran = new Random();
			String sql = "INSERT INTO concat_tbl1(code,random_code) VALUES(?,?)";
			pstmt = conn.prepareStatement(sql);
			String value_random_code="";
			int value_code = 1;
			int i1=1 ;
			for (int iii1 = 1; iii1 <= 1000; iii1++) {
				for (int ii1 = 1; ii1 <= 1000; ii1++) {
				    pstmt.setLong(1, value_code);
//					 for (int i1 = 1; i1 <=12; i1++) { // 원하는 난수의 길이
					while(i1 <=12){ 
						 int num1 = (int) 48 + (int) (ran.nextDouble() * 74);
						 
						 if ((num1>=48 && num1<=57)||(num1>=97 && num1<=122))    // 특수문자 제외시킴
	                      {       
					    		value_random_code = value_random_code + (char) num1;
					    		i1++;
	                      } 
					 }
					
					pstmt.setString(2, value_random_code);
					pstmt.executeUpdate();
					value_random_code="";
					i1=1;
				}
				value_code++;
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			conn.close();
		}
	}
}



< ORACLE >
package test;
import java.lang.Math;
import java.sql.*;
import java.io.*;
import cubrid.jdbc.driver.*;
import cubrid.sql.*;
import java.util.*;

public class insert {
	public static void main(String[] args) throws SQLException, ClassNotFoundException {
		Class.forName("cubrid.jdbc.driver.CUBRIDDriver");
		Connection conn = null;
		conn = DriverManager.getConnection("jdbc:cubrid:172.17.0.2:30000:db1:dba::");
        
		PreparedStatement pstmt = null;

		try {
			Random ran = new Random();
			String sql = "INSERT INTO concat_tbl1(code,random_code) VALUES(?,?)";
			pstmt = conn.prepareStatement(sql);
			String value_random_code="";
			int value_code = 1;
			int i1=1 ;
			for (int iii1 = 1; iii1 <= 1000; iii1++) {
				for (int ii1 = 1; ii1 <= 1000; ii1++) {
				    pstmt.setLong(1, value_code);
//					 for (int i1 = 1; i1 <=12; i1++) { // 원하는 난수의 길이
					while(i1 <=12){ 
						 int num1 = (int) 48 + (int) (ran.nextDouble() * 74);
						 
						 if ((num1>=48 && num1<=57)||(num1>=97 && num1<=122))    // 특수문자 제외시킴
	                      {       
					    		value_random_code = value_random_code + (char) num1;
					    		i1++;
	                      } 
					 }
					
					pstmt.setString(2, value_random_code);
					pstmt.executeUpdate();
					value_random_code="";
					i1=1;
				}
				value_code++;
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			conn.close();
		}
	}
}
