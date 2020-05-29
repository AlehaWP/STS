{$FORM TMainDialog, Unit2.sfm}                                                                                                             

uses
  Classes, Graphics, Controls, Forms, Dialogs, cxGrid, 
  cxGridBandedTableView, cxGridCustomTableView, 
  cxGridCustomView, cxGridDBBandedTableView, cxGridLevel, 
  ExtCtrls, StdCtrls, UniDB,
  Registry, SysUtils;

const
  REGINI = TRegIniFile.Create('Software\CTM\');    
  KEY = 'STS\PROCDOCS\COMM_ACT_FROM_UV';
              

procedure rbSearchParamPropertiesChange(Sender: TObject);
begin
  Case rbSearchParam.ItemIndex of    
     // по транспортному документу и транспортному средству
     0 : begin                                               
       UniQuery1.SQL.Clear;
       UniQuery1.Params.Clear;                                                                                                                                               
       UniQuery1.SQL.Add('SELECT JOURNAL_MASTER_ID, PrDocumentName, PrDocumentNumber, PrDocumentDate, SVHDocNumber, SVHDocDate, SumInvoiceCost, SumPlaceNumber, SumBruttoVolQuantity, SumMeasureQuantity ');
       UniQuery1.SQL.Add('FROM JRGOODOUT2 ');
       UniQuery1.SQL.Add('WHERE ');
       UniQuery1.SQL.Add('JOURNAL_MASTER_ID IN '); 
       UniQuery1.SQL.Add(' (SELECT JOURNAL_MASTER_ID FROM DTTranspDoc2 WHERE (PrDocumentNumber=:docno OR OnlyNumber=:onlynumber) AND PrDocumentDate=:docdate) ');
       UniQuery1.SQL.Add('AND JOURNAL_MASTER_ID IN ');
       UniQuery1.SQL.Add(' (SELECT JOURNAL_MASTER_ID FROM TRANSPORT2 WHERE TransportIdentifier=:transpno OR TransportIdentifier=:ntrailer)');
       UniQuery1.SQL.Add('AND DOCUMENTKIND=' +chr(39)+ 'GoodOutDecision' +chr(39));
       UniQuery1.Params.ParamByName('docno').DataType := 1;    // ftString  
       UniQuery1.Params.ParamByName('onlynumber').DataType := 1; // frString          
       UniQuery1.Params.ParamByName('docdate').DataType := 11;  // ftDate    
       UniQuery1.Params.ParamByName('transpno').DataType := 1; // frString        
       UniQuery1.Params.ParamByName('ntrailer').DataType := 1; // frString                
       UniQuery1.Params.ParamByName('docno').Value := qPapers.FieldByName('PAPERNO').Value;     
       UniQuery1.Params.ParamByName('onlynumber').Value := ExecuteFuncScript('RegExReplace ("' + qPapers.FieldByName('PAPERNO').Value + '", "[^(\d)]", "", 34)');    
       UniQuery1.Params.ParamByName('docdate').Value := qPapers.FieldByName('PAPERDATE').Value;   
       UniQuery1.Params.ParamByName('transpno').Value := qTransp.FieldByName('CARNO').Value;    
       UniQuery1.Params.ParamByName('ntrailer').Value := qTransp.FieldByName('NTRAILER').Value;    
       UniQuery1.Reopen;                                                                    
     end;        
     // по транспортному документу
     1 : begin     
        UniQuery1.SQL.Clear;
        UniQuery1.Params.Clear;
        UniQuery1.SQL.Add('SELECT JOURNAL_MASTER_ID, PrDocumentName, PrDocumentNumber, PrDocumentDate, SVHDocNumber, SVHDocDate, SumInvoiceCost, SumPlaceNumber, SumBruttoVolQuantity, SumMeasureQuantity ');
        UniQuery1.SQL.Add('FROM JRGOODOUT2 ');
        UniQuery1.SQL.Add('WHERE ');             
        UniQuery1.SQL.Add('JOURNAL_MASTER_ID IN ');    
        UniQuery1.SQL.Add('  (SELECT JOURNAL_MASTER_ID FROM DTTranspDoc2 WHERE (PrDocumentNumber=:docno OR OnlyNumber=:onlynumber) AND PrDocumentDate=:docdate)');                                                             
        UniQuery1.SQL.Add('AND DOCUMENTKIND=' +chr(39)+ 'GoodOutDecision' +chr(39));
        UniQuery1.Params.ParamByName('docno').DataType := 1;    // ftString
        UniQuery1.Params.ParamByName('onlynumber').DataType := 1; // frString                  
        UniQuery1.Params.ParamByName('docdate').DataType := 11;  // ftDate            
        UniQuery1.Params.ParamByName('docno').Value := qPapers.FieldByName('PAPERNO').Value; 
        UniQuery1.Params.ParamByName('onlynumber').Value := ExecuteFuncScript('RegExReplace ("' + qPapers.FieldByName('PAPERNO').Value + '", "[^(\d)]", "", 34)');            
        UniQuery1.Params.ParamByName('docdate').Value := qPapers.FieldByName('PAPERDATE').Value;   
        UniQuery1.Reopen;                 
     end;    
     // по транспортному документу (без даты)
     2 : begin    
        UniQuery1.SQL.Clear;
        UniQuery1.Params.Clear;
        UniQuery1.SQL.Add('SELECT JOURNAL_MASTER_ID, PrDocumentName, PrDocumentNumber, PrDocumentDate, SVHDocNumber, SVHDocDate, SumInvoiceCost, SumPlaceNumber, SumBruttoVolQuantity, SumMeasureQuantity ');
        UniQuery1.SQL.Add('FROM JRGOODOUT2 ');
        UniQuery1.SQL.Add('WHERE ');
        UniQuery1.SQL.Add('JOURNAL_MASTER_ID IN ');    
        UniQuery1.SQL.Add('  (SELECT JOURNAL_MASTER_ID FROM DTTranspDoc2 WHERE PrDocumentNumber=:docno OR OnlyNumber=:onlynumber)');
        UniQuery1.SQL.Add('AND DOCUMENTKIND=' +chr(39)+ 'GoodOutDecision' +chr(39));        
        UniQuery1.Params.ParamByName('docno').DataType := 1;    // ftString 
        UniQuery1.Params.ParamByName('onlynumber').DataType := 1; // frString          
        UniQuery1.Params.ParamByName('docno').Value := qPapers.FieldByName('PAPERNO').Value;
        UniQuery1.Params.ParamByName('onlynumber').Value := ExecuteFuncScript('RegExReplace ("' + qPapers.FieldByName('PAPERNO').Value + '", "[^(\d)]", "", 34)');            
        UniQuery1.Reopen;
     end;  
     // по транспортному средству
     3 : begin
        UniQuery1.SQL.Clear;
        UniQuery1.Params.Clear;
        UniQuery1.SQL.Add('SELECT JOURNAL_MASTER_ID, PrDocumentName, PrDocumentNumber, PrDocumentDate, SVHDocNumber, SVHDocDate, SumInvoiceCost, SumPlaceNumber, SumBruttoVolQuantity, SumMeasureQuantity ');
        UniQuery1.SQL.Add('FROM JRGOODOUT2 ');
        UniQuery1.SQL.Add('WHERE ');
        UniQuery1.SQL.Add('JOURNAL_MASTER_ID IN ');    
        UniQuery1.SQL.Add('  (SELECT JOURNAL_MASTER_ID FROM TRANSPORT2 WHERE TransportIdentifier=:transpno OR TransportIdentifier=:ntrailer)');
        UniQuery1.SQL.Add('AND DOCUMENTKIND=' +chr(39)+ 'GoodOutDecision' +chr(39));        
        UniQuery1.Params.ParamByName('transpno').DataType := 1;    // ftString
        UniQuery1.Params.ParamByName('ntrailer').DataType := 1; // frString                  
        UniQuery1.Params.ParamByName('transpno').Value := qTransp.FieldByName('CARNO').Value; 
        UniQuery1.Params.ParamByName('ntrailer').Value := qTransp.FieldByName('NTRAILER').Value;        
        UniQuery1.Reopen;
     end;
  else btnOK.Enabled := False;  
  end;    

  btnOK.Enabled := UniQuery1.Recordcount;
end;
                                                                                
procedure MainDialogResize(Sender: TObject);
begin      
  if WindowState = wsMaximized then 
    begin
      cxGrid1DBTableView1.OptionsView.ColumnAutoWidth := True;  
    end
  else
    begin                          
      Position := poScreenCenter;              
    end;
end;                       

         
procedure MainDialogClose(Sender: TObject; var Action: TCloseAction);                                       
begin
  //сохраняем параметры формы 
  // если окно развернуто на весь экран - не запоминаем его размер
  if WindowState <> wsMaximized then
    begin
      REGINI.WriteInteger(KEY, 'Height', Height); 
      REGINI.WriteInteger(KEY, 'Width', Width);          
    end;                                                  
  REGINI.WriteInteger(KEY, 'WindowState', WindowState);        
  REGINI.WriteString(KEY, 'PersonLastName', teLastName.Text);
  REGINI.WriteString(KEY, 'PersonFirstName', teFirstName.Text);
  REGINI.WriteString(KEY, 'PersonMiddleName', teMiddleName.Text);  
  REGINI.WriteString(KEY, 'PersonPost', tePost.Text);  
  REGINI.Free;                  
end;

procedure MainDialogCreate(Sender: TObject);
begin
  // загрузка настроек формы из реестра                    
  Height := REGINI.ReadInteger(KEY, 'Height', 600);
  Width := REGINI.ReadInteger(KEY, 'Width', 950);      
  Position := poScreenCenter;         
  WindowState := REGINI.ReadInteger(KEY, 'WindowState', 0);   
  
  teLastName.Text := REGINI.ReadString(KEY, 'PersonLastName', '');
  teFirstName.Text := REGINI.ReadString(KEY, 'PersonFirstName', '');
  teMiddleName.Text := REGINI.ReadString(KEY, 'PersonMiddleName', '');
  tePost.Text := REGINI.ReadString(KEY, 'PersonPost', '');  
  
  qPapers.Active := False;
  qPapers.Params.ParamByName('placeid').Value := KRD_MAIN.Fields['PLACEID'].Value;
  qPapers.Params.ParamByName('id').Value := KRD_MAIN.Fields['ID'].Value;              
  qPapers.Active := True;    
                 
  qTransp.Active := False;
  qTransp.Params.ParamByName('placeid').Value := KRD_MAIN.Fields['PLACEID'].Value;
  qTransp.Params.ParamByName('id').Value := KRD_MAIN.Fields['ID'].Value;              
  qTransp.Active := True;                    
 
  rbSearchParam.ItemIndex := 0;      
  UniQuery1.Active := False;                     
  UniQuery1.Params.ParamByName('docno').Value := qPapers.FieldByName('PAPERNO').Value;
  UniQuery1.Params.ParamByName('onlynumber').Value := ExecuteFuncScript('RegExReplace ("' + qPapers.FieldByName('PAPERNO').Value + '", "[^(\d)]", "", 34)');    
  UniQuery1.Params.ParamByName('docdate').Value := qPapers.FieldByName('PAPERDATE').Value;                                  
  UniQuery1.Params.ParamByName('transpno').Value := qTransp.FieldByName('CARNO').Value;      
  UniQuery1.Params.ParamByName('ntrailer').Value := qTransp.FieldByName('NTRAILER').Value;      
  UniQuery1.Active := True;                                                                                                                
                              
  btnOK.Enabled := UniQuery1.Recordcount;  
end;
                                                                                          
procedure btnOKClick(Sender: TObject);
var 
  sScriptPath, sJMID, sPersonInfo : String;
  mReason : Memo;
  iSelected, iIndex : Integer;
begin     
  iIndex := 0; 
  iSelected := cxGrid1DBTableView1.Controller.SelectedRecordCount;
  if iSelected > 0 then                                                            
    while iIndex < iSelected do
      begin
        if Length (sJMID) = 0 then
          sJMID := VarToStr(cxGrid1DBTableView1.Controller.SelectedRecords[iIndex].Values[0])
        else
          sJMID := sJMID + ',' + VarToStr(cxGrid1DBTableView1.Controller.SelectedRecords[iIndex].Values[0]);
        iIndex := iIndex + 1;
      end;      
  else
    sJMID := VarToStr(UniQuery1.FieldByName('JOURNAL_MASTER_ID').Value);  

  mReason := mReasons.Lines.Text;          
  sPersonInfo := teLastName.Text + ';' + teFirstName.Text + ';' + teMiddleName.Text + ';' + tePost.Text;  
  
  sScriptPath := ExtractFilePath(Application.ExeName) + 'procdocs\comm_act_from_uv\comm_act_from_uv.prd';
  ExecuteFuncScript('EXECUTESCRIPT ("' + sScriptPath + '");' +
                    'CreateCommAct("' + sJMID + '", "' + mReason + '", "' + sPersonInfo + '");');
end;                                     
                                                                                                   
procedure cxGrid1DBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  btnOKClick(Sender); 
  Close();
end;

procedure mReasonsPropertiesChange(Sender: TObject);
begin
  if length(mReasons.Lines.Text) > 0 then
    mReasons.Style.BorderColor := clWindowFrame
  else
    mReasons.Style.BorderColor := clRed;                
end;

procedure teLastNamePropertiesChange(Sender: TObject);
begin
  if length(teLastName.Text) > 0 then
    teLastName.Style.BorderColor := clWindowFrame
  else
    teLastName.Style.BorderColor := clRed;    
end;   

procedure teFirstNamePropertiesChange(Sender: TObject);
begin
  if length(teFirstName.Text) > 0 then
    teFirstName.Style.BorderColor := clWindowFrame
  else
    teFirstName.Style.BorderColor := clRed;      
end;

procedure teMiddleNamePropertiesChange(Sender: TObject);
begin
  if length(teMiddleName.Text) > 0 then
    teMiddleName.Style.BorderColor := clWindowFrame
  else
    teMiddleName.Style.BorderColor := clRed;      
end;

procedure tePostPropertiesChange(Sender: TObject);
begin
  if length(tePost.Text) > 0 then
    tePost.Style.BorderColor := clWindowFrame
  else
    tePost.Style.BorderColor := clRed;      
end;

begin
end;
