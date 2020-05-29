uses                  
  Classes, Graphics, Controls, Forms, Dialogs, FuncScript, Unit2;

var
  MainForm: TMainDialog;
begin      
  if ExecuteFuncScript('BOOKOPENED ()') = '1' then
    begin
      MainForm := TMainDialog.Create(Application);
      MainForm.ShowModal;
    end                     
  else                             
    begin
      Raise('Сначала нужно открыть книгу учёта!');
    end;
end;
