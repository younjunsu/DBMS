package insert_delay;
import java.sql.*;
import java.io.*;
import cubrid.jdbc.driver.* ;
import cubrid.sql.* ;
import java.util.*;

public class insert {
	public static void main(String[] args) throws SQLException, ClassNotFoundException {
		Class.forName("cubrid.jdbc.driver.CUBRIDDriver");
		Connection conn  = null;
		conn = DriverManager.getConnection("jdbc:cubrid:192.168.204.101:33000:WEBMAIL2:dba:help9544!:");
//        conn.setAutoCommit(false);

		PreparedStatement pstmt = null;

		try {
			Random ran = new Random();
			String value = "";
			int i;
			String sql = "INSERT INTO junsu(a,b,c,d,e,f,g) VALUES(?,?,?,?,?,?,?)";
			pstmt = conn.prepareStatement(sql);
			
			for(int ii=1; ii<999999999;ii++) {
				for (i = 0; i < 15; i++) { // 원하는 난수의 길이
					int num1 = (int) 48 + (int) (ran.nextDouble() * 74);
					value = value + (char) num1;
				}
				
				pstmt.setString(1, value);
				pstmt.setString(2, value);
				pstmt.setString(3, value);
				pstmt.setString(4, value);
				pstmt.setString(5, value);
				pstmt.setString(6, value);
				pstmt.setString(7, value);
				pstmt.executeUpdate();	
			
				value="";
			}
		}catch ( Exception e) {
			e.printStackTrace();
		} finally {
			conn.close();
		}
	}
}
