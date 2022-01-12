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
        ResultSet rs = null;

        try {
            String sel_sql="SELECT SQ_TH_SYS_ACCES_LOG_SEQ.NEXT_VALUE AS seq FROM DB_ROOT";
            System.out.println("0");
            pstmt =conn.prepareStatement(sel_sql);
            conn.setAutoCommit(false);     
            System.out.println("0-1");      		
            rs = pstmt.executeQuery();
            System.out.println("0-2");
            System.out.println(rs);

            while(rs.next()) {
                int seq1 = rs.getInt(1);
           
            System.out.println(seq1);
            System.out.println("0-3");      		
                
            
            pstmt.close();

            System.out.println("1");
			String sql = "INSERT INTO TH_SYS_ACCES_LOG (SEQ, ACCES_URL, REQUST_QUERY, REQUST_PARAMTR, ACCES_CONFM_STTUS, ACCES__IP, USER_SN, CREAT_DT) VALUES (TO_NUMBER(?), ?, ?, CHAR_TO_CLOB(?), ?, ?, TO_NUMBER(?), SYSDATETIME)";
            conn.setAutoCommit(false);    
			System.out.println("1-1");
            pstmt = conn.prepareStatement(sql);
            
            System.out.println("1-2");
            String v1 = String.valueOf(seq1);
            String v2 = "/gacsem/co/sys/login/Login.do";
            String v3 = null;
            String v4 = "{user_password=fntldk1530!, user_id=kimdmsql93}";
            String v5 = "Y";
            String v6 = "10.117.10.128";
            String v7 = null;

            System.out.println("2");

            pstmt.setString(1, v1);
            pstmt.setString(2, v2);
            pstmt.setString(3, v3);
            pstmt.setString(4, v4);
            pstmt.setString(5, v5);
            pstmt.setString(6, v6);
            pstmt.setString(7, v7);
            pstmt.executeUpdate();
            System.out.println("2-1");
            rs.close();
            pstmt.close();            
            //conn.commit(); 
            conn.close();   
        }
        rs.close();
            System.out.println("3");

		}catch ( Exception e) {
			e.printStackTrace();
		} finally {
			conn.close();
		}
    
    }
}   
