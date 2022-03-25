
import java.sql.*;

public class tibero_pstmt_select {
    public static void main(String[] args) throws Exception {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.tmax.tibero.jdbc.TbDriver");
            conn = DriverManager.getConnection("jdbc:tibero:thin:@localhost:8629:tibero", "junsu", "tibero");

            String sql = "SELECT a.num AS num FROM board_content a, board_content b WHERE a.num = b.num AND ROWNUM <= ?;";
            pstmt = conn.prepareStatement(sql);
            
            pstmt.setInt(1, 1000);    
            rs = pstmt.executeQuery();

            while(rs.next()) {
               String board_content_num = rs.getString("num");
               System.out.println("num ==> " + board_content_num);
               System.out.println("\n=========================================\n");
            }

            rs.close();
            pstmt.close();
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
