{$FORM TMainForm, Unit2.sfm}                                                                      

uses
  Classes, Graphics, Controls, Forms, Dialogs, cxGrid, 
  cxGridBandedTableView, cxGridCustomTableView, 
  cxGridCustomView, cxGridDBBandedTableView, cxGridLevel, 
  UniDB, Menus,
  FuncScript;

procedure Form2Activate(Sender: TObject);
begin
  qEpsLog.Active := True;
  pmiAutoHeight.Checked := ExecuteFuncScript('IniFile ("EPS_SHOW_NOTIFICATION", "GridAutoWidth", "True")');
  cxGrid1DBTableView1.OptionsView.ColumnAutoWidth := pmiAutoHeight.Checked;  
end;

procedure ClearList;                      
var
  sScriptText : String;
begin
  sScriptText := 'EXECUTESQL ("dbJournals", "UPDATE EPS_LOG SET READED=' +chr(39)+ '1' +chr(39)+ 
                                      ' WHERE READED=' +chr(39)+ '0' +chr(39)+ '");' +
                 'SETSTATUSBARHINT (' +chr(39)+chr(39)+ ', ' +chr(39)+chr(39)+ ', ' +chr(39)+chr(39)+ ', ' +chr(39)+chr(39)+ ');'                                     
  ExecuteFuncScript(sScriptText);                               
  Close;
end;

procedure cxButton1Click(Sender: TObject);
begin                                  
  if ExecuteFuncScript('YESNO ("Отметить все сообщения как прочитанные?");') = 1 then
    ClearList;
  Close;                                  
end;

procedure cxButton3Click(Sender: TObject);
begin               
  ClearList; 
end;

procedure pmiClearListClick(Sender: TObject);
begin
  ClearList;
end;

procedure pmiAutoHeightClick(Sender: TObject);
begin                                            
  pmiAutoHeight.Checked := not pmiAutoHeight.Checked;
  cxGrid1DBTableView1.OptionsView.ColumnAutoWidth := pmiAutoHeight.Checked;      
  ExecuteFuncScript ('WriteIniFile ("EPS_SHOW_NOTIFICATION", "GridAutoWidth", "' + VarToStr(cxGrid1DBTableView1.OptionsView.ColumnAutoWidth) + '");');
end;                                                                                                                                              
              
procedure cxButton2Click(Sender: TObject);
var 
  sScriptText : String;
begin         
   IF qEpsLog.FieldByName('DOCTYPE').Value = 'ДО-3' then
     begin
     
     end     
   else
     begin
       sScriptText := 'LOCATE ("KRD_MAIN", "PLACEID;ID", [' + VarToStr(qEpsLog.FieldByName('PLACEID').Value) + ',' + VarToStr(qEpsLog.FieldByName('ID').Value) + ']);';
       IF qEpsLog.FieldByName('COUNTER').Value > 0 then
         sScriptText := sScriptText + 'LOCATE ("REL_MAIN", "PLACEID;ID;COUNTER", [' + VarToStr(qEpsLog.FieldByName('PLACEID').Value) + ',' + VarToStr(qEpsLog.FieldByName('ID').Value) + ',' + VarToStr(qEpsLog.FieldByName('COUNTER').Value) + ']);';
     end;
   ExecuteFuncScript(sScriptText);   
   Close;
end;

procedure cxGrid1DBTableView1FocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
begin                                                                                                        
  if (qEpsLog.FieldByName('DOCTYPE').Value = 'ДО-1') or (qEpsLog.FieldByName('DOCTYPE').Value = 'ДО-2') then
    begin
      btnGotoDocument.Enabled := true;
    end
  else
    begin
      btnGotoDocument.Enabled := false;       
    end;
end;                                                           

procedure MainForm_1Create(Sender: TObject);
begin

  if Height > Screen.Height then Height := Screen.Height;
  if Width > Screen.Width then Width := Screen.Width;    
                              
  WindowState := wsMaximized;                           
end;

begin       
end;                 
