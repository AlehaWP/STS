{$FORM TfrSelectBase, PathToBase.sfm}                                                    

uses
  Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, FuncScript, IniFiles, 
  UniDB;
  
var
ini : TIniFile;
MY_DB : TUniDatabase;  
                 
procedure SetDbName(sDBNameParam : string); 
begin
     sDB_Name := sDBNameParam;   
end;      

procedure frSelectBaseActivate(Sender: TObject); 
begin 
     //IF (sDB_Name = NULL) or (sDB_Name='') then sDB_Name :='USER_STS_DB'; 
     sProgPath := ExecuteFuncScript('PROGRAMPATH()');
     ini := TIniFile.Create(sProgPath + 'sts.ini');
     iDBListCount := ini.ReadString('DatabaseList','Count', '0'); 
                                                              

          
     MY_DB := TUniDatabase(Application.FindComponent('MY_DB')); 
     if MY_DB = nil then begin  
        MY_DB := TUniDatabase.Create(Application);                              
        With MY_DB do begin  
             Setup;
             NAME := 'MY_DB';
             DataBaseName := 'MY_DB';
             Connected := True;
        end;
     end;                                
               
     {ExecuteFuncScript('BLOCK(
                              OPENDATABASE ("TEST_DB", "STANDARD", "PATH=D:\CTM\STS\DATA\");
                              OPENQUERY ("GET_DO", "SELECT * FROM KRD_MAIN", "TEST_DB");
                              showmessage(GET_DO.ID); )
                       ');
      }                 
     //ExecuteFuncScript('CLOSEDATABASE ("TEST_DB")');
     //ExecuteFuncScriptFromFile(sProgPath + 'ProcDocs\Test.prd');   
     ExecuteFuncScript(          
                      'BLOCK( 
                             OPENQUERY ("GET_DO", "SELECT * FROM KRD_MAIN", "MY_DB");
                             showmessage(GET_DO.ID); 
                      )'                            
     ); 
                     
     //MY_DB_3.Destroy;  
     //ini.WriteString('xxx','xxx',Edit1.Text);
end;                                             
                                                                         
begin
end;
