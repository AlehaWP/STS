uses                                                             
  Classes, Graphics, Controls, Forms, Dialogs, FuncScript, IniFiles, 
  UniDB, PathBase; 
var
 sDBNameInput : string;
   

begin                      
               
  sDBNameInput := InputParameter('DB_NAME');  
  //PathBase.OpenBase('MY_DB'); 
  PathBase.OpenBase(sDBNameInput); 
end;


 
