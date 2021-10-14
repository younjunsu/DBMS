import java.sql.*;
import java.io.*;
import cubrid.jdbc.driver.* ;
import cubrid.sql.* ;

public class cub_batch_insert {

	public static void main(String[] args) throws SQLException, ClassNotFoundException {
		Class.forName("cubrid.jdbc.driver.CUBRIDDriver");
		Connection conn  = null;
		conn = DriverManager.getConnection("jdbc:cubrid:192.168.204.201:33000:testdb:dba:cubrid:");
        conn.setAutoCommit(false);
        
		PreparedStatement pstmt = null;

		try {


		int count = 0;
		String sql = "insert into test_dup(a,b,c,d,e,f,g,h,i,j,k,l,m,n) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)  on duplicate key update  a=a, b=b, c=c, d=d, e=e, f=f, i=i, j=j, k=k, l=l, m=m, n=n ";
		pstmt = conn.prepareStatement(sql);
		int cnt_num=1;
		while(cnt_num==1) { 
			while(count<100000) {
			
			  	pstmt.setString(1, "aaaaaaaaaaaaa"+count); 
	        	pstmt.setString(2, "bbbbbbbbbbbbb");
	        	pstmt.setString(3, "ccccccccccccc");
	        	pstmt.setString(4, "ddddddddddddd");
	        	pstmt.setString(5, "eeeeeeeeeeeee");
	        	pstmt.setString(6, "fffffffffffff");
	        	pstmt.setString(7, "ggggggggggggg");
	        	pstmt.setString(8, "hhhhhhhhhhhhh");
	        	pstmt.setString(9, "iiiiiiiiiiiii");
	        	pstmt.setString(10,"jjjjjjjjjjjjj");
	        	pstmt.setString(11,"kkkkkkkkkkkkk");
	        	pstmt.setString(12,"lllllllllllll");
	        	pstmt.setString(13,"mmmmmmmmmmmmm");
	        	pstmt.setString(14,"nnnnnnnnnnnnn");
	        	pstmt.addBatch();
            	pstmt.clearParameters();
	        	
	        	count ++;
            	
			if(count % 100 == 0){
			    pstmt.executeBatch();
			    pstmt.clearBatch(); // Batch Clear
			}
		
			}
				conn.commit();
				pstmt = conn.prepareStatement(sql);
				cnt_num++;
			}
		} catch ( Exception e) {
			e.printStackTrace();
		} finally {
			conn.close();
		}
	}
}