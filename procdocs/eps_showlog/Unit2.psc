{$FORM TfrmLogEPS, Unit2.sfm}                                                                                                                                                                                                                                                                                  
                    
uses                                             
  Classes, Graphics, Controls, Forms, Dialogs, Grids, DBGrids,
  DB, ADODB, DBTables, cxGrid, cxGridBandedTableView, 
  cxGridCustomTableView, cxGridCustomView,          
  cxGridDBBandedTableView, cxGridLevel, UniDB, Menus, 
  FuncScript, System, SysUtils, Windows, 
  Registry, WinInet,   
  ClipBrd, StdCtrls, ExtCtrls,
  ShellApi, UrlMon, AnsiStrings,
  Unit3;                              

const
  REGINI = TRegIniFile.Create('Software\CTM\');
  KEY = 'STS\PROCDOCS\EPS_SHOWLOG';
                    
var                                          
  sType, sUserUUID, sFileName, sKey, sDocumentIDList : String;                                                               
  Xml : TStringList;                       
  frmCancelDO : TCancelDOReport;
                                                       
procedure frmLogEPSClose(Sender: TObject; var Action: TCloseAction);         
begin
  if pmUserMsgs.Checked then begin
    REGINI.WriteInteger(KEY, 'Veiw', 0);
  end
  else if pmUserAndTechMsgs.Checked then begin
    REGINI.WriteInteger(KEY, 'Veiw', 1);
  end
  else if pmAllMsgs.Checked then begin
    REGINI.WriteInteger(KEY, 'Veiw', 2);
  end;

  //сохраняем параметры формы
  // если окно развернуто на весь экран - не запоминаем его размер                                                             
  if WindowState <> wsMaximized then
    begin
      REGINI.WriteInteger(KEY, 'Height', Height); 
      REGINI.WriteInteger(KEY, 'Width', Width);
    end;
  REGINI.WriteInteger(KEY, 'WindowState', WindowState);
  REGINI.Free;                                                                              
end;                                                        

procedure UpdateDocumentIdList;
var
  sScript : String;
begin
  sScript := 'VAR ("sDocumentID", String, KRD_MAIN.DOCUMENTID);' +
             'sDocumentID := sDocumentID + "|" + REPLACESTR (UNIONVALUES ("REL_MAIN", ["DOCUMENTID"], "|", ""), " ", "");' +
             'sDocumentID';
  sDocumentIdList := ExecuteFuncScript(sScript);
end;

procedure SetConnection;                        
Var                                                                                                                                
  sSQL : String;                                                 
begin                                                                                                                                       
    sKey := 'MONITORED\MAIN\Db';
    Case REGINI.ReadInteger(sKey, 'ArcType', 0) of
      1 : begin                                       
            if REGINI.ReadString(sKey, 'ArcDir', '') <> '' then
              begin                                                                                             
                if MEDConnection.Connected then MEDConnection.Connected := false;                           
                MEDConnection.Provider := 'Microsoft.Jet.OLEDB.4.0';                                                
                MEDConnection.LoginPrompt := False;           
                MEDConnection.Mode := cmRead;           
//                Provider=Microsoft.Jet.OLEDB.4.0;Data Source=D:\CTM\ALLDATA\MONITORED\BASE\MONITORED.MDB;Persist Security Info=False;
                MEDConnection.ConnectionString := 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source='+ REGINI.ReadString(sKey, 'ArcDir', '') +'MONITORED.MDB;Persist Security Info=False';
                if not MEDConnection.Connected then MEDConnection.Connected := true;
                          
                if qryMonitor.Active then qryMonitor.Active := False;    
                qryMonitor.Connection := MEDConnection;                                                            
 
//                if not qryMonitor.Active then qryMonitor.Active := True;   
                                                           
                if qPId.Active then qPId.Active := False;
                qPId.Connection := MEDConnection;                   
              end;            
          end;                                                                                         
      2 : begin                                  
            sKey := sKey + '\SQLServer';
            if REGINI.ReadString(sKey, 'DBName', '') <> '' then
              begin                                
                if MEDConnection.Connected then MEDConnection.Connected := false;
                MEDConnection.Provider := 'SQLOLEDB.1';
                MEDConnection.LoginPrompt := false;        
                MEDConnection.Mode := cmRead;                                               
                MEDConnection.ConnectionString := 'Provider=SQLOLEDB.1;Data Source=' + REGINI.ReadString(sKey, 'ServerName', '') + ';Initial Catalog=' + REGINI.ReadString(sKey, 'DBName', '') + ';';                              
                if REGINI.ReadString(sKey, 'IntegratedSecurity', '') = '1' then
                  MEDConnection.ConnectionString := MEDConnection.ConnectionString + 'Integrated Security=SSPI;';                  
                else if REGINI.ReadString(sKey, 'IntegratedSecurity', '') <> '' then
                  MEDConnection.ConnectionString := MEDConnection.ConnectionString + 'User Id=' + REGINI.ReadString(sKey, 'Login', '') + ';Password=' + REGINI.ReadString(sKey, 'Password', '') + ';';                                                                                    
                if not MEDConnection.Connected then MEDConnection.Connected := true;

                if qryMonitor.Active then qryMonitor.Active := False;                    
                qryMonitor.Connection := MEDConnection;
               
//                if not qryMonitor.Active then qryMonitor.Active := True;                                                               
                
                if qPId.Active then qPId.Active := False;
                qPId.Connection := MEDConnection;                     
              end;
          end;              
    else           
      ExecuteFuncScript('SHOWMESSAGE ("Неизвестный тип базы данных Монитор ЭД", 2, "ВЭД-Склад: Лог ЭПС");');
    end;                       
end;
                                                                                  
procedure frmLogEPSActivate(Sender: TObject);                                      
var
  sSQL : String;
begin                                                 

//  case ExecuteFuncScript ('INIFILE ("EPS_LOG", "View", "1")') of
  case REGINI.ReadInteger(KEY, 'View', 0) of
    0: begin
      pmUserMsgs.Checked := True;
    end;
    1: begin
      pmUserAndTechMsgs.Checked := True;    
    end;
    2: begin
      pmAllMsgs.Checked := True;    
    end;
  end;

  pmColoredRows.Checked := REGINI.ReadBool(KEY, 'ColoredRows', true);   

  // Проверка на случай обновления по f5. Чтобы не переоткрывать соединение
  if not MEDConnection.Connected then SetConnection;
  
  qryEpsLog.Params[0].Value := KRD_MAIN.FieldByName('PLACEID').Value;
  qryEpsLog.Params[1].Value := KRD_MAIN.FieldByName('ID').Value;   
  If KRD_MAIN.FieldByName('DOCUMENTID').Value <> Null then
    qryEpsLog.Params[2].Value := KRD_MAIN.FieldByName('DOCUMENTID').Value
  else   qryEpsLog.Params[2].Value := '1';
  IF REL_MAIN.FieldByName('DOCUMENTID').Value <> Null then
    qryEpsLog.Params[3].Value := REL_MAIN.FieldByName('DOCUMENTID').Value
  else qryEpsLog.Params[3].Value := '1';
    
  if pmUserMsgs.Checked then begin
    qryEpsLog.Params[4].Value := 0  
  end 
  else if pmUserAndTechMsgs.Checked then begin
    qryEpsLog.Params[4].Value := 1 
  end
  else if pmAllMsgs.Checked then begin
    qryEpsLog.Params[4].Value := 2  
  end; 
  
  // Сделано на случай обновления по f5
  if qryEpsLog.Active then begin 
      qryEpsLog.Reopen;
  end else
    qryEpsLog.Active := True;                 
                                          
  //MEDConnection.Connected := True;              
  //qryMonitor.Active := True;                                  
                                           
  pmAutoWidth.Checked := ExecuteFuncScript ('IniFile ("EPS_LOG", "TopGridAutoWidth", "True")');
  gridEpsLogDBTableView1.OptionsView.ColumnAutoWidth := pmAutoWidth.Checked;     
                                                                  
  if VarIsNull(qryEpsLog.FieldByName('PLACEID').Value) then                        
    begin
      miOpenProtocolMED.Enabled := False;   
      btnShowXmlDocument.Enabled := False;
      if LENGTH (KRD_MAIN.Fields['PROCESSID'].Value) = 36 then 
        miHistoryRequest.Enabled := True                            
      else
        miHistoryRequest.Enabled := False;      
    end;                
                                                              
  // открываем журнал регистрации сообщений на последней записи
  gridEpsLogDBTableView1.DataController.DataSource.DataSet.Last;          
  
  UpdateDocumentIdList;     
  gridEpsLog.SetFocus;

end;

procedure ShowXmlDocument(sFile: String; sFmtVersion: String);    
var                                                      
  sScript : String;                                  
begin
  sScript := 'EXECUTESCRIPT ("ProcDocs\eps_showlog\view_backup_file.prd");ViewBackupFile("' + sFile + '", "' + sFmtVersion + '");';
  ExecuteFuncScript(sScript);                                                                      
end;
                                       
procedure setMsgIdParameters;
var 
  sProcessId : String;
begin
  qPId.Active := False;                                                     
  qPId.Parameters[0].Value := qryEpsLog.FieldByName('PLACEID').Value;
  qPId.Parameters[1].Value := qryEpsLog.FieldByName('DOCUMENTID').Value;  
  qPId.Parameters[2].Value := qryEpsLog.FieldByName('COUNTER').Value;        
  qPId.Active := True;                                                 
  sProcessId := qPId.Fields[0].Value;
  
  if chkbHideTechMessages.Checked then
    begin                                         
      qryMonitor.Parameters.ParamByName('msgid1').Value := 'ED.11001';
      qryMonitor.Parameters.ParamByName('msgid2').Value := 'ED.11002';            
      qryMonitor.Parameters.ParamByName('msgid3').Value := 'CMN.00002';            
      qryMonitor.Parameters.ParamByName('msgid4').Value := 'CMN.00004';
//      qryMonitor.Parameters.ParamByName('processid').Value := KRD_MAIN.Fields['PROCESSID'].Value;   
      qryMonitor.Parameters.ParamByName('processid').Value := sProcessId;        
    end                                                                                            
  else
    begin
      qryMonitor.Parameters.ParamByName('msgid1').Value := '';
      qryMonitor.Parameters.ParamByName('msgid2').Value := '';            
      qryMonitor.Parameters.ParamByName('msgid3').Value := '';            
      qryMonitor.Parameters.ParamByName('msgid4').Value := '';                        
//      qryMonitor.Parameters.ParamByName('processid').Value := KRD_MAIN.Fields['PROCESSID'].Value;  
      qryMonitor.Parameters.ParamByName('processid').Value := sProcessId;   
    end;                                                            
end;
                                                                                                                             
procedure gridEpsLogDBTableView1FocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
begin   

  if (qryMonitor.Parameters[0].Value <> qryEpsLog.FieldByName('PLACEID').Value)  or 
     (qryMonitor.Parameters[1].Value <> qryEpsLog.FieldByName('DOCUMENTID').Value) or
     (qryMonitor.Parameters[2].Value <> qryEpsLog.FieldByName('COUNTER').Value)  then  
  begin                                    
    qryMonitor.Parameters[0].Value := qryEpsLog.FieldByName('PLACEID').Value;        
    qryMonitor.Parameters[1].Value := qryEpsLog.FieldByName('DOCUMENTID').Value;                                                                           
    qryMonitor.Parameters[2].Value := qryEpsLog.FieldByName('COUNTER').Value;    
                  
    qryMonitor.Active := False;
          
    // вызываем процедуру установки параметров MsgId1, MsgId2, ...
    setMsgIdParameters;                                            
                                  
    qryMonitor.Active := True;
                                                             
    // если просматриваем не протокол ДО-1, то блокируем запрос истории процедуры
    if (qryEpsLog.FieldByName('COUNTER').Value = 0) then
    begin
      miHistoryRequest.Enabled := True;   
    end
    else                                                                 
    begin             
      miHistoryRequest.Enabled := False;  
    end;
                 
  end;

end;                                                        
                                                      
procedure OpenProtocolMED;  
begin                                                    
  if qryEpsLog.FieldByName('DOCTYPE').Value = 'ДО-1' then sType := '1_' else sType := '2_';
  sUserUUID := ExecuteFuncScript ('UserInfo("", "UserUUID")');
  if Length(sUserUUID) > 0 then      
    sFileName := 'STS-MED\iin\' + sUserUUID + '\SHOWLOGDO' + sType + VarToStr(qryEpsLog.FieldByName('PLACEID').Value) + '_' + qryEpsLog.FieldByName('DOCUMENTID').Value + '_' + VarToStr(qryEpsLog.FieldByName('COUNTER').Value) + '.xml'
  else                                                                                            
    sFileName := 'STS-MED\iin\SHOWLOGDO' + sType + VarToStr(qryEpsLog.FieldByName('PLACEID').Value) + '_' + qryEpsLog.FieldByName('DOCUMENTID').Value + '_' + VarToStr(qryEpsLog.FieldByName('COUNTER').Value) + '.xml';
                                       
  Xml := TStringList.Create;           
  Xml.Add('<?xml version="1.0" encoding="windows-1251"?>');                
  Xml.Add('<ShowLog>Просмотр протокола ДО</ShowLog>');            
  Xml.SaveToFile(ExtractFilePath(Application.ExeName) + sFileName);   
end;                                                                 
                
procedure ShowMED;
begin
  sUserUUID := ExecuteFuncScript ('UserInfo("", "UserUUID")');        
  if Length(sUserUUID) > 0 then
    sFileName := 'STS-MED\iin\' + sUserUUID + '\SHOWMONITORED.xml'
  else                                                              
    sFileName := 'STS-MED\iin\SHOWMONITORED.xml';   
    
  Xml := TStringList.Create;
  Xml.Add('<?xml version="1.0" encoding="utf-8"?>');                
  Xml.Add('<SHOWMONITORED></SHOWMONITORED>');            
  Xml.SaveToFile(ExtractFilePath(Application.ExeName) + sFileName);  
end; 
            
procedure ResendDO2;
begin  
  try
    ExecuteFuncScript ('EXECUTESCRIPT (INCLUDETRAILINGBACKSLASH (PROGRAMPATH ()) + "ProcDocs\do2_resend.prd")'); 
  finally
    qryEpsLog.Reopen;
    KRD_MAIN.DataSet.Refresh;
    UpdateDocumentIdList;
    qryMonitor.Refresh;
  end;
end;                                                 
                                                   
procedure FixProtocol;
begin
  try
    ExecuteFuncScript ('EXECUTESCRIPT (INCLUDETRAILINGBACKSLASH (PROGRAMPATH ()) + "ProcDocs\fix_protocol.prd")');
  finally
    qryEpsLog.Reopen;
    KRD_MAIN.DataSet.Refresh;
    REL_MAIN.DataSet.Refresh;
    UpdateDocumentIdList;
    qryMonitor.Refresh;
  end;
end;


procedure HistoryRequest;
var
  sProcessId, sScriptText : String;
begin                        
//  ExecuteFuncScript ('EXECUTESCRIPT (INCLUDETRAILINGBACKSLASH (PROGRAMPATH ()) + "ProcDocs\history_request.prd")')       
  sProcessId := '';
  if KRD_MAIN.Fields['ID'].Value = qryEpsLog.Fields['PLACEID'].Value then sProcessId := KRD_MAIN.Fields['PROCESSID'].Value;

  if Length(sProcessId) <> 36 then begin
      qPId.Active := False;                                                     
      qPId.Parameters[0].Value := qryEpsLog.FieldByName('PLACEID').Value;
      qPId.Parameters[1].Value := qryEpsLog.FieldByName('DOCUMENTID').Value;  
      qPId.Parameters[2].Value := qryEpsLog.FieldByName('COUNTER').Value;        
      qPId.Active := True;                                              
    
      sProcessId := qPId.Fields[0].Value;
  end;   
  
  if sProcessId <> '' then begin  
    sUserUUID := ExecuteFuncScript ('UserInfo("", "UserUUID")'); 
  
    if Length(sUserUUID) > 0 then
      sFileName := 'STS-MED\iin\' + sUserUUID + '\DO1HISTORY_' + IntToStr(qryMonitor.FieldByName('WHId').Value) + '_' + qryMonitor.FieldByName('WHDocId').Value + '_' + sProcessId + '.xml'                                         
    else
      sFileName := 'STS-MED\iin\DO1HISTORY_' + IntToStr(qryMonitor.FieldByName('WHId').Value) + '_' + qryMonitor.FieldByName('WHDocId').Value + '_' + sProcessId + '.xml';        

    Xml := TStringList.Create;
    Xml.Add('<?xml version="1.0" encoding="utf-8"?>');
    Xml.Add('<DO1HistoryRequest>');      
    Xml.Add('  <PlaceId>' + IntToStr(qryMonitor.FieldByName('WHId').Value) + '</PlaceId>');                 
    Xml.Add('  <DocumentId>' + qryMonitor.FieldByName('WHDocId').Value + '</DocumentId>');  
    Xml.Add('  <ProcessId>' + sProcessId + '</ProcessId>');             
    Xml.Add('</DO1HistoryRequest>');      
     
    if trim (sFileName) <> '' then
      Xml.SaveToFile(ExtractFilePath(Application.ExeName) + sFileName);           
  end;

  sScriptText := 'EXECUTESCRIPT (INCLUDETRAILINGBACKSLASH (PROGRAMPATH ()) + "ProcDocs\write_eps_log.prd");' +
                  'WriteEpsLog (' + IntToStr(qryEpsLog.Fields['PLACEID'].Value) + 
                  ',' + IntToStr(qryEpsLog.Fields['ID'].Value) + 
                  ',' + VarToStr(qryEpsLog.Fields['COUNTER'].Value) + 
                  ',"' + qryMonitor.FieldByName('WHDocId').Value + '"' +
                  ',"' + qryEpsLog.Fields['DocType'].Value + '"' +
                  ',"' + qryEpsLog.Fields['DocNo'].Value + '"' +
                  ',"' + VarToStr(qryEpsLog.Fields['DocDate'].Value) + '"' +
                  ', "Запрошена история процедуры"' +
                  ', FDT ("DD.MM.YYYY HH:NN:SS", (Date () + Time (1)))' +
                  ', GENERATEUUID()' +
                  ', ""' +
                  ', ""' +           
                  ', "1"' +                                                 
                  ', FDT ("DD.MM.YYYY HH:NN:SS", (Date () + Time (1)))' +
                  ', 0' + 
                  ');';
  try
    ExecuteFuncScript(sScriptText);       
  finally
    qryEpsLog.Reopen;
  end;
  
  // пока закомментируем обновление значения "Стаутс ЭПС", 
  // т. к. при получении истории не возникает никаких событий и мы не сможем
  // сменить статус на "История получена"
  //ExecuteFuncScript('EXECUTESQL ("STS_DB", "UPDATE KRD_MAIN SET STATUS_EPS="+char(39)+"Запрошена история процедуры"+char(39)+" WHERE PLACEID=' + IntToStr(KRD_MAIN.FIELDS['PLACEID'].Value) + ' AND ID=' + IntToStr(KRD_MAIN.FIELDS['ID'].Value) + '");');
end;                                                                                                                              
                                
procedure UpdateStatusEPS;
var iChVariant: Integer;
begin
  try
    if StrToInt(ExecuteFuncScript ('GETSELECTEDCOUNT()')) > 0 then 
      begin
       iChVariant := StrToInt(ExecuteFuncScript ('CHOICEVARIANT ("Обновтить статусы для документов:", 1, 1, ["Текущего", "Выделенных"])'));
       case iChVariant of
         0: ExecuteFuncScript ('EXECUTESCRIPT (INCLUDETRAILINGBACKSLASH(PROGRAMPATH()) + "procdocs\refresh_eps.prd"); RefreshEps(KRD_MAIN.PLACEID,KRD_MAIN.ID,KRD_MAIN.DOCUMENTID);');
         1: ExecuteFuncScript ('EXECUTESCRIPT (INCLUDETRAILINGBACKSLASH(PROGRAMPATH()) + "procdocs\refresh_eps_SelectedDO.prd")');
       end
      end
    else
      ExecuteFuncScript ('EXECUTESCRIPT (INCLUDETRAILINGBACKSLASH(PROGRAMPATH()) + "procdocs\refresh_eps.prd"); RefreshEps(KRD_MAIN.PLACEID,KRD_MAIN.ID,KRD_MAIN.DOCUMENTID);');
  finally
    qryEpsLog.Reopen;     
    KRD_MAIN.DataSet.Refresh; 
    ExecuteFuncScript ('GLOBALREFRESH()');
  end;
end;                                                                                
      
procedure btnShowXmDocumentClick(Sender: TObject);
var 
  ext : Variant;     
  sBackupFile, sDocumentModeCode : String;   
  sScript : String;    
  iIncoming : Integer;        
begin                       
  if qryMonitor.FieldByName('INCOMING').Value then
    iIncoming := 1
  else
    iIncoming := 0;
  
  sScript := 'EXECUTESCRIPT (INCLUDETRAILINGBACKSLASH (PROGRAMPATH ()) + "ProcDocs\utils\get_backup_file.prd");' +
             'GetBackupFile ("' + VarToStr(qryMonitor.FieldByName('BACKUPFILE').Value) + '", ' +  VarToStr(iIncoming) + ')';           
  sBackupFile := ExecuteFuncScript(sScript);
  
  if FileExists(sBackupFile) then
    ShowXmlDocument(sBackupFile, qryMonitor.FieldByName('FmtVersion').Value)     
  else
    ExecuteFuncScript('SHOWMESSAGE ("Файл не найден. Возможно, он уже удален из каталога резервных копий.", 2, "ВЭД-Склад: Лог ЭПС");');
        
end;                                                        

procedure RepeatDOMessage;
var 
  sUserUUID, sFileName : String;
begin           
  if Length (qryMonitor.FieldByName('WHPROCESSID').Value) > 0 then begin 
    sUserUUID := ExecuteFuncScript ('UserInfo ("", "UserUUID")');
    if Length(sUserUUID) > 0 then
      sFileName := 'STS-MED\iin\' + sUserUUID + '\repeatdo1message_' + IntToStr(KRD_MAIN.FieldByName('PLACEID').Value) + '_' + KRD_MAIN.FieldByName('DOCUMENTID').Value + '_' + qryMonitor.FieldByName('WHPROCESSID').Value + '_' + qryMonitor.FieldByName('ENVELOPEID').Value + '.xml';
    else                        
      sFileName := 'STS-MED\iin\repeatdo1message_' + IntToStr(KRD_MAIN.FieldByName('PLACEID').Value) + '_' + KRD_MAIN.FieldByName('DOCUMENTID').Value + '_' + qryMonitor.FieldByName('WHPROCESSID').Value + '_' + qryMonitor.FieldByName('ENVELOPEID').Value + '.xml';
                          
    Xml := TStringList.Create;
    Xml.Add('<?xml version="1.0" encoding="utf-8"?>');
    Xml.Add('<RepeatDO1Message>');           
    Xml.Add('  <WHID>' + IntToStr(KRD_MAIN.FieldByName('PLACEID').Value) + '</WHID>');
    Xml.Add('  <WHDocID>' + KRD_MAIN.FieldByName('DOCUMENTID').Value + '</WHDocID>'); 
    Xml.Add('  <WHProcessID>' + qryMonitor.FieldByName('WHPROCESSID').Value + '</WHProcessID>');
    Xml.Add('  <EnvelopeID>' + qryMonitor.FieldByName('ENVELOPEID').Value + '</EnvelopeID>');
    Xml.Add('</RepeatDO1Message>');    
                                                     
    if trim(sFileName) <> '' then begin
      Xml.SaveToFile(ExtractFilePath(Application.ExeName) + sFileName);
      ExecuteFuncScript ('SHOWMESSAGE ("Выполнен запрос повтора сообщения", 0, "ВЭД-Склад: Лог ЭПС");');
    end;
  end
  else begin
    ExecuteFuncScript ('SHOWMESSAGE ("У сообщения нет идентификатора процедуры", 2, "ВЭД-Склад: Лог ЭПС");');
  end;
  
end;                                                                                              

procedure gridMEDDBTableView1MsgIdPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var 
  sBackupFile, sScript : String;  
  iIncoming : Integer;
begin
  if (VarToStr(qryMonitor.FieldByName('FMTVERSION').Value) = '') and (VarToStr(qryMonitor.FieldByName('SPECVERSION').Value) = '') then begin
//    showmessage ('Данное сообщение отсутствует в базе данных.' +chr(13)+ 'Необходимо в Мониторе ЭД запрос отсутствующих сообщений.'); 
    RepeatDOMessage;
  end
  else begin   
    if qryMonitor.FieldByName('INCOMING').Value then
      iIncoming := 1
    else
      iIncoming := 0;
  
    sScript := 'EXECUTESCRIPT (INCLUDETRAILINGBACKSLASH (PROGRAMPATH ()) + "ProcDocs\utils\get_backup_file.prd");' +
               'GetBackupFile ("' + VarToStr(qryMonitor.FieldByName('BACKUPFILE').Value) + '", ' +  VarToStr(iIncoming) + ')';           
    sBackupFile := ExecuteFuncScript(sScript);      
  
    if FileExists(sBackupFile) then
      ShowXmlDocument(sBackupFile, qryMonitor.FieldByName('FmtVersion').Value)     
    else                                              
      ExecuteFuncScript('SHOWMESSAGE ("Файл не найден. Возможно, он уже удален из каталога резервных копий.", 2, "ВЭД-Склад: Лог ЭПС");');
  end;                
end; 
                  
procedure gridEpsLogDBTableView1SubStatusPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var 
  sCustomsId : String;     
begin
  sCustomsId := ExecuteFuncScript('VAR ("sCustomsID", String, ""); REGEXMATCH ("' + qryEpsLog.FieldByName('SubStatus').Value + '", "(\S{8}(-\S{4}){3}-\S{12})", 34, "sCustomsID"); sCustomsID');
  if Length(sCustomsId) = 36 then
    Clipboard.AsText := sCustomsId
  else begin
    sCustomsId := ExecuteFuncScript('VAR ("sCustomsID", String, ""); REGEXMATCH ("' + qryEpsLog.FieldByName('SubStatus').Value + '", "(\d{8}\/\d{6}\/\d{7})", 34, "sCustomsID"); sCustomsID');
    if Length(sCustomsId) = 23 then
      Clipboard.AsText := sCustomsId      
    else                             
      Clipboard.AsText := qryEpsLog.FieldByName('SubStatus').Value;
  end;
end;                                                                
                                 

procedure gridMEDDBTableView1WHProcessIdPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin                       
  Clipboard.AsText := qryMonitor.FieldByName('WHProcessId').Value;
end;

procedure gridMEDDBTableView1EnvelopeIdPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Clipboard.AsText := qryMonitor.FieldByName('EnvelopeId').Value;  
end;

procedure gridMEDDBTableView1ParticipantIdPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Clipboard.AsText := qryMonitor.FieldByName('ParticipantId').Value;    
end;

procedure gridMEDDBTableView1WHIdPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin                     
  Clipboard.AsText := qryMonitor.FieldByName('WHId').Value;      
end;
                              
procedure gridMEDDBTableView1WHDocIdPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin                                                                                      
  Clipboard.AsText := qryMonitor.FieldByName('WHDocId').Value;
end;

procedure gridMEDDBTableView1WHDocId2PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin                                             
  Clipboard.AsText := qryMonitor.FieldByName('WHDocId2').Value;
end;

                                
procedure miCloseClick(Sender: TObject);
begin
  Close;
end;

procedure PopupMenu1_NewItem1Click(Sender: TObject);
begin               
  pmAutoWidth.Checked := not pmAutoWidth.Checked
  gridEpsLogDBTableView1.OptionsView.ColumnAutoWidth := pmAutoWidth.Checked;
  ExecuteFuncScript ('WriteIniFile ("EPS_LOG", "TopGridAutoWidth", "' + VarToStr(gridEpsLogDBTableView1.OptionsView.ColumnAutoWidth) + '")');
end;

procedure miTeamViewerClick(Sender: TObject);
var 
sTVPath, sTVFileName, sUrl : string;   
begin        
  sUrl := 'http://ftp.ctm.ru/ctm/SUPPORT/TeamViewerQS_ru.exe';  
  sTVFileName := 'TeamViewer_QS.exe'                                                 
  sTVPath := IncludeTrailingBackslash(GetEnvironmentVariable('TEMP')) + 'DOWNLOADS\';        
  if FileExists(sTVPath + sTVFileName) then                                                                
    //ShellExecute(Handle, 'open', 'TeamViewer_QS.exe', nil, nil, 5);
    ShellExecute(Handle, 'Open', sTVPath + sTVFileName, nil, nil, 5)
  else         
    begin
      ForceDirectories(sTVPath);  
      DeleteUrlCacheEntry(sUrl);
      URLDownloadToFile(nil, sUrl, sTVPath + sTVFileName, 0, nil);    
      ShellExecute(Handle, 'Open', sTVPath + sTVFileName, nil, nil, 5)
    end; 
    
end;    

procedure frmLogEPSCreate(Sender: TObject);
var 
  iUpdateVersion : Integer;
  sUpdateAt : String; 
begin
  // загрузка настроек формы из реестра
  chkbHideTechMessages.Checked := REGINI.ReadString(KEY, 'HideTechMessages', 'False');

  Height := REGINI.ReadInteger(KEY, 'Height', 740);
  Width := REGINI.ReadInteger(KEY, 'Width', 1024);

  Position := poScreenCenter;
  WindowState := REGINI.ReadInteger(KEY, 'WindowState', 0);                               

  iUpdateVersion := Int (ExecuteFuncScript('INIFILE ("STS", "UpdateVersion", 0)'));
  sUpdateAt := ExecuteFuncScript('INIFILE ("STS", "UpdateAt", "")');
  if iUpdateVersion > 0 then begin
    lblUpdateVersion.Caption := lblUpdateVersion.Caption + 
                                ' #' + IntToStr(iUpdateVersion);
    if length(sUpdateAt) > 0 then  
      lblUpdateVersion.Caption := lblUpdateVersion.Caption  +      
                                  ' от ' + sUpdateAt;
    lblUpdateVersion.Caption := lblUpdateVersion.Caption  + ')';
  end                    
  else
    lblUpdateVersion.Caption := '';
    
  if Height > Screen.Height then Height := Screen.Height;
  if Width > Screen.Width then Width := Screen.Width;
end;                          
                                                     
procedure gridMEDDBTableView1CustomDrawCell(Sender: TcxCustomGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
var
  sEpsLogDocumentID: String;
begin
  
  sEpsLogDocumentID := VarToStr(qryEpsLog.FieldByName('DOCUMENTID').Value);
  if length(sEpsLogDocumentID) = 0 then sEpsLogDocumentID := KRD_MAIN.Fields['DOCUMENTID'].Value;
  
    if not AViewInfo.Selected then
      case VarToStr(AViewInfo.GridRecord.Values[3]) of
        true: 
          if StrPos(sDocumentIDList, sEpsLogDocumentID) = '' then begin
            ACanvas.Canvas.Brush.Color := $efefef;
            ACanvas.Canvas.Font.Color := $696969;
          end
          else begin
            ACanvas.Canvas.Brush.Color := clInfoBk; 
            ACanvas.Canvas.Font.Color := clBlack;
          end
      else                                                        
        if StrPos(sDocumentIDList, sEpsLogDocumentID) = '' then begin
          ACanvas.Canvas.Brush.Color := $dfdfdf;
          ACanvas.Canvas.Font.Color := $696969;
        end
        else begin
          ACanvas.Canvas.Brush.Color := $c1ffc0; 
          ACanvas.Canvas.Font.Color := clBlack;
        end                              
      end;

    if (VarToStr(AViewInfo.GridRecord.Values[7]) = '') and (vartostr(AViewInfo.GridRecord.Values[8]) = '') then begin
      ACanvas.Canvas.Brush.Color :=$c0c0ff;
      ACanvas.Canvas.Font.Color := clBlack;
    end;
      
end;

procedure chkbHideTechMessagesPropertiesChange(Sender: TObject);
begin
  REGINI.WriteString(KEY, 'HideTechMessages', chkbHideTechMessages.Checked); 
  
  if qryMonitor.Active then
    begin
      setMsgIdParameters;  
      qryMonitor.Requery();          
    end;                                                                  
end;

procedure gridEpsLogDBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var 
  header : String;
begin
  if AShift = 73 then 
    begin
      header := VarToStr(qryEpsLog.FieldByName('PLACEID').Value) + ';' + VarToStr(qryEpsLog.FieldByName('ID').Value) + ';' + VarToStr(qryEpsLog.FieldByName('COUNTER').Value);
      InputBox(header,                 
               'ID',                                    
               VarToStr(qryEpsLog.FieldByName('ID').Value));
    end;
end;
                            
procedure gridMEDDBTableView1InitEnvelopeIdPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Clipboard.AsText := qryMonitor.FieldByName('InitEnvelopeId').Value; 
end;

procedure pmCopyDoNumberClick(Sender: TObject);
begin
  Clipboard.AsText := qryEpsLog.FieldByName('DOCNO').Value;
end;                                                         
                                                                   
procedure pmCopyIdClick(Sender: TObject);
begin
  Clipboard.AsText := qryEpsLog.FieldByName('ID').Value;  
end;

procedure pmCopyDocumentIdClick(Sender: TObject);
begin
  Clipboard.AsText := qryEpsLog.FieldByName('DOCUMENTID').Value;    
end;

procedure gridMEDDBTableView1CellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if AButton = mbRight then        
    begin
      pmCopyProcessIdMED.Enabled := qryMonitor.FieldByName('WHPROCESSID').Value <> '';
      pmMonitor.Popup(mouse.CursorPos.X, mouse.CursorPos.Y);    
    end;
end;                                                            

procedure pmCopyDocumentIdMEDClick(Sender: TObject);
begin
  Clipboard.AsText := qryMonitor.FieldByName('WHDOCID').Value;      
end;
                    
procedure pmCopyProcessIdMEDClick(Sender: TObject);                
begin
  Clipboard.AsText := qryMonitor.FieldByName('WHPROCESSID').Value;      
end;

procedure pmCopyEnvelopeIdMEDClick(Sender: TObject);
begin
  Clipboard.AsText := qryMonitor.FieldByName('ENVELOPEID').Value;    
end;

procedure prepareDO1;
var 
  sScript : String;    
  ext : Variant;
begin 
{
  KRD_MAIN.DataSet.Edit;
  KRD_MAIN.FieldByName('MC_STATUS_BD').Value := '';                     
  KRD_MAIN.FieldByName('DOCUMENTID').Value := '';
  KRD_MAIN.FieldByName('ALBUM_VERSION').Value := '';          
  KRD_MAIN.FieldByName('REG_NBD').Value := '';  
  KRD_MAIN.FieldByName('FIO_INSPECTOR').Value := '';       
  KRD_MAIN.FieldByName('POST_INSPECTOR').Value := '';         
  KRD_MAIN.FieldByName('GD1').Value := -700000;             
  KRD_MAIN.FieldByName('GD2').Value := '';         
  KRD_MAIN.DataSet.Post;         
}       
  try
    ext := CreateOleObject('svh.Extention');  
    sScript := 'EXECUTESCRIPT(INCLUDETRAILINGBACKSLASH (PROGRAMPATH ()) + "ProcDocs\write_eps_log.prd");' + 
               'WriteEpsLog(' + VarToStr(KRD_MAIN.FieldByName('PLACEID').Value) + 
               ',' + VarToStr(KRD_MAIN.FieldByName('MAIN_ID').Value) +             
               ', 0' +
               ', "' + KRD_MAIN.FieldByName('DOCUMENTID').Value + '"' +       
               ', "ДО-1"' +
               ', "' + KRD_MAIN.FieldByName('NBD').Value + '"' +
               ', "' + VarToStr(KRD_MAIN.FieldByName('BD_DATE').Value) + '"' +
               ', "ДО-1 подготовлена к переотправке пользователем ' + VarToStr(ext.ComputerName) + ' ' + VarToStr(ext.CurrentUser) + '"' +
               ', FDT ("DD.MM.YYYY HH:NN:SS", (Date () + Time (1)))' +
               ', GENERATEUUID()' +
               ', "Рег. номер= ' + KRD_MAIN.FieldByName('REG_NBD').Value + ' от ' + FormatDateTime('DD.MM.YYYY', KRD_MAIN.FieldByName('GD1').Value) + ' присвоен: ' + KRD_MAIN.FieldByName('FIO_INSPECTOR').Value + ' (' + KRD_MAIN.FieldByName('POST_INSPECTOR').Value + ' | ' + KRD_MAIN.FieldByName('GD2').Value + ')"' +
               ', "eps_showlog"' +                                                                                                                 
               ', "1"' +
               ', FDT ("DD.MM.YYYY HH:NN:SS", (Date () + Time (1)))' + 
               ', 2' +
               ');';                            
    ExecuteFuncScript(sScript);
  finally
    qryEpsLog.Reopen;
  end;

  try
    sScript := 'UPDATE KRD_MAIN SET ' +
            ' STATUS_EPS=' +chr(39)+ 'ДО-1 подготовлена к переотправке' +chr(39)+ ',' +
            ' MC_STATUS_BD=NULL, ' +                                     
            ' ALBUM_VERSION=NULL, ' +
            ' DOCUMENTID=NULL, ' +          
            ' PROCESSID=NULL, ' +          
            ' REG_NBD=NULL, ' +
            ' FIO_INSPECTOR=NULL, ' +
            ' POST_INSPECTOR=NULL, ' +   
            ' GD1=NULL, ' +                            
            ' GD2=NULL ' +   
            ' WHERE ' +
            ' PLACEID=' + VarToStr(KRD_MAIN.FieldByName('PLACEID').Value) +  
            ' AND MAIN_ID=' + VarToStr(KRD_MAIN.FieldByName('MAIN_ID').Value);
    ExecuteFuncScript('EXECUTESQL ("STS_DB", "' + sScript + '")');
  finally
    KRD_MAIN.DataSet.Refresh;
    UpdateDocumentIdList;
    qryMonitor.Refresh;
    
    ExecuteFuncScript ('SHOWMESSAGE ("Отченость ДО-1 подготовлена к переотправке.", 1, "ВЭД-Склад: Лог ЭПС")');
  end;                                      
end;     
                                                   
procedure miResendDO1Click;
var
  userChoise : Integer;
begin
  if KRD_MAIN.FieldByName('MC_STATUS_BD').Value = '3' then
    begin
      if MessageDlg('Вы собираетесь подготовить к переотправке уже ЗАРЕГИСТРИРОВАННЫЙ в таможне отчёт!' +chr(13)++chr(13)+ 'Продолжить выполнение?', mtWarning, mbOKCancel, 0) = mrOk then
        prepareDO1;
    end;
  else
    begin                                                                                                             
      //prepareDO1;
      ExecuteFuncScript ('SHOWMESSAGE ("Подготовка к переотправке не требуется, так как отчетность ДО-1 не зарегистрирована и может быть переотправлена без дополнительных действий.", 1, "ВЭД-Склад: Лог ЭПС")');
    end;

end;

procedure FixHandProtocol(Sender: TObject);
begin                       
  try
    ExecuteFuncScript ('EXECUTESCRIPT (INCLUDETRAILINGBACKSLASH (PROGRAMPATH ()) + "ProcDocs\fix_hand_protocol.prd")');
  finally
    qryEpsLog.Reopen; 
    KRD_MAIN.DataSet.Refresh;      
    UpdateDocumentIdList;
    qryMonitor.Refresh;
  end;
end;


procedure miServiceClick(Sender: TObject);                                                
begin
  miFixHandProtocol.Visible := ExecuteFuncScript('SHIFTPRESSED ()') = 1;   
end;           
                                             
procedure miCancelDOClick(Sender: TObject);
begin             
  frmCancelDO := TCancelDOReport.Create(Application);
  frmCancelDO.ShowModal;
end;                       

function GetStsUpdateFile(sUrl:String): string;
var  sFileName : string;   
begin
  Result := '';                     
  try
    sFileName := IncludeTrailingBackslash(ExecuteFuncScript('TempDirectory ()')) + 'STS_UPDATE_' + ExecuteFuncScript('GENERATEUUID ()') + '.ZIP';
    DeleteUrlCacheEntry(sUrl);
    URLDownloadToFile(nil, sUrl, sFileName, 0, nil);                         
    Result := sFileName;  
  except
    Result := '';                     
  end;
end;       

function GetStsNewsUpdateFile(sUrl:String): string;
var  sFileName : string;   
begin
  Result := '';                     
  try
    sFileName := IncludeTrailingBackslash(ExecuteFuncScript('TempDirectory ()')) + 'STS_UPDATE_NEWS_' + ExecuteFuncScript('GENERATEUUID ()') + '.TXT';
    DeleteUrlCacheEntry(sUrl);
    URLDownloadToFile(nil, sUrl, sFileName, 0, nil);
    Result := sFileName;  
  except
    Result := '';                     
  end;
end;                                        
       
        
procedure mLoadUpdateClick(Sender: TObject);
var sStsUpdateFile, sProgramPath, sScript, sLogText, sFileNews, sUrlNews: String;
    strList: TStringList;
begin
   sScript := 'EXECUTESCRIPT(INCLUDETRAILINGBACKSLASH (PROGRAMPATH ()) + "ProcDocs\writelog.prd");';
   sFileNews := '';
   sStsUpdateFile := '';

   ExecuteFuncScript( sScript + 'WriteLog ("StsExtract","'+ 'Начало загрузки файла.' +'")' );
   sStsUpdateFile :=  GetStsUpdateFile('http://ftp.ctm.ru/INCOMING/STS/SCRIPTSUPDATE/update.zip');    
   ExecuteFuncScript( sScript + 'WriteLog ("StsExtract","'+ sStsUpdateFile +'")');                      
   ExecuteFuncScript( sScript + 'WriteLog ("StsExtract","'+ 'Окончание загрузки файла.' +'")' );
   sProgramPath := IncludeTrailingBackslash(ExecuteFuncScript('PROGRAMPATH ()'));
   if FileExists(sStsUpdateFile) then 
     begin
       try
         strList:= TStringList.Create;
         sFileNews := GetStsNewsUpdateFile('http://ftp.ctm.ru/INCOMING/STS/patchinfo.txt');     
         ExecuteFuncScript( sScript + 'WriteLog ("StsExtract","'+ 'Начало новостей.' +'")' );
         if FileExists(sFileNews) then begin
           strList.LoadFromFile( sFileNews );  
           ExecuteFuncScript( sScript + 'WriteLog ("StsExtract","'+ 'Показ новостей.' +'")' );
           MessageDlg (strList.text, 2,1,0);
           ExecuteFuncScript( sScript + 'WriteLog ("StsExtract","'+ 'Запись новостей в лог.' +'")' );
           ExecuteFuncScript( sScript + 'WriteLog ("StsExtract","'+ ReplaceStr(ReplaceStr(strList.text, '"', ''), '''', '') +'")' );
           DeleteFile(sFileNews);
           ExecuteFuncScript( sScript + 'WriteLog ("StsExtract","'+ 'Удалили файла новостей из темпа.' +'")' );
         end;
      finally                                                             
        strList.Free;
   end; 
        ExecuteFuncScript(sScript + 'WriteLog ("StsExtract","'+ 'Распаковка файлов.' +'")' );
        ExecuteFuncScript('ZipExtractFile ("'+ sStsUpdateFile  +'", "' + sProgramPath + '")');
        ExecuteFuncScript(sScript + 'WriteLog ("StsExtract","'+ 'Удаление файла из временной папки.' +'")' );
//        DeleteFile(sStsUpdateFile);
        MessageDlg ('Обновление файлов завершено.',2,1,0);
     end
   else
     begin 
        ExecuteFuncScript(sScript + 'WriteLog ("StsExtract","'+ 'Не удалось загрузить файл.' +'")' );
        MessageDlg ('Не удалось загрузить файл.',1,2,0);
     end;
end;

procedure JournalFixLayoutClick(Sender: TObject);
var sScriptText:String;
begin
  sScriptText := ' 
FUNC ("ClearLayouts", PARAM ("sLocalLayouts", String, 0), 
     Block(
           VAR ("sTemp", String, "");
           VAR ("sLocalLayoutsListDirectory", String, "");
           sLocalLayoutsListDirectory := GETDIRECTORYLIST(sLocalLayouts, "*", "|");
           VAR ( "iCount", Integer, SPLITSTR (sLocalLayoutsListDirectory, "|", sTemp));
           VAR ( "iI",     Integer, 0);
           iI := 1;
           ClearDirectory (IncludeTrailingBackslash (sLocalLayouts));
           WHILE( iI <= iCount,
                  Block(
                        sTemp := EXTRACTSTR ( sLocalLayoutsListDirectory, iI, "|");
                        ClearDirectory (IncludeTrailingBackslash (sLocalLayouts) + sTemp);
                        iI := iI + 1;
                  )//BLOCK
           );//WHILE
     )//block
);// func ClearLayouts
ClearLayouts( IncludeTrailingBackslash (ProgramPath ()) + "JOURNALS\descr\LAYOUTS\" );
ClearLayouts( INCLUDETRAILINGBACKSLASH (SpecialFolderPath (28)) + "CTM\STS\Layouts\");
showmessage ("Настройка отображения журналов, восстановлена.", 0, "Внимание");
  ';      
  ExecuteFuncScript(sScriptText);  
end;

procedure gridMEDDBTableView1BackupFilePropertiesStartClick(Sender: TObject);
var                         
  sBackupFile, sScript : String;
  iIncoming : Integer;
begin
  sBackupFile := qryMonitor.FieldByName('BACKUPFILE').Value;          
                                     
  if not fileexists (sBackupFile) then
    begin  
      if qryMonitor.FieldByName('INCOMING').Value then
        iIncoming := 1
      else
        iIncoming := 0;
  
      sScript := 'EXECUTESCRIPT (INCLUDETRAILINGBACKSLASH (PROGRAMPATH ()) + "ProcDocs\utils\get_backup_file.prd");' +
                 'VAR ("sBackupFile", String, GetBackupFile ("' + sBackupFile + '", ' +  VarToStr(iIncoming) + '));' +                                                                                                     
                 'IF (FILEEXISTS (sBackupFile), SHELLEXECUTE ("iexplore.exe", sBackupFile, "open", 3));';           
      ExecuteFuncScript(sScript);                  
    end
  else
    begin
      sScript := 'SHELLEXECUTE ("iexplore.exe", "' + sBackupFile + '", "open", 3);';     
      ExecuteFuncScript(sScript);                
    end;                        
end;

procedure miMonitorClick(Sender: TObject);
begin
  if ExecuteFuncScript('SHIFTPRESSED()') = '1' then miHistoryRequest.Enabled := True; 
end;

procedure miEpsImpLogClick(Sender: TObject);
begin                             
  ExecuteFuncScript('SHOWLOGFILE (INCLUDETRAILINGBACKSLASH (PROGRAMPATH ()) + "LOGS\EPSIMP.log", "Лог импорта сообщений из АСТО")');  
end;                      

procedure miMonitorEdClientLogClick(Sender: TObject);
begin                                          
  ExecuteFuncScript('SHOWLOGFILE (INCLUDETRAILINGBACKSLASH (PROGRAMPATH ()) + "STS-MED\log.txt", "Лог передачи сообщений")');
end;

procedure pmRepeatMessageClick(Sender: TObject);
begin
  RepeatDOMessage;
end;

procedure pmMonitorPopup(Sender: TObject);
begin                     
  if (VarToStr(qryMonitor.FieldByName('FMTVERSION').Value) = '') and (VarToStr(qryMonitor.FieldByName('SPECVERSION').Value) = '') or Length (qryMonitor.FieldByName('WHPROCESSID').Value) > 0 then
    pmRepeatMessage.Enabled := True
  else
    pmRepeatMessage.Enabled := False;
end;

procedure gridEpsLogDBTableView1CustomDrawCell(Sender: TcxCustomGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
var
  sStatus: String;
begin               
  // раскрашиваем выделенные записи белым фоном с черным шрифтом
  if AViewInfo.Selected then
  begin
    ACanvas.Canvas.Brush.Color := clWhite;//clWebPowderBlue;//clWebLightCyan;//clWebAliceBlue;//clWebGhostWhite; 
    ACanvas.Canvas.Font.Color := clBlack;
  end;
  
  // записи не привязанные к текущей ДО выделяем серым
  if StrPos(sDocumentIDList, VarToStr(AViewInfo.GridRecord.Values[6])) = '' then 
  begin
      ACanvas.Canvas.Font.Color := $696969;
      ACanvas.Canvas.Brush.Color := $efefef;
  end
  else if pmColoredRows.Checked then
  // записи привязанные к текущей ДО    
  begin                               
    // анализируем текст статуса
    sStatus := VarToStr(AViewInfo.GridRecord.Values[4]);
    sStatus := ExecuteFuncScript('UPPERSTR ("' + sStatus + '")');
    if StrPos(sStatus, 'ЗАРЕГИСТРИРОВАН') <> '' then 
    // записи о регистрации \ принятии
    begin                 
      //ACanvas.Canvas.Font.Color := clWhite; //clGreen;
      //ACanvas.Canvas.Brush.Color := clGreen; //$90EE90; //$F0FFF0     
      ACanvas.Canvas.Font.Style := 1;
      ACanvas.Canvas.Font.Color := clGreen; 
    end
    else if (StrPos(sStatus, 'ОТКАЗ') <> '') or (StrPos(sStatus, 'ОТМЕНЕН') <> '') then 
    // записи об отказе \ отмене
    begin
      //ACanvas.Canvas.Font.Color := clWhite; //clRed;
      //ACanvas.Canvas.Brush.Color := clRed; //$E6F0FA;
      ACanvas.Canvas.Font.Style := 1;
      ACanvas.Canvas.Font.Color := clRed;
    end;
  end;

end;

procedure pmViewCertificateClick(Sender: TObject);
var
  iIncoming : Integer;
  sScript, sBackupFile : String;
begin

  if qryMonitor.FieldByName('INCOMING').Value then
    iIncoming := 1
  else
    iIncoming := 0;
    
  sScript := 'EXECUTESCRIPT (INCLUDETRAILINGBACKSLASH (PROGRAMPATH ()) + "ProcDocs\utils\get_backup_file.prd");' +
             'GetBackupFile ("' + VarToStr(qryMonitor.FieldByName('BACKUPFILE').Value) + '", ' +  VarToStr(iIncoming) + ')';
  sBackupFile := ExecuteFuncScript(sScript);

  if FileExists(sBackupFile) then begin
    sScript := 'EXECUTESCRIPT ("ProcDocs\eps_showlog\view_certificate.prd");ViewCertificate("' + sBackupFile + '");';
    ExecuteFuncScript(sScript);
  end
  else
    ExecuteFuncScript('SHOWMESSAGE ("Не найден файл резервной копии", 2, "ВЭД-Склад: Лог ЭПС")');
    
end;

procedure frmLogEPSResize(Sender: TObject);
begin
  gridEpsLog.Height := ClientHeight / 2;
end;
                 
procedure miUserMsgsClick(Sender: TObject);
begin
//  miUserMsgs.Checked := not miUserMsgs.Checked;
end;

procedure miUserAndTechMsgsClick(Sender: TObject);
begin                                                                      
//  miUserAndTechMsgs.Checked := not miUserAndTechMsgs.Checked;
end;

procedure miAllMsgsClick(Sender: TObject);
begin
//  miAllMsgs.Checked := not miAllMsgs.Checked;
end;                                                             

procedure changeEpsLogFilter(Sender: TObject);
begin
  if pmUserMsgs.Checked then begin
    qryEpsLog.Params[4].Value := 0;
    REGINI.WriteInteger(KEY, 'View', 0);
  end 
  else if pmUserAndTechMsgs.Checked then begin
    qryEpsLog.Params[4].Value := 1;
    REGINI.WriteInteger(KEY, 'View', 1);
  end
  else if pmAllMsgs.Checked then begin
    qryEpsLog.Params[4].Value := 2;
    REGINI.WriteInteger(KEY, 'View', 2);
  end; 
  qryEpsLog.Active := True;
  qryEpsLog.Reopen;
{
  if qryEpsLog.RecordCount = 0 then
  begin
    sDocumentIDList := KRD_MAIN.FieldByName('DOCUMENTID').Value;
    qryMonitor.Parameters[0].Value := KRD_MAIN.FieldByName('PLACEID').Value;
    qryMonitor.Parameters[1].Value := KRD_MAIN.FieldByName('DOCUMENTID').Value;
    qryMonitor.Parameters[2].Value := 0;
    qryMonitor.Active := true;
  end
  else
    qryEpsLog.Last;
}
end;

procedure qryEpsLogAfterRefresh(DataSet: TDataSet);
begin
  if qryEpsLog.RecordCount > 0 then 
  begin
    if not qryEpsLog.Eof then qryEpsLog.Last;
    if not qryMonitor.Active then qryMonitor.Active := true;
    qryMonitor.Refresh;
  end;
end;

procedure qryEpsLogAfterOpen(DataSet: TDataSet);
begin 
  if qryEpsLog.RecordCount > 0 then 
  begin
    if not qryEpsLog.Eof then qryEpsLog.Last;
    if not qryMonitor.Active then qryMonitor.Active := true;  
    qryMonitor.Refresh;
  end;
end;                                                                                          

procedure pmColoredRowsClick(Sender: TObject);
begin
  qryEpsLog.Refresh;
  REGINI.WriteBool(KEY, 'ColoredRows', pmColoredRows.Checked);
end;

procedure qryMonitorAfterRefresh(DataSet: TDataSet);
begin
{   
  if qryEpsLog.RecordCount = 0 then
  begin
    sDocumentIDList := KRD_MAIN.FieldByName('DOCUMENTID').Value;
    qryMonitor.Parameters[0].Value := KRD_MAIN.FieldByName('PLACEID').Value;
    qryMonitor.Parameters[1].Value := KRD_MAIN.FieldByName('DOCUMENTID').Value;
    qryMonitor.Parameters[2].Value := 0;
  end
  else
  begin
    qryMonitor.Parameters[0].Value := qryEpsLog.FieldByName('PLACEID').Value;
    qryMonitor.Parameters[1].Value := qryEpsLog.FieldByName('DOCUMENTID').Value;
    qryMonitor.Parameters[2].Value := qryEpsLog.FieldByName('COUNTER').Value;
  end;
  if not qryMonitor.Active then qryMonitor.Active := true;
}
end;

procedure qryMonitorAfterOpen(DataSet: TDataSet);
begin

  if qryEpsLog.RecordCount = 0 then
  begin
    sDocumentIDList := KRD_MAIN.FieldByName('DOCUMENTID').Value;
    qryMonitor.Parameters[0].Value := KRD_MAIN.FieldByName('PLACEID').Value;
    qryMonitor.Parameters[1].Value := KRD_MAIN.FieldByName('DOCUMENTID').Value;
    qryMonitor.Parameters[2].Value := 0;
  end
  else
  begin
    qryMonitor.Parameters[0].Value := qryEpsLog.FieldByName('PLACEID').Value;
    qryMonitor.Parameters[1].Value := qryEpsLog.FieldByName('DOCUMENTID').Value;
    qryMonitor.Parameters[2].Value := qryEpsLog.FieldByName('COUNTER').Value;
  end;
  if not qryMonitor.Active then qryMonitor.Active := true;
 
end;

begin
end;                                    
