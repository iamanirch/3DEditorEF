/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package Test;

/**
 *
 * @author Arvind
 */
import com.oreilly.servlet.*;
import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.*;

public class upload extends HttpServlet {    
    String f1,f2;
    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws
            ServletException, IOException {
        try{
    MultipartRequest m=new MultipartRequest(request, "C:/Users/mani/Dropbox/acads/DDP/3D Model Editing/3DEditorEF/web/3DEditor/model", 100*1024*1024);        
    f2=m.getParameter("hidden");
    f1=m.getParameter("hidden1");
    request.setAttribute("f2",f2);
    request.setAttribute("f1",f1);
    System.out.println(f2);
    System.out.println(f1);
    Thread.sleep(5000);
        }           
                 catch (Exception e) {
                System.out.println(e);
}
            request.getRequestDispatcher("3dEditor.jsp").forward(request, response);

    }

        


}
  
       
    

