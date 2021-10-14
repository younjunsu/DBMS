package java_orcle_blob;
import java.io.File;
import java.io.FileInputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
 
public class BlobTest {
 
    public static void main(String[] args) {
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        
        Connection con = null;
        PreparedStatement stmt = null;
        
        
        try {
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl",
                    "ora_to_cub","cubrid");
            
            File f = new File("E:\\DB\\20190922_102415000_iOS.mp4");    
            FileInputStream fis = new FileInputStream(f);
            
            stmt = con.prepareStatement(
                    "insert into blob_test values(?,?)");
            stmt.setString(1, "20190922_102415000_iOS.mp4");
            stmt.setBinaryStream(2, fis,(int)f.length());
            int rownum = stmt.executeUpdate();
            
            if(rownum >0){
                System.out.println("삽입성공");
            }else
            {
                System.out.println("실패");
            }
            
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        finally {
                //사용한 객체 close
                try {
                    if(con != null) con.close();
                    if(stmt != null) stmt.close();
                } catch (Exception e) {
                    
                }
            
        }
        
    }
 
}
 
