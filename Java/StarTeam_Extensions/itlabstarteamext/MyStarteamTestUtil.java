package itlabstarteamext;

import java.util.*;
//import java.io.*;
import static com.starbase.starteam.Item.LockType.*;
import com.starbase.starteam.*;

/** 
* 
* Utiliy return path of file within specified PROJ/VIEW of starteam.
* @version 1.1
* @author Vlad Bronfman at 210714
* @since  2014-7-14
*
* @param conn The url must contain the username, password, host address and port (or server description), project, view name and folder path
* @param file the filename to search. Search isn't casensitive
* @param lock optional parameter. If set - attempt to obtain an exclusive lock on this file without attempting to break an existing lock
* @param unlock optional parameter. If set - Removes the current user's lock from this file. If another user has an exclusive lock on the file this method will not remove that lock. 
* @see StarTeam API docs http://techpubs.borland.com/starteam/2009/en/sdk_documentation/api/com/starbase/starteam
* @return 0 Returns 0 if there were no errors during the execution.
*
*/

class MyStarteamTestUtil {

   public String getValues(String key){

        System.out.println("DEBUG Key is "+key);
        ResourceBundle bundle=ResourceBundle.getBundle("itlabstarteamext.response");

        System.out.println("DEBUG Key server from properties  "+bundle.getString(key));


        return bundle.getString(key);
   }

}
