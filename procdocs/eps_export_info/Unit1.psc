uses                                                              
  Classes, Graphics, Controls, Forms, Dialogs, Unit2, FuncScript;

var
  MainForm: TForm2;
begin
  MainForm := TForm2.Create(Application);         
  MainForm.sLogFile := InputParameter('sLogFile');    
  MainForm.do1_send.Caption := IntToStr(InputParameter('ido1')); 
  MainForm.ca_send.Caption := IntToStr(InputParameter('ica'));  
  MainForm.ml_send.Caption := IntToStr(InputParameter('iml'));          
  MainForm.do2_send.Caption := IntToStr(InputParameter('ido2'));        
  MainForm.do1_error.Caption := IntToStr(InputParameter('ido1_fail'));   
  MainForm.ca_error.Caption := IntToStr(InputParameter('ica_fail'));      
  MainForm.ml_error.Caption := IntToStr(InputParameter('iml_fail'));     
  MainForm.do2_error.Caption := IntToStr(InputParameter('ido2_fail'));       
  MainForm.ShowModal;
end;
