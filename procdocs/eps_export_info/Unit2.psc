{$FORM TForm2, Unit2.sfm}

uses
  Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, 
  StdCtrls, FuncScript;       

var
  sLogFile : String;                                           

procedure cxButton2Click(Sender: TObject);
begin                                                            
  ExecuteFuncScript('SHOWLOGFILE ("' + sLogFile + '", "Результаты передачи")');
end;                                    

begin                                                    
end;
