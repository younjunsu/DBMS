import java.io.File;
import java.io.FileInputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

public class test {
	public static void main(String[] args) {
		try {
			Class.forName("com.tmax.tibero.jdbc.TbDriver");
		} catch(Exception e) {
            System.out.println(e.getMessage());
        }
        	String ip = "192.168.246.101";
			String port = "8629";
			String database = "dodo";
			String user = "sys";
			String psw = "tibero";
            String sqltext = "INSERT INTO DOC(BLOBFILE) VALUES(?)";

        	try {
                
        		String tibero_url = "jdbc:tibero:thin:@" + ip + ":" + port + ":" + database;
                PreparedStatement stmt = null;
        		Connection conn = DriverManager.getConnection(tibero_url,user,psw);

                /* Windows Type*/       		
          		//File f = new File("C:\\Users\\junsu\\Downloads\\tbinary_v1.4.22.tar");

                /* Linux Type*/
        		File f = new File("/home/tibero/work/profile");

        		FileInputStream fis = new FileInputStream(f);
        		
        		stmt = conn.prepareStatement(sqltext);
 		        stmt.setBinaryStream(1, fis,(int)f.length());
                
                /* Success Check */
        		int rownum = stmt.executeUpdate();
        		
        		if(rownum >0) {
        			System.out.println("ok");
        		}else
        		{
        			System.out.println("X");
        		}
                /* Success Check Done */
        	} catch(Exception e) {
        		System.out.println(e.getMessage());
        	}	
	}

}	