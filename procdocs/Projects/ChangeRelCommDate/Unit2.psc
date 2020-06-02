{$FORM TForm2, Unit2.sfm}                                                 

uses
  Classes, Graphics, Controls, Forms, Dialogs, Buttons, 
  ExtCtrls, StdCtrls, UniDB;

procedure Form2Activate(Sender: TObject);
begin
  udREL_COMM.DataSet :=  REL_COMM;  
  cxNewDate.Date := Now();
end;



procedure btOKClick(Sender: TObject);
var 
sSQL : string;
begin
     sSQL := 'UPDATE REL_COMM ';        
     sSQL := sSQL + ' SET RELEASE_OUT_DATE=' +#39+ DateTimeToStr(cxNewDate.Date)+ #39 ;
     sSQL := sSQL + ' WHERE ';
     sSQL := sSQL + ' PLACEID=' + IntToStr(REL_COMM.DataSet.FieldByName('PLACEID').Value);
     sSQL := sSQL + ' AND ID=' + IntToStr(REL_COMM.DataSet.FieldByName('ID').Value);
     sSQL := sSQL + ' AND COUNTER=' + IntToStr(REL_COMM.DataSet.FieldByName('COUNTER').Value);
     UpRelComm.SQL.Text := sSQL;
     UpRelComm.ExecSQL;
end;

begin
end;
