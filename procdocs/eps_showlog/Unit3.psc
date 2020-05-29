{$FORM TCancelDOReport, Unit3.sfm}                                                                                               
uses 
  Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, FuncScript,
  ExtCtrls;

var
  sCancelationSing : String;
  iDOType : Integer;

procedure mCancelationReasonsPropertiesChange(Sender: TObject);
begin  
  btnSend.Enabled := (length (mCancelationReasons.Text) > 0) and (length(cbReportNumber.Text)) and (cbReportNumber.ItemIndex <> -1);
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
  if iDOType = 2 then                                   
    begin
//      sScript := 'VAR ("iCounter", Integer, ' + VarToStr('') + ');';
      sScript := 'VAR ("sReleaseString", String, "' + cbReportNumber.Text + '");';
    end;      

  sScript := sScript +
      'VAR ("iPlaceId", Integer, ' + VarToStr(KRD_MAIN.FieldByName('PLACEID').Value) + ');' +
      'VAR ("iId", Integer, ' + VarToStr(KRD_MAIN.FieldByName('ID').Value) +');' +
      'VAR ("iDOType", Integer, ' + VarToStr(iDOType) + ');' +    
      'VAR ("sPersonFIO", String, "' + rePersonFIO.Text + '");' + 
      'VAR ("sPersonPost", String, "' + tePersonPost.Text + '");' +       
      'VAR ("sCancelationSing", String, "' + sCancelationSing + '");' +
      'VAR ("mCancelationReasons", Memo, "' + mCancelationReasons.Lines.Text + '");' +   
      'EXECUTESCRIPT (INCLUDETRAILINGBACKSLASH (PROGRAMPATH ()) + "DATA\IMPEX\SCRIPTS\" + INIFILE ("XMLFormat", "Version", "5.15.0") + "\wh_cancel_doreport.exp");';
  ExecuteFuncScript(sScript);
end;                     
                                                                 
procedure CancelDOReportCreate(Sender: TObject);
begin
  sCancelationSing := 'cancel_OtherReasons';
  lblHint.Height := 38;             
  cbReportNumber.ItemIndex := -1;
  iDOType := 1;
  
  if Height > Screen.Height then Height := Screen.Height;
  if Width > Screen.Width then Width := Screen.Width;
end;
                           
procedure rbtnDO1Click(Sender: TObject);
begin
  cbReportNumber.Properties.Items.Clear;
  cbReportNumber.Properties.Items.Add(KRD_MAIN.FieldByName('NBD').Value + ' от ' + FormatDateTime('DD.MM.YYYY', KRD_MAIN.FieldByName('BD_DATE').Value));
  Caption := 'Отмена подачи отчета по форме ДО-1';
  lblDoType.Caption := 'Форма ДО-1:';
  cbReportNumber.ItemIndex := -1;               
  iDOType := 1; 
  
  mCancelationReasonsPropertiesChange(nil);
end;
         
function LeftPad(scr: string; len: integer): string;
begin
  Result := scr;
  while Length(Result) < len do
    Result := Result + ' ';     
end;

procedure rbtnDO2Click(Sender: TObject);
var
  sLine : String;             
begin
  cbReportNumber.Properties.Items.Clear;
  REL_MAIN.First;
  while not REL_MAIN.Eof do
  begin
    sLine := REL_MAIN.FieldByName('RELEASE_NO').Value + ' от ' + FormatDateTime('DD.MM.YYYY', REL_MAIN.FieldByName('OUT_DATE').Value) + 
             ' (' + REL_MAIN.FieldByName('DOC_TYPE').Value + ' № ' + REL_MAIN.FieldByName('DOC_NO').Value + ' от ' + FormatDateTime ('DD.MM.YYYY', REL_MAIN.FieldByName('RELEASE_DATE').Value) + ')';
    sLine := LeftPad(sLine, 100) + '|' + VarToStr(REL_MAIN.FieldByName('MAIN_COUNTER').Value);
    cbReportNumber.Properties.Items.Add(sLine);                                                                                             
    REL_MAIN.Next;
  end;                
  Caption := 'Отмена подачи отчета по форме ДО-2';
  lblDoType.Caption := 'Форма ДО-2:';
  cbReportNumber.ItemIndex := -1;    
  iDOType := 2;  
  
  mCancelationReasonsPropertiesChange(nil);
end;                                                      
                                             
procedure CancelDOReportShow(Sender: TObject);
begin
  lblHint.Width := Width - lblHint.Left;      
  rbtnDO1Click(nil);
end;                                     

procedure cbReportNumberPropertiesChange(Sender: TObject);
begin
  mCancelationReasonsPropertiesChange(nil);
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
