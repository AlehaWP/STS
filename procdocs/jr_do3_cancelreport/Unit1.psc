uses
  Classes, Graphics, Controls, Forms, Dialogs,
  FuncScript, Unit2;

var
  MainForm: TCancelDOReport;
begin                                                      
  MainForm := TCancelDOReport.Create(Application);
  MainForm.PLACEID := Int(InputParameter('PlaceId'));
  MainForm.REPORTNUMBER := InputParameter('ReportNumber');
  MainForm.REPORTDATE := InputParameter('ReportDate');    
  MainForm.DOCUMENTID := InputParameter('DocumentId');    
  MainForm.ShowModal;                    
end;
