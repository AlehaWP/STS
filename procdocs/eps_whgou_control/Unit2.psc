{$FORM TMainForm, Unit2.sfm}                                                                                                                                               
                                                      
uses
  Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, DateUtils, 
  ExtCtrls, UniDB, DB, ADODB, Registry, FuncScript, SysUtils, 
  Grids, DBGrids, DBTables, DBClient;    
                                                   
const
  REGINI = TRegIniFile.Create('Software\CTM\');
  MED_KEY = 'MONITORED\MAIN\Db'; 

var 
  dtMonth, dtWeek, dtToday, dtNow : TDateTime;  
  cds : TClientDataset;
        
procedure btnCloseClick(Sender: TObject);
begin
  Close;
end;

// первый день месяца   
function FDOM(Date: TDateTime): TDateTime;
var 
  Year, Month, Day : Word;
begin
  DecodeDate(Date, Year, Month, Day);
  Result := EncodeDate(Year, Month, 1);
end;                                                         
                             
// первый день недели
function FDOW(Date: TDateTime): TDateTime;
begin                                     
  Result := Date - DayOfTheWeek(Date) + 1;                           
end;                                                               

function GetMedCount(date : TDateTime): Integer;
begin                                           
  if not qMed.Active then qMed.Active := True;
  qMed.Parameters.ParamByName('dtFrom').Value := FormatDateTime('yyyy-mm-dd', date);        
  qMed.Requery;   
  Result := qMed.FieldByName('C').Value;
end;    
                          
function GetJourCount(date : TDateTime): Integer;
begin
  if not qJour.Active then qJour.Active := True;
  qJour.Params.ParamByName('dtFrom').Value := date;  
  qJour.Reopen;   
  Result := qJour.FieldByName('C').Value;                  
end;
                                                        
procedure UpdateTable;
begin
  cds.EmptyDataSet;    
                    
  cds.Append;                                                   
  cds.FieldByName('descr').AsString := 'С начала месяца';
  cds.FieldByName('med').AsInteger := GetMedCount(dtMonth);
  cds.FieldByName('jour').AsInteger := GetJourCount(dtMonth);            
  cds.Append;                                        
  cds.FieldByName('descr').AsString := 'С начала недели';
  cds.FieldByName('med').AsInteger := GetMedCount(dtWeek);             
  cds.FieldByName('jour').AsInteger := GetJourCount(dtWeek);    
  cds.Append;       
  cds.FieldByName('descr').AsString := 'За сегодня';
  cds.FieldByName('med').AsInteger := GetMedCount(dtToday);             
  cds.FieldByName('jour').AsInteger := GetJourCount(dtToday);
  cds.Post;                                                                                      
end;                                  
                                                     
procedure MainForm_1Create(Sender: TObject);   
var                                                                                
  sSQLKey : String;
begin                
  Width := 600;
  Height := 300;
  
  dtMonth := FDOM(Date);
  dtWeek := FDOW(Date);
  dtToday := Date;         
  dtNow := Now;        
  
  Case ExecuteFuncScript('GetDatabaseType("dbJournals");') of
    'MSSQL': begin  
      qJour.SQL.Clear;
      qJour.SQL.Add('SELECT COUNT(*) AS C');
      qJour.SQL.Add('FROM JRGOODOUT2');      
      qJour.SQL.Add('WHERE');      
      qJour.SQL.Add('SENDDATE + ' +chr(39)+ ' ' +chr(39)+ ' + SENDTIME >= :dtFrom');      
      qJour.Params.ParamByName('dtFrom').DataType := 11;
      qJour.Active := true;
    end;
    'PARADOX': begin
    end;
  end;

  Case REGINI.ReadInteger(MED_KEY, 'ArcType', 0) of
    1 : begin
      if REGINI.ReadString(MED_KEY, 'ArcDir', '') <> '' then
        begin
          if connMed.Connected then connMed.Connected := False;
          connMed.Provider := 'Microsoft.Jet.OLEDB.4.0';
          connMed.LoginPrompt := False;
          connMed.Mode := cmRead;
          connMed.ConnectionString := 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source='+ REGINI.ReadString(MED_KEY, 'ArcDir', '') +'MONITORED.MDB;Persist Security Info=False';  
          if not connMed.Connected then connMed.Connected := True;
          
          if qMed.Active then qMed.Active := false;
          qMed.Connection := connMed;                                          
                                         
          if not qMed.Active then qMed.Active := True;   
       end;
    end;                                                
    2 : begin 
      if REGINI.ReadString(MED_KEY + '\SQLServer', 'DBName', '') <> '' then
        begin   
          sSQLKey := MED_KEY + '\SQLServer';
          if connMed.Connected then connMed.Connected := False;
          connMed.Provider := 'SQLOLEDB.1';
          connMed.LoginPrompt := False;
          connMed.Mode := cmRead;                                                                           
          connMed.ConnectionString := 'Provider=SQLOLEDB.1;Data Source=' + REGINI.ReadString(sSQLKey, 'ServerName', '') + ';Initial Catalog=' + REGINI.ReadString(sSQLKey, 'DBName', '') + ';';   
          if REGINI.ReadString(sSQLKey, 'IntegratedSecurity', '') = '1' then   
            connMed.ConnectionString := connMed.ConnectionString + 'Integrated Security=SSPI;'
          else if REGINI.ReadString(sSQLKey, 'IntegratedSecurity', '') <> '' then                                      
            connMed.ConnectionString := connMed.ConnectionString + 'User Id=' + REGINI.ReadString(sSQLKey, 'Login', '') + ';Password=' + REGINI.ReadString(sSQLKey, 'Password', '') + ';';
          if not connMed.Connected then connMed.Connected := True;
          
          if qMed.Active then qMed.Active := False;
          qMed.Connection := connMed;
                     
          if not qMed.Active then qMed.Active := True;          
        end;            
    end;
  end;  // Case 
 
  cds := TClientDataSet.Create(Self);                         
  cds.FieldDefs.Add('descr', ftString, 30, True);
  cds.FieldDefs.Add('med', ftInteger, 0, True);
  cds.FieldDefs.Add('jour', ftInteger, 0, True); 
  cds.CreateDataSet;
                              
  dsMain.DataSet := cds;
  gdMain.DataSource := dsMain;                                   
  
  gdMain.Columns.Items[0].Title.Font.Style := [fsBold];       
  gdMain.Columns.Items[0].Title.Caption := 'Период';   
  gdMain.Columns.Items[0].Title.Alignment := 2;
  gdMain.Columns.Items[0].Width := 220;
  gdMain.Columns.Items[1].Title.Font.Style := [fsBold];       
  gdMain.Columns.Items[1].Title.Caption := 'Получено в Монитор ЭД';  
  gdMain.Columns.Items[1].Title.Alignment := 2;  
  gdMain.Columns.Items[1].Alignment := 2;      
  gdMain.Columns.Items[1].Width := 170;  
  gdMain.Columns.Items[2].Title.Font.Style := [fsBold];         
  gdMain.Columns.Items[2].Title.Caption := 'Загружено в Журнал';  
  gdMain.Columns.Items[2].Title.Alignment := 2;
  gdMain.Columns.Items[2].Alignment := 2; 
  gdMain.Columns.Items[2].Width := 170;  
             
  UpdateTable; 
  
  btnReloadWhgou.Enabled := dsMain.DataSet.FieldByName('med').Value > dsMain.DataSet.FieldByName('jour').Value;
end;                             

procedure SaveXmlDocument(sFile: String);
var         
  sDir : String;  
begin
  sDir := ExtractFilePath(Application.ExeName) + 'STS-MED\iout\';
  if Length (ExecuteFuncScript ('UserInfo("", "UserUUID")')) > 0 then
    sDir := sDir + ExecuteFuncScript ('UserInfo("", "UserUUID")') + '\';
{    
  ExecuteFuncScript(
    'VAR ("XmlDoc", Integer);' +                 
    'VAR ("XmlObject", Integer);' +
    'VAR ("XmlBody", Integer);' +
    'XmlDoc := XMLDOCUMENTCREATE();' +
    'XMLDOCUMENTLOAD (XmlDoc, "' + sFile + '");' +
    'XmlObject := XMLNODEFIND (XMLNODEFIND (XMLNODEFIND (XMLNODEFIND (XMLDOCUMENTROOT (XmlDoc), 0), "Body"), "Signature"), "Object");' +
    'IF (XMLNODEFIND (XmlObject, "ED_Container"), XmlObject := XMLNODEFIND (XMLNODEFIND (XMLNODEFIND (XMLNODEFIND (XMLNODEFIND (XmlObject, "ED_Container"), "ContainerDoc"), "DocBody"), "Signature"), "Object"));' +
    'XmlBody := XMLNODECHILD (XmlObject, 0);' +
    'XMLNODESAVE (XmlBody, "' + sDir + ExtractFileName(sFile) + '");'       
  );    
}     

  ExecuteFuncScript (
    'VAR("XmlDoc", Integer);' +
    'VAR ("XmlObject", Integer);' +
    'VAR ("XmlBody", Integer);' +
    'XmlDoc := XMLDOCUMENTCREATE();' +
    'XMLDOCUMENTLOAD (XmlDoc, "' + sFile + '");' +
    'XmlObject := XMLNODEFIND (XMLNODEFIND (XMLNODEFIND (XMLNODECHILD (XMLDOCUMENTROOT (XmlDoc), 0), "Body"), "Signature"), "Object");' +             
    'IF (XMLNODEFIND (XmlObject, "ED_Container"), XmlObject := XMLNODEFIND (XMLNODEFIND (XMLNODEFIND (XMLNODEFIND (XMLNODEFIND (XmlObject, "ED_Container"), "ContainerDoc"), "DocBody"), "Signature"), "Object"));' +
    'XmlBody := XMLNODECHILD (XmlObject, 0);XMLNODESAVE (XmlBody, "' + sDir + ExtractFileName(sFile) + '");'   
  ); // ExecuteFuncScripts

end;                                                          

procedure ReloadWHGou;                  
var 
  iMissedFiles, iIncoming : Integer;
  sMsg, sScript, sBackupFile : String;   
begin         
  iMissedFiles := 0;
  qBackups.First;            
  while not qBackups.Eof do
    begin                                                           
      if qBackups.FieldByName('INCOMING').Value then
        iIncoming := 1
      else
        iIncoming := 0;   
        
      sScript := 'EXECUTESCRIPT (INCLUDETRAILINGBACKSLASH (PROGRAMPATH ()) + "ProcDocs\utils\get_backup_file.prd");' +
                 'GetBackupFile ("' + VarToStr(qBackups.FieldByName('BACKUPFILE').Value) + '", ' +  VarToStr(iIncoming) + ')';           
      sBackupFile := ExecuteFuncScript(sScript);     
      if FileExists(sBackupFile) then      
        SaveXmlDocument(sBackupFile);  
      else 
        iMissedFiles := iMissedFiles + 1;
        
      qBackups.Next; 
    end;
  ExecuteFuncScript('VAR ("iShowProgressBar", Integer, 1);' +  
                    'EXECUTESCRIPT (INCLUDETRAILINGBACKSLASH (PROGRAMPATH ()) + "Data\Impex\Scripts\eps.imp");');

  if iMissedFiles > 0 then 
    begin
      sMsg := 'Обработка завершена.'; 
      sMsg := sMsg + chr(13) + 'Не найдены резервные копии для ' + IntToStr(iMissedFiles) + ' Уведомления(-ий).';
      MessageDlg(sMsg, mtInformation, mbOK, 0);  
    end;
end;                                                           
                               
procedure gdMainCellClick(Column: TColumn);                     
begin
  btnReloadWhgou.Enabled := dsMain.DataSet.FieldByName('med').Value > dsMain.DataSet.FieldByName('jour').Value;
end;

procedure btnReloadWhgouClick(Sender: TObject);
begin
  if not qBackups.Active then qBackups.Active := True;  
  qBackups.Parameters.ParamByName('dtFrom').DataType := 9; 
  Case dsMain.DataSet.FieldByName('descr').Value of
    'С начала месяца':  begin   
      qBackups.Parameters.ParamByName('dtFrom').Value := FormatDateTime('yyyy-mm-dd', dtMonth); 
    end;                                                
    'С начала недели':  begin   
      qBackups.Parameters.ParamByName('dtFrom').Value := FormatDateTime('yyyy-mm-dd', dtWeek);    
    end;
    'За сегодня': begin  
      qBackups.Parameters.ParamByName('dtFrom').Value := FormatDateTime('yyyy-mm-dd', dtToday);    
    end;                                                   
  end;    
  if qBackups.Active then qBackups.Requery else qBackups.Active := True;    
                                        
  ReloadWHGou;                            
  UpdateTable;  
end;

begin                                                        
end;                                            
