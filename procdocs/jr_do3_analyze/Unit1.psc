uses                                            
  Classes, Graphics, Controls, Forms, Dialogs, Unit2, FuncScript;

var
  MainForm: TForm2;
begin
  MainForm := TForm2.Create(Application);  
  MainForm.PLACEID := InputParameter('P1');   
  MainForm.ShowModal;  
end;
