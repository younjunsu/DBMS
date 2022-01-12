import java.sql.*;
import java.io.*;
import cubrid.jdbc.driver.* ;
import cubrid.sql.* ;
import java.util.*;

public class cubrid_insert {
	public static void main(String[] args) throws SQLException, ClassNotFoundException {
		Class.forName("cubrid.jdbc.driver.CUBRIDDriver");
		Connection conn = DriverManager.getConnection("jdbc:cubrid:localhost:33000:gacsdb:dba::");
        PreparedStatement pstmt = null;

		try {
			String sql = "INSERT INTO TH_SYS_ACCES_LOG (SEQ, ACCES_URL, REQUST_QUERY, REQUST_PARAMTR, ACCES_CONFM_STTUS, ACCES__IP, USER_SN, CREAT_DT) VALUES (TO_NUMBER(?), ?, ?, CHAR_TO_CLOB(?), ?, ?, TO_NUMBER(?), SYSDATETIME)";
			pstmt = conn.prepareStatement(sql);
            String v1 = "59897528";
            String v2 = "/gacsem/co/sys/login/Login.do";
            String v3 = "1";
            String v4 = "{user_password=fntldk1530!, user_id=kimdmsql93}";
            String v5 = "Y";
            String v6 = "10.117.10.128";
            String v7 = "1";

				pstmt.setString(1, v1);
				pstmt.setString(2, v2);
				pstmt.setString(3, v3);
				pstmt.setString(4, v4);
				pstmt.setString(5, v5);
				pstmt.setString(6, v6);
				pstmt.setString(7, v7);
				pstmt.executeUpdate();
			
		}catch ( Exception e) {
			e.printStackTrace();
		} finally {
			conn.close();
		}
    
    }
}   
