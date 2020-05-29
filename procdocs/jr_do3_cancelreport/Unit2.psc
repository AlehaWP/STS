{$FORM TCancelDOReport, Unit2.sfm}                                                                              
uses
  Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, FuncScript,
  ExtCtrls;

var
  sCancelationSing : String;
  PLACEID : Integer;
  REPORTNUMBER, REPORTDATE, DOCUMENTID : String;
  

procedure mCancelationReasonsPropertiesChange(Sender: TObject);
begin
  btnSend.Enabled := (length (mCancelationReasons.Text) > 0);
end;

procedure cbxCancelationSignPropertiesChange(Sender: TObject);
begin
  lblHint.Width := Width - lblHint.Left;
  case cbxCancelationSign.ItemIndex of
    0: begin
      lblHint.Caption := 'Указанная в отчете операция (принятия или выдачи) не имела места';
      sCancelationSing := 'cancel_StockOperation';             
    end;
    1: begin
      lblHint.Caption := 'Отчет по указанной в отчете операции (принятия или выдачи) уже подавался ранее';
      sCancelationSing := 'cancel_ReportDuplication';
    end;                               
    2: begin
      lblHint.Caption := 'Указанная в отчете операция (принятия или выдачи) имела место, после исправления ошибок ожидается подача нового отчета с исправленными сведениями';
      sCancelationSing := 'cancel_ReportErrors';          
    end;                                       
    3: begin
      lblHint.Caption := '';
      sCancelationSing := 'cancel_OtherReasons';
    end;
  end;
end;

procedure btnSendClick(Sender: TObject);
var
  sScript, sPrdFile : String;
begin
  sScript := '';                                             
                          
  sScript := sScript +
      'VAR ("iPlaceId", Integer, ' + VarToStr(PLACEID) + ');' +
      'VAR ("sReportNumber", String, "' + REPORTNUMBER + '");' +
      'VAR ("sReportDate", String, "' + REPORTDATE + '");' +
      'VAR ("sDocumentId", String, "' + DOCUMENTID + '");' +
      'VAR ("sPersonFIO", String, "' + rePersonFIO.Text + '");' +
      'VAR ("sPersonPost", String, "' + tePersonPost.Text + '");' +
      'VAR ("sCancelationSing", String, "' + sCancelationSing + '");' +
      'VAR ("mCancelationReasons", Memo, "' + mCancelationReasons.Lines.Text + '");' +
      'EXECUTESCRIPT (INCLUDETRAILINGBACKSLASH (PROGRAMPATH ()) + "DATA\IMPEX\SCRIPTS\" + INIFILE ("XMLFormat", "Version", "5.15.0") + "\wh_cancel_do3report.exp");';

  ExecuteFuncScript(sScript);
end;

procedure CancelDOReportCreate(Sender: TObject);
begin                                
  teReport.Text := REPORTNUMBER + ' от ' + REPORTDATE;
  sCancelationSing := 'cancel_OtherReasons';
  lblHint.Height := 38;                            
  
  if Height > Screen.Height then Height := Screen.Height;
  if Width > Screen.Width then Width := Screen.Width;  
end;
         
function LeftPad(scr: string; len: integer): string;
begin
  Result := scr;
  while Length(Result) < len do
    Result := Result + ' ';                                                     
end;

procedure CancelDOReportShow(Sender: TObject);
begin
  teReport.Text := REPORTNUMBER + ' от ' + REPORTDATE;
  lblHint.Width := Width - lblHint.Left;                                            
end;                                                          

procedure CancelDOReportResize(Sender: TObject);
begin
  lblHint.Width := Width - lblHint.Left - 5;
  lblHint.Height := 38;
end;

procedure rePersonFIOPropertiesChange(Sender: TObject);
begin                                                                                                                       
  if Length(tePersonPost.Text) = 0 then 
    tePersonPost.Text := ExecuteFuncScript('REFERENCE ("EMPLOYEE", "EMPLOYEE_NAME", "' + rePersonFIO.Text + '", "EMPLOYEE_POST")');
end;

begin

end;
