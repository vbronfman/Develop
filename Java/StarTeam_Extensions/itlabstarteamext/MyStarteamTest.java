package itlabstarteamext;

import java.util.*;
//import java.io.*;
import static com.starbase.starteam.Item.LockType.*;
import com.starbase.starteam.*;

/** 
* 
* Utiliy return path of file within specified PROJ/VIEW of starteam.
* @version 2.0
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

public class MyStarteamTest{

/**
* @depricated 
private String address = "starteam1"; // ST Server
private int port = 49201; // ST Port
private String username = "ccmngr"; // ST Login
private String password = "ccmngr"; // ST Pass
*/

private static String filename = null; //file to search 
private static String connString = null; //StarTeam API connection URL - StarTeamFinder extension  
private static String path = null; //StarTeam API connection URL - StarTeamFinder extension  
private static boolean lock = false; // 
private static boolean unlock = false; //unlock file if found 
private static int ret = 1; //return value ofogram 
private static int found = 0; //file to search 
private static boolean debug = false; 


public static void main(String[] args){
   
   parseArgs (args);

   MyStarteamTestUtil utl=new MyStarteamTestUtil();

   connString=(connString!=null)?connString: utl.getValues("connString"); //fetch value from properties file

   connString=(path==null)?connString: String.format("%s/%s", connString,path);
        

   if (debug) System.out.println (connString);

   try{ 
/**
* @example  Enumerate projects
	// Create a Server object Server 
	Server myServer = new Server("starteam1",49201);
	System.out.println("Log In ");
	// Log in to StarTeam
	//myServer.logOn(username,password);
	myServer.logOn("ccmngr","QweQwe11");
	if (myServer.isConnected() ){

	System.out.println("Logged In ");
	String strName="PM_ALM";
	// The project collection is simply an array. 
	Project[] projects = myServer.getProjects(); 
	Project result = null; 
	for (int i = 0; i < projects.length; i++) { 
	Project next = projects[i]; 
	if (next.getName().equals(strName)) { 
	result = next; 
	break; 
	} 
	} 

	if (result != null){
	System.out.println("Project found "+strName);
	View[] view=result.getAccessibleViews();
	}

	myServer.disconnect();
	}
 */

/**
* @depricated Read property file
	Properties response=new Properties();
	response.load(new java.io.FileInputStream("./response.properties"));
*/

	Folder f=myOpenFolder(connString); //throw exception 

	if(f==null){
		System.out.println("Failed Open folder");
		ret=1;
	}
	else{
		if(debug) System.out.println("DEBUG Opened folder "+f.toString());
		File myfile=null;
		if(debug) System.out.println("DEBUG Folder= "+f.toString()+" file="+filename);
		String s=myfindFile (filename, f);
		//  if (s == null || s.isEmpty()) ret=1; //isEmpty since Java 1.6
		if (found > 0 ) ret=0;
	}

}catch(Exception e){
	System.err.println("EXCEPTION in main() Log In Failed:" + e);
}

System.exit(ret);

}

//recursive search, return full name or nothing
static String myfindFile (String fileName, Folder currFolder){

	File myFile=null;

	//System.out.println("DEBUG Inside myfindFile fileName="+fileName.toString()+" currFolder="+currFolder);
	try {
		if (currFolder == null ) return null;
		myFile=StarTeamFinder.findFile(currFolder,fileName,false);
		//System.out.println("Inside findFile myFile=");
		if (myFile != null){
			System.out.println("File found in:"+myFile.getParentFolderHierarchy()+myFile.toString()+"\n");
			found+=1;

			if(lock){
				myFile.putLock(UNLOCKED|BREAK_FLAG, true); //Sets the current user's lock for this file. This method can be used to break another
				// user's exclusive lock on the file. An exception will be thrown if a break is attempted
				// for a user that does not have sufficient rights to break locks
				myFile.lock();//Obtains an exclusive lock on this file without attempting to break an existing lock      

			}
			else if(unlock){
				myFile.putLock(UNLOCKED|BREAK_FLAG, true); //Sets the current user's lock for this file. This method can be used to break another                                               
				//myFile.putLock(0|16, true); //Sets the current user's lock for this file. This method can be used to break another                                               
				// user's exclusive lock on the file. An exception will be thrown if a break is attempted
				// for a user that does not have sufficient rights to break locks
				myFile.unlock(); //Removes the current user's lock from this file. If another user has an exclusive lock on the file this method will not remove that lock
			}

			return myFile.toString();
		}

		//not found

		//System.out.println("DEBUG Descent down "+currFolder.toString());
		Folder[] subfolders=currFolder.getSubFolders();
		if(subfolders.length !=0){ 
			for (int i = 0; i < subfolders.length; i++) {
				//System.out.println("DEBUG Subfoders: subfolders ["+i+"] = "+(subfolders[i]).toString());
				//System.out.println("DEBUG After findFile "+myfindFile(fileName,subfolders[i]));
				myfindFile(fileName,subfolders[i]);
			}
		}
		else {
			//System.out.println("No subfolders in "+currFolder.toString());
			return null; //return string of folder name
		}
	}catch(Exception e){
		if (myFile != null && myFile.getLocker() !=-1 ){
			System.err.println("EXCEPTION in findFile(): file locked by user ID " + myFile.getLocker() );
		}
		//System.out.println("findFile exception:get class " + e.getClass());
		System.err.println("EXCEPTION In findFile():" + e);
	}
	return null;
}



/**
 * Connects to StarTeam and returns an upper Folder of hierarchy 
 * @param  conn url - The url must contain the username, password, host address and port (or server description), project, view name and folder path.
 *                     "ccmngr:QweQwe11@starteam1:49201/PM_ALM/PM_ALM/Develop"
 * @return Folder object 

 */

static Folder myOpenFolder(String conn){
	Folder f=null;
	try {
		f=StarTeamFinder.openFolder(conn);

	}
	catch(Exception e) {
		System.err.println("EXCEPTION in myOpenFolder(). Log In Failed:" + e);
	}
	return f;
}


/**
 * Parse input arguments of the programm. Checks for certain parameteres: -conn, -file, -lock/unlock. Throw exception if one or more not presented. 
 * @param  conn url - The url must contain the username, password, host address and port (or server description), project, view name and folder path.
 *                     "ccmngr:QweQwe11@starteam1:49201/PM_ALM/PM_ALM/Develop"
 * @return Folder object 
 * @throws Exception java.lang.IllegalArgumentException
 */

static void parseArgs (String[] args){

  try{

    if (args.length==0) throw new IllegalArgumentException ();

      for (int i = 0; i < args.length; i++) {
        switch (args[i].charAt(0)) {
        case '-':
            if (args[i].length() < 2)
            {
               throw new IllegalArgumentException ();
            }
            
            String tmp=args[i].substring(1); 
            
            if (tmp.compareToIgnoreCase("conn")==0) {
                      connString=args[i+1] ;
                      i++;
            }
            else if (tmp.compareToIgnoreCase("path")==0) {
                      path=args[i+1] ;
                      i++;
            }
            else if (tmp.compareToIgnoreCase("file")==0){  
                      filename=args[i+1] ;
                      i++;
            }
            else if (tmp.compareToIgnoreCase("lock")==0){  
                     lock=true;
            }
            else if (tmp.compareToIgnoreCase("unlock")==0){  
                     unlock=true;
            }
            else if (tmp.compareToIgnoreCase("debug")==0){  
                     debug=true;
            }
            else throw new IllegalArgumentException ();
               
            break;
        
        default:
           throw new IllegalArgumentException ();
         }
       }//for

// Check for mandatory arguments


// file is a mandatory  argument
        if (filename == null) {

		System.err.println("file is a mandatory argument");
                throw new IllegalArgumentException (); 
        }

// in case connString isn't presented - the path becomes mandatory
        if (connString==null && path ==null ){
		System.err.println("in case connString isn't presented - the path becomes mandatory");
                throw new IllegalArgumentException (); 
        }


     } catch (Exception e){
         System.err.println("Exception caught:"+e);
         Usage();
         }
}

static void Usage(){
String s = String.format("%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s", 
               "Utility returns path of file within specified PROJ/VIEW of StarTeam.",
               "Prints out Parent Folder Hierarchy path of file in case the file is found and nothing - otherwise",
               "Returns 0 if there were no errors during the execution.",
               "\tUsage:",
               "\t\tjava  -cp \"./starteam110.jar:.\" MyStarteamTest  [-conn url] [-path proj/view/folder] <-file fileiname> [-lock|-unlock]",
               "\twhere",
               "\t\tconn - Optional. If isn't presented value the of connString key from properties file is used. URL consists of username, password, host address, port (or server description).\n Optionaly can consist of  project, view name and folder path.",
               "\t\tpath - Optional. If presented contains project, view name and folder path to search within. In case connString isn't presented - the path becomes mandatory; omitted otherwise",
               "\t\tfile - the filename to search. Search isn't casensitive.",
               "\t\tlock - optional parameter. If set - attempt to obtain an exclusive lock on this file with attempting to break an existing lock",
               "\t\tunlock - optional parameter. Removes the current user's lock from this file. If another user has an exclusive lock on the file this method will attempt to remove that lock",
               "\t\tdebug - optional parameter. verbose output",
               "\tExample:",
               "\tjava  -cp \"./starteam110.jar:.\" MyStarteamTest  -conn \"ccmngr:ccmngr@starteam1:49201/PM_ALM/PM_ALM/Develop\" -file statusCMS -lock"
           );

System.out.println(s);
System.exit( 1);
}


}


