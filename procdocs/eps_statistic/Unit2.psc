{$FORM TForm1, Unit2.sfm}                                                                                                         

uses
  Classes, Graphics, Controls, Forms, Dialogs, cxGrid, 
  cxGridBandedTableView, cxGridCustomTableView, 
  cxGridCustomView, cxGridDBBandedTableView, cxGridLevel, DB, 
  DBTables, UniDB, ExtCtrls, FuncScript, SysUtils, Menus,
  ClipBrd, Registry;

const
  REGINI = TRegIniFile.Create('Software\CTM\');
  KEY = 'STS\PROCDOCS\EPS_STATISTIC';
 
var 
  iTimerTickCount : Integer;
  sScript, sListId : String;         
  sKey : String;
                              
procedure UpdateEpsStatistic;
begin
  if Timer1.Enabled = True then begin
    sScript := 'EXECUTESCRIPT (INCLUDETRAILINGBACKSLASH (PROGRAMPATH()) + "PROCDOCS\eps_statistic\eps_statistic.prd");' +
               'sGUID :="' + sListId + '";' +
               'RefreshEpsStatistic();';
    sListId := ExecuteFuncScript(sScript);
    qEpsStatistic.Params['list_id'].Value := sListId;
    qEpsStatistic.Refresh;                       
    if qEpsStatistic.RecordCount > 0 then begin
      btnShowProtocol.Enabled := True;
      btnGotoDocument.Enabled := True;  
    end
    else begin
      btnShowProtocol.Enabled := False;          
      btnGotoDocument.Enabled := False;  
    end;                                                                                           
  end;                                                                   
end;                                        
                             
procedure btnCloseClick(Sender: TObject);           
begin
  Close;                                                  
end;                                                                         

procedure FormCreate(Sender: TObject);
var                    
  sUserUUID : String;
begin                
  if Height > Screen.Height then Height := Screen.Height;
  if Width > Screen.Width then Width := Screen.Width;
  WindowState := wsMaximized;
  
  Timer1.Enabled := False;
  sUserUUID := ExecuteFuncScript ('USERINFO("","USERUUID")');
  if length(sUserUUID) > 0 then                  
    sKey := KEY + '_' + sUserUUID
  else                   
    sKey := KEY;
    
  cbxNew.Checked := REGINI.ReadBool(sKey, 'New', False);
  cbx2Hours.Checked := REGINI.ReadBool(sKey, '2Hours', True);
  cbx24Hours.Checked := REGINI.ReadBool(sKey, '24Hours', True);
  cbxForRegistration.Checked := REGINI.ReadBool(sKey, 'ForRegistration', False);
  
  teClock.EditValue := Time(); 
  sListId := ExecuteFuncScript('GENERATEUUID (1);');  
  qEpsStatistic.Active := True;  
  Timer1.Enabled := True;
  UpdateEpsStatistic;   
end;                    
                   
procedure cxGrid1DBTableView1CustomDrawCell(Sender: TcxCustomGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
begin
  if AViewInfo.Item.Index = 6 then begin
    case TRIM (AViewInfo.GridRecord.DisplayTexts[6]) of
      'Недавно подан' : begin            
        ACanvas.Brush.Color := $BAF8B7;
        ACanvas.Canvas.Font.Color := clBlack;      
      end;
      'Превышен срок 2 часа' : begin  
        ACanvas.Brush.Color := $C6FFF8;
        ACanvas.Canvas.Font.Color := clBlack;
      end;              
      'Превышен срок 24 часа' : begin
        ACanvas.Brush.Color := $BBBBFF;
        ACanvas.Canvas.Font.Color := clBlack;
      end;
      'Для регистрации' : begin
        ACanvas.Brush.Color := $FAD3C0;
        ACanvas.Canvas.Font.Color := clBlack;
      end;
    end; // case   
  end; // if                          
end;                           
                                                      
procedure Timer1Timer(Sender: TObject);         
begin
  teClock.EditValue := Time();                             
  Inc(iTimerTickCount);                        
  if iTimerTickCount > 60 then begin            
     iTimerTickCount :=  1;  
     // обновляем таблицу
     UpdateEpsStatistic;
  end                         
end;               

procedure GotoDocument;
begin
  if (1 = ExecuteFuncScript('LOCATE ("KRD_MAIN", "PLACEID;MAIN_ID", [' + VarToStr(qEpsStatistic.Fields['PLACEID'].Value) + ', ' + VarToStr(qEpsStatistic.Fields['MAIN_ID'].Value) + '])')) then
    begin
      if qEpsStatistic.Fields['DO_TYPE'].Value = 'ДО-2' then
        if ExecuteFuncScript('LOCATE ("RELEASE", "PLACEID;MAIN_ID;MAIN_COUNTER", [' + VarToStr(qEpsStatistic.Fields['PLACEID'].Value) + ', ' + VarToStr(qEpsStatistic.Fields['MAIN_ID'].Value) + ', ' + VarToStr(qEpsStatistic.Fields['MAIN_COUNTER'].Value) + '])') = '0' then
          MessageDlg('Документ не найден. Снимите фильтры и попробуйте снова.', mtInformation, mbYes, 0);  
        else
          Close;
      else                         
        Close;
    end                                                                                                             
  else
    MessageDlg('Документ не найден. Снимите фильтры и попробуйте снова.', mtInformation, mbYes, 0);
end;
                   
procedure btnGotoDocumentClick(Sender: TObject);
begin   
  GotoDocument;  
end; 

procedure Form1Close(Sender: TObject; var Action: TCloseAction);
begin
  Timer1.Enabled := False;
  sScript := 'ExecuteScript(INCLUDETRAILINGBACKSLASH (PROGRAMPATH ()) + "PROCDOCS\eps_statistic\eps_statistic.prd");' +
             'ClearEpsStatistic("' + sListId + '")';
  ExecuteFuncScript(sScript);
                            
  REGINI.WriteBool(sKey, 'New', cbxNew.Checked);
  REGINI.WriteBool(sKey, 'ForRegistration', cbxForRegistration.Checked);
  REGINI.WriteBool(sKey, '2Hours', cbx2Hours.Checked); 
  REGINI.WriteBool(sKey, '24Hours', cbx24Hours.Checked); 
end;

procedure ShowProtocol;
var
  sDoType, sPlaceId, sDocumentId, sMainCounter, sType, sUserUUID, sFileName : String;
  xmlStringList : TStringList;
begin
  sDoType := VarToStr(qEpsStatistic.Fields['DO_TYPE'].Value);
  sPlaceId := VarToStr(qEpsStatistic.Fields['PLACEID'].Value);
  sDocumentId := VarToStr(qEpsStatistic.Fields['DOCUMENTID'].Value);
  sMainCounter := VarToStr(qEpsStatistic.Fields['MAIN_COUNTER'].Value);
  
  if sDoType = 'ДО-1' then sType := '1_' else sType := '2_';
  sUserUUID := ExecuteFuncScript('USERINFO ("", "UserUUID")');
  if length(sUserUUID) > 0 then
    sFileName := 'STS-MED\iin\' + sUserUUID + '\SHOWLOGDO' + sType + sPlaceId + '_' + sDocumentId + '_' + sMainCounter + '.xml'
  else
    sFileName := 'STS-MED\iin\SHOWLOGDO' + sType + sPlaceId + '_' + sDocumentId + '_' + sMainCounter + '.xml';
                         
  xmlStringList := TStringList.Create;
  xmlStringList.Add('<?xml version="1.0" encoding="windows-1251"?>');
  xmlStringList.Add('<ShowLog>Просмотр протокола ДО</ShowLog>');
  xmlStringList.SaveToFile(ExtractFilePath(Application.ExeName) + sFileName);
end;

procedure btnShowProtocolClick(Sender: TObject);
begin
  ShowProtocol;  
end;

procedure pmShowProtocolClick(Sender: TObject);
begin     
  ShowProtocol;
end;

procedure pmGotoDocumentClick(Sender: TObject);
begin
  GotoDocument;  
end; 

procedure pmCopyDoNoClick(Sender: TObject);
begin
  Clipboard.AsText := qEpsStatistic.Fields['DO_NO'].Value;
end;

procedure pmCopyIdClick(Sender: TObject);
begin
  Clipboard.AsText := qEpsStatistic.Fields['MAIN_ID'].Value;  
end;

procedure pmCopyDocumentIdClick(Sender: TObject);
begin
  Clipboard.AsText := qEpsStatistic.Fields['DOCUMENTID'].Value;
end;

procedure pmRefreshClick(Sender: TObject);
begin
  UpdateEpsStatistic;        
end;

procedure cxGrid1DBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  GotoDocument;
end; 
   
procedure btnRefreshClick(Sender: TObject);
begin
  UpdateEpsStatistic;
end;

procedure cbxNewPropertiesEditValueChanged(Sender: TObject);
begin
  if not cbxForRegistration.Checked and not cbx2Hours.Checked and not cbx24Hours.Checked then begin
    cbxNew.Checked := True;
  end
  else begin
    REGINI.WriteBool(sKey, 'New', cbxNew.Checked);
    UpdateEpsStatistic;       
  end;   
end;        
     
procedure cbx2HoursPropertiesEditValueChanged(Sender: TObject);
begin
  if not cbxNew.Checked and not cbxForRegistration.Checked and not cbx24Hours.Checked then begin
    cbx2Hours.Checked := True;
  end
  else begin         
    REGINI.WriteBool(sKey, '2Hours', cbx2Hours.Checked);
    UpdateEpsStatistic;
  end;                 
end;

procedure cbx24HoursPropertiesEditValueChanged(Sender: TObject);
begin
  if not cbxNew.Checked and not cbxForRegistration.Checked and not cbx2Hours.Checked then begin
    cbx24Hours.Checked := True;
  end
  else begin
    REGINI.WriteBool(sKey, '24Hours', cbx24Hours.Checked);
    UpdateEpsStatistic;   
  end;   
end;

procedure cbxForRegistrationPropertiesEditValueChanged(Sender: TObject);
begin
  if not cbxNew.Checked and not cbx2Hours.Checked and not cbx24Hours.Checked then begin
    cbxForRegistration.Checked := True;
  end
  else begin
    REGINI.WriteBool(sKey, 'ForRegistration', cbxForRegistration.Checked);
    UpdateEpsStatistic;
  end;  
end;

procedure PopupMenuPopup(Sender: TObject);
begin
  pmPrepareToResend.Enabled := TRIM(qEpsStatistic.Fields['STAGE'].Value) <> 'Для регистрации';
end;

procedure pmPrepareToResendClick(Sender: TObject);
var 
  sScript : String;
  ext : Variant;
begin
  if MessageDlg('Вы уверены, что хотите подготовить ДО к переотправке?', mtWarning, mbOKCancel, 0) = mrOK then begin                                                 
    // подготовить к переотправке         
    case TRIM(qEpsStatistic.Fields['DO_TYPE'].Value) of
      'ДО-1' : begin           
        sScript := 'UPDATE KRD_MAIN SET' +
                   ' STATUS_EPS=' +chr(39)+ 'ДО-1 подготовлена к переотправке' +chr(39)+ 
                   ',MC_STATUS_BD=NULL' +
                   ',ALBUM_VERSION=NULL' +
                   ',DOCUMENTID=NULL' +
                   ',PROCESSID=NULL' +
                   ',REG_NBD=NULL' +
                   ',FIO_INSPECTOR=NULL' +
                   ',POST_INSPECTOR=NULL' +
                   ',GD1=NULL' +
                   ',GD2=NULL' +                                                             
                   ' WHERE' +
                   ' PLACEID=' + VarToStr(qEpsStatistic.Fields['PLACEID'].Value) +
                   ' AND MAIN_ID=' + VarToStr(qEpsStatistic.Fields['MAIN_ID'].Value);
        //showmessage (sScript);                   
        ExecuteFuncScript('EXECUTESQL ("STS_DB", "' + sScript + '")');
      end;
      'ДО-2' : begin            
        sScript := 'VAR ("sSQL", String, "");' +
                   'sSQL := "UPDATE " + CORRECTTABLENAME ("RELEASE") + " SET" +' +
                   '" MC_STATUS=NULL" +' +
                   '",DOCUMENTID=NULL" +' +  
                   '" WHERE" +' +  
                   '" PLACEID=' + VarToStr(qEpsStatistic.Fields['PLACEID'].Value) + '" +'  +
                   '" AND MAIN_ID=' + VarToStr(qEpsStatistic.Fields['MAIN_ID'].Value) + '" +'  +
                   '" AND MAIN_COUNTER=' +VarToStr(qEpsStatistic.Fields['MAIN_COUNTER'].Value) + '";' +
                   'EXECUTESQL ("STS_DB", sSQL);' +
                   'sSQL := "UPDATE KRD_MAIN SET" +' +
                   '" STATUS_EPS=' +chr(39)+ 'ДО-2 №' + qEpsStatistic.Fields['DO_NO'].Value + ' подготовлена к переотправке' +chr(39)+ '" +' +
                   '" WHERE"' +
                   '" PLACEID=' + VarToStr(qEpsStatistic.Fields['PLACEID'].Value) +
                   ' AND MAIN_ID=' + VarToStr(qEpsStatistic.Fields['MAIN_ID'].Value) + '";' +
                   'EXECUTESQL ("STS_DB", sSQL);';       
        //showmessage (sScript);
        ExecuteFuncScript(sScript);
      end; 
    end; // CASE  
    
    ext := CreateOleObject ('svh.Extention');
    sScript := 'EXECUTESCRIPT (INCLUDETRAILINGBACKSLASH (PROGRAMPATH()) + "PROCDOCS\write_eps_log.prd");' +
               'WriteEpsLog(' + 
               VarToStr(qEpsStatistic.Fields['PLACEID'].Value) +
               ',' + VarToStr(qEpsStatistic.Fields['MAIN_ID'].Value) +      
               ',' + VarToStr(qEpsStatistic.Fields['MAIN_COUNTER'].Value) +
               ',"' + qEpsStatistic.Fields['DOCUMENTID'].Value + '"' +
               ',"' + qEpsStatistic.Fields['DO_TYPE'].Value +  '"' +               
               ',"' + VarToStr(qEpsStatistic.Fields['DO_NO'].Value) + '"' +
               ',"' + VarToStr(qEpsStatistic.Fields['DO_DATE'].Value) + '"' +
               ',"' + qEpsStatistic.Fields['DO_TYPE'].Value + ' подготовлена к переотправке пользователем ' + VarToStr(ext.ComputerName) + ' ' + VarToStr(ext.CurrentUser) + '"' +
               ',Date()+Time(1)' +
               ',GENERATEUUID()' + 
               ',""' +
               ',"eps_statistic"' +    
               ', "1"' +
               ', Date()+Time(1)' +
               ', 2' + 
               ');';
    ExecuteFuncScript(sScript);    
    
    UpdateEpsStatistic;
  end; // if  
end;

begin
                   
end;        
