



import java.sql.*;
import cubrid.jdbc.driver.*;

public class SelectData {
    public static void main(String[] args) throws Exception {
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            Class.forName("cubrid.jdbc.driver.CUBRIDDriver");
            conn = DriverManager.getConnection("jdbc:cubrid:localhost:33000:DB:::","dba","암호");

            String sql = "SELECT count(*) as cnt  FROM db_class";
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while(rs.next()) {
               String junsu_cnt = rs.getString("cnt");
               System.out.println("count ==> " + junsu_cnt);
               System.out.println("\n=========================================\n");
            }

            rs.close();
            stmt.close();
            conn.close();
        } catch ( SQLException e ) {
            System.err.println(e.getMessage());
        } catch ( Exception e ) {
            System.err.println(e.getMessage());
        } finally {
            if ( conn != null ) conn.close();
        }
    }
}
