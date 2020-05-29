uses                                                     
  Classes, Graphics, Controls, Forms, Dialogs, Unit2, FuncScript;

var
  MainFormLog : TMForm;         
  
begin                  

  MainFormLog := TMForm.Create(Application);              
  MainFormLog.LoadParams(InputParameter('LID'));
  MainFormLog.ShowModal;                      
  
end;                                                                                
