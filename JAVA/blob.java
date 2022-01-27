import cubrid.jdbc.driver.*;
import java.io.File;
import java.io.FileInputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

public class BLOB_MAIN {

	public static void main(String[] args) {
		
		
		try {
			Class.forName("cubrid.jdbc.driver.CUBRIDDriver");
		} catch(Exception e) {
            System.out.println(e.getMessage());
        }
			Connection con = null;
        	PreparedStatement stmt = null;
        	
        	try {
        		Connection conn = DriverManager.getConnection ("jdbc:cubrid:192.168.204.101:30000:YS:dba:cubrid:", "", "");
        		
        		File f = new File("D:\\[Setup File]\\junsu\\junsu.exe");
        		FileInputStream fis = new FileInputStream(f);
        		
        		stmt = conn.prepareStatement("INSERT INTO doc(image) VALUES(?)");
                stmt.setBinaryStream(1, fis,(int)f.length());
      		
        		int rownum = stmt.executeUpdate();
        		
        		if(rownum >0) {
        			System.out.println("»ðÀÔ¼º°ø");
        		}else
        		{
        			System.out.println("»ðÀÔ½ÇÆÐ");
        		}
        		
        	} catch(Exception e) {
        		System.out.println(e.getMessage());
        	}

		
	}

}