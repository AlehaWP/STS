uses                                                   
  Classes,Graphics, Controls,Dialogs, StdCtrls, Forms,  FuncScript, IniFiles, 
  UniDB; 
  
var
ini : TIniFile;
MY_DB : TUniDatabase;
sProgPath : string;
 
procedure OpenBase(sDBNameParam : string);
begin           
          
     sProgPath := ExecuteFuncScript('PROGRAMPATH()');
     ini := TIniFile.Create(sProgPath + 'sts.ini');                                                             

          
     MY_DB := TUniDatabase(Application.FindComponent(sDBNameParam)); 
     if MY_DB = nil then begin  
        MY_DB := TUniDatabase.Create(Application);                              
        With MY_DB do begin 
             IF Setup then begin        
                NAME := sDBNameParam;
                DataBaseName := sDBNameParam;
                Connected := True;
             end;         
        end;
     end
     else begin
        MY_DB.DESTROY;
        OpenBase (sDBNameParam);
     end;   
end;     
