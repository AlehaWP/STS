uses                                                                                
  Classes, Graphics, Controls, Forms, Dialogs, Unit2, FuncScript;

var
  MainForm: TForm1;
begin
  ExecuteFuncScript('EXECUTESCRIPT (INCLUDETRAILINGBACKSLASH (PROGRAMPATH()) + "PROCDOCS\eps_statistic\eps_statistic.prd");');
  MainForm := TForm1.Create(Application);
  MainForm.ShowModal;
end;
