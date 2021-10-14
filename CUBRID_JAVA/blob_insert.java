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
                PreparedStatement pstmt = null;
                
                try {
                    Connection conn = DriverManager.getConnection("jdbc:cubrid:localhost:30000:MCMS:bin:tibero:", "", "");
                    
                    File f = new File("/home/cub9.3.8.0003/work/20211014/lob1.file");
                    FileInputStream fis = new FileInputStream(f);
                    
                    pstmt = conn.prepareStatement("INSERT INTO a1(x) VALUES(?)");
                    pstmt.setBinaryStream(1, fis,(int)f.length());
                
                    int rownum = pstmt.executeUpdate();
                    if(rownum >0) {
                        System.out.println("OK");
                    }else
                    {
                        System.out.println("FALSE");
                    }
                    
                } catch(Exception e) {
                    System.out.println(e.getMessage());
                }       
        }

    }
