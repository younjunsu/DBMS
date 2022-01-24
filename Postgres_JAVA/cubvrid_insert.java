

import java.io.*;
import java.sql.*;
import java.time.*;
import java.util.*;
import java.text.*;
import cubrid.jdbc.driver.* ;
/*
DDL : create table devpg_ex.board_content(num INT NOT NULL AUTO_INCREMENT, title VARCHAR, content VARCHAR, CREATE_DATE DATE, UPDATE_DATE DATE, view_cnt INT);
*/

public class cubrid_insert{
    public static void main(String[] args) throws SQLException, ClassNotFoundException {
    Class.forName("cubrid.jdbc.driver.CUBRIDDriver");
    Connection connection = DriverManager.getConnection("jdbc:cubrid:localhost:33000:demodb:dba::");
    PreparedStatement pstmt = null;

    String title="";
    String content="";
    int view_cnt=0;
   
    System.out.println(1);
    try {
        Random ran = new Random();
        String sql = "INSERT INTO board_content(title,content,create_date,update_date,view_cnt) VALUES(?,?,?,?,?)";
        pstmt = connection.prepareStatement(sql);
        
        for(int ii=1; ii<50000000;ii++) {
            title="";
            content="";
            /* title */
            for (int i = 1; i <= 10; i++) { 
                int num1 = (int) 48 + (int) (ran.nextDouble() * 74);
                title = title + (char) num1;
            }
            
            /* content */
            for (int i = 1; i <= 40; i++) { 
                int num1 = (int) 48 + (int) (ran.nextDouble() * 74);
                content = content + (char) num1;
            }
            
            
            System.out.println(2);
            int minDay = (int) LocalDate.of(2016, 1, 1).toEpochDay();
            int maxDay = (int) LocalDate.of(2022, 1, 1).toEpochDay();
            long randomDay = minDay + ran.nextInt(maxDay - minDay);
            LocalDate create_date = LocalDate.ofEpochDay(randomDay);
            LocalDate update_date = create_date.plusDays(30);   
            System.out.println(3);
            // DateFormat foramt = new SimpleDateFormat("yyyyMMdd");
            System.out.println(4);
            String create_date1 = create_date.toString();
            System.out.println(5);
            String update_date1 = update_date.toString();
            System.out.println(6);
 
     
            /* view_cnt */
            int num1 = (int) 48 + (int) (ran.nextInt(5000));
            view_cnt = view_cnt + (int) num1;
            System.out.println(7);
            System.out.println(title);
            System.out.println(content);
            System.out.println(create_date1);
            System.out.println(update_date1);
            System.out.println(view_cnt);
            pstmt.setString(1, title);
            pstmt.setString(2, content);
            pstmt.setString(3, create_date1);
            pstmt.setString(4, update_date1);
            pstmt.setInt(5, view_cnt);
            pstmt.executeUpdate();
        }    
    }catch ( Exception e) {
        e.printStackTrace();
    } finally {
        connection.close();
    }
}
}
