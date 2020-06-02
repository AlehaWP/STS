{$FORM TForm2, Unit2.sfm}                                                                                                                                                         
                                                    
uses
  Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, DB, 
  DBTables, cxGrid, cxGridBandedTableView, cxGridCustomTableView, 
  cxGridCustomView, cxGridDBBandedTableView, cxGridLevel, 
  UniDB, ADODB, Menus, ExtCtrls, Buttons, ComCtrls, FuncScript, cxGraphics, IniFiles, SysUtils, Registry, Unit3;   
  
const
  cRegINI = TRegIniFile.Create('Software\CTM\');    
  cKey = 'STS\PROJECTS\CHECKDO2';    
  
Var 
sDTNum, sParsedG33 : string;
iPlaceid, iId, iCounter : integer;  
iSumBrutto, iSumPlace, iSumCost, iSumVesPallet, iVesPallet, w, h : double; 
iDo2andDtIsDifference : integer;
 cRegINI2  : TRegIniFile;  
 iDTId : integer; 

function OpenQuery(sDBName, sSQL: string): TUniDataSet;
var qResult : TUniQuery;
begin         
  qResult :=  TUniQuery.Create(Self);
  qResult.DatabaseName := sDBName;
  qResult.SQL.Add(sSQL);
  qResult.Active := true; 
  Result := qResult;
end;


procedure SetCellValue (pIndex : integer; sValue : string)
begin                                       
   cxGrgGoodsTV.Controller.FocusedItemIndex :=  pIndex;                                  
   cxGrgGoodsTV.Controller.FocusedItem.EditValue := sValue;   
   //cxGrgGoodsTV.Controller.FocusedItem.OnCustomDrawCell := 'cxGrgGoodsTVCustomDrawCell';
end;

procedure FillSumm (pFillSumm : integer; pSetZiro : integer);
begin 
    if pSetZiro then begin   
        iSumBrutto := 0;     
        iSumPlace := 0;
        iSumCost := 0; 
        iSumVesPallet := 0;   
    end;
    if pFillSumm then 
    with qDTGoods.DataSet do begin   
        iVesPallet := 0;
        IF  (FieldByName('PlaceDescription').Value <> Null) and (FieldByName('PlaceDescription').Value <> '') then begin
            iVesPallet := ExecuteFuncScript ('EXECUTESCRIPT(PROGRAMPATH() + "ProcDocs\FindNumber.prd");FINDNUMBER("'+FieldByName('PlaceDescription').Value+'", "КГ)^кг)^Кг)^кГ)^КГ^Кг^кг^кГ");');
            If iVesPallet = Null then iVesPallet := 0;                                                              
        end;                
        iSumVesPallet := iSumVesPallet + iVesPallet;   
        iSumBrutto := iSumBrutto + FieldByName('BruttoVolQuantity').Value; 
        iSumPlace := iSumPlace +  FieldByName('PlaceNumber').Value;           
        iSumCost :=  iSumCost +  FieldByName('InvoiceCost').Value;  
    end;
end;
                                                                                                         
function AddToResult(pResult : string; pAdd : string) : string;
var
sRes : string;
begin
    sRes := pResult;
    if sRes = '' then sRes := 'Расхождение в:'              
    else sRes := sRes + '; ';
    sRes := sRes + pAdd;
    Result := sRes; 
end;          
               
procedure AddGoodsToGrid(iFillNotExistInDo2 : integer);
var 
   sResult : string;
begin                                                                                
    sResult := '';     
    cxGrgGoodsTV.Controller.CreateNewRecord(true);  
    if iFillNotExistInDo2 = 0 then 
        with qryRC.DataSet do begin      
            SetCellValue(0, FieldByName('G32').Value); 
            SetCellValue(2, FieldByName('G33').Value);
            SetCellValue(3, FieldByName('G312').Value);  
            SetCellValue(4, FieldByName('RELEASE_G35').Value); 
            SetCellValue(8, FieldByName('RELEASE_G311').Value);
            SetCellValue(10, FieldByName('RELEASE_G42').Value);   
            SetCellValue(12, FieldByName('VALCODE').Value);    
            SetCellValue(14, FieldByName('OUT_DATE').Value);  
        end
    else begin
    end; 
    
    
    if qDTGoods.IsEmpty then 
         sResult := 'Товар не найден в ДТ'
    else
    with qDTGoods.DataSet do begin  
         
        IF (iFillNotExistInDo2 = 0) then begin 
            First;  
            FillSumm (0 , 1);
            while Eof=0 do begin  
                FillSumm (1, 0);
                if sParsedG33<> '' then sParsedG33 :=  sParsedG33 + ',';                              
                sParsedG33 :=  sParsedG33 + QuotedStr(FieldByName('GoodsTNVEDCODE').Value);                 
                Next;   
            end;              
                  
            IF CheckWeight.Checked and (iSumBrutto + iSumVesPallet <> qryRC.FieldByName('RELEASE_G35').Value)
            then  sResult := AddToResult(sResult, 'Весе'); 
            IF CheckPlace.Checked and (iSumPlace <> qryRC.FieldByName('RELEASE_G311').Value)
            then  sResult := AddToResult(sResult, 'Кол-ве мест'); 
            IF CheckCost.Checked and (iSumCost <> qryRC.FieldByName('RELEASE_G42').Value)
            then  sResult := AddToResult(sResult, 'Стоимости'); 
            IF CheckCurrency.Checked and (FieldByName('CurrencyCode').Value <> qryRC.FieldByName('VALCODE').Value)
            then  sResult := AddToResult(sResult, 'Кодах валюты'); 
            IF CheckDateOut.Checked and (FieldByName('SendDate').Value > qryRC.FieldByName('OUT_DATE').Value) 
            then sResult := AddToResult(sResult, 'Дате выпуска'); 
            

        end                                                                                   
        else begin
            FillSumm (1, 1);
            SetCellValue(2, FieldByName('GoodsTNVEDCODE').Value);
            SetCellValue(3, FieldByName('GoodsDescription').Value);            
            sResult := 'Товар отсутствует в ДО2';
        end; 
        
        SetCellValue(5, iSumBrutto + iSumVesPallet);
        SetCellValue(6, iSumBrutto);            
        SetCellValue(7, iSumVesPallet);
        SetCellValue(9, iSumPlace); 
        SetCellValue(11, iSumCost);  
        SetCellValue(13, FieldByName('CurrencyCode').Value); 
        SetCellValue(15, FieldByName('SendDate').Value);          
    end;                                                                                                                                                                               
                                                                    
    //if sResult <>  
    
    SetCellValue(1, sResult);     
    cxGrgGoodsTV.Controller.FocusedItemIndex := 0; 
    

     
    if sResult <> '' then iDo2andDtIsDifference := 1;  
    
    
end;          
                                                    
procedure ReadOptionsFromIniFile;
var
sIniFlePath : string; 
i : integer;
oComponent : TcxCheckBox;     
begin                     
    sIniFlePath := ExecuteFuncScript('Programpath()') + 'sts.ini';
    { 
    CheckWeight.Checked := cRegIni.ReadBool(cKey,'CheckWeight', true);
    CheckPlace.Checked := cRegIni.ReadBool(cKey,'CheckPlace', true);
    CheckCost.Checked := cRegIni.ReadBool(cKey,'CheckCost', true);
    CheckCurrency.Checked := cRegIni.ReadBool(cKey,'CheckCurrency', true);
    CheckDateOut.Checked := cRegIni.ReadBool(cKey,'CheckDateOut', true);
    CheckBy4Symbol.Checked := cRegIni.ReadBool(cKey,'CheckBy4Symbol', true); 
    CheckGroupCodes.Checked := cRegIni.ReadBool(cKey,'CheckGroupCodes', true); 
    CheckTSDinDOandDT.Checked := cRegIni.ReadBool(cKey,'CheckTSDinDOandDT', true); 
     }
     for i:=0 to gbOptions.ControlCount-1 do
     if (gbOptions.controls[i] is tcxCheckBox) then
     begin   
         oComponent := gbOptions.Controls[i]; 
         oComponent.Checked:= cRegIni.ReadBool(cKey, oComponent.Name, True);   
     end;   
    
    gbOptions.Visible :=  cRegIni.ReadBool(cKey,'gbOptions', false); 
     
    Width := cRegIni.ReadInteger(cKey, 'FormWidth', 0);             
    Height := cRegIni.ReadInteger(cKey, 'FormHeight', 0);
    Left:= cRegIni.ReadInteger(cKey, 'FormLeft', 0);
    Top := cRegIni.ReadInteger(cKey, 'FormTop', 0);    
    
    if Left <> 0 then Position := poDesigned
    else  Position := poMainFormCenter;
    
    WindowState :=  cRegIni.ReadInteger(cKey,'WindowState', 0); 

    if gbOptions.Visible then  btOptions.Caption := 'Скрыть настройки'
    else btOptions.Caption := 'Настройки проверки'; 
        
    //Событие пришлось прописать в настройках, потому что иначе оно вызывалось при настройке чекбоксов из ini
    for i:=0 to gbOptions.ControlCount-1 do
        if (gbOptions.controls[i] is tcxCheckBox) then
        begin   
            oComponent := gbOptions.Controls[i]; 
            oComponent.OnClick:='CheckOptionsChanged';                  
        end;   
        
       
        

end;  

procedure SetColumnsVisible;
begin
    cxGrgGoodsTV.Bands.Items[4].Visible := CheckWeight.Checked;
    cxGrgGoodsTV.Bands.Items[5].Visible := CheckPlace.Checked; 
    cxGrgGoodsTV.Bands.Items[6].Visible := CheckCost.Checked; 
    cxGrgGoodsTV.Bands.Items[7].Visible := CheckCurrency.Checked;
    cxGrgGoodsTV.Bands.Items[8].Visible := CheckDateOut.Checked;
    
end;
   
procedure SetNormalToshowDOandDTDocsButton;
begin
     showDOandDTDocs.PaintStyle := 1; 
     showDOandDTDocs.Caption := '                    Посмотреть ТСД ДО1 и ДТ';
     showDOandDTDocs.Colors.DefaultText := clBlack;  
end;
                                                          
function CheckDoDt : integer; 
var                                                         
sSQL, sPaperNo : string; 
qryKR_Paper, qryDT_Doc: TUniQuery;
iCounterDoc: integer; 

begin  
  ReadOptionsFromIniFile;          
    
  iDo2andDtIsDifference := 0; 
  sParsedG33 := ''; 
  sSQL := ''; 
  iDTId := 0; 
  sPaperNO := '';   
  iCounterDoc := 0; 
  
  sDTNum := Release.FieldByName('DOC_NO').Value; 
  iPlaceid:= Release.FieldByName('PLACEID').Value;
  iId:= Release.FieldByName('ID').Value;    
  iCounter := Release.FieldByName('COUNTER').Value; 
  
  if CheckGroupCodes.Checked then begin                  
      sSQL := qryRC.SQL.Text; 
      sSQL := StringReplace(sSQL, 'RC.G32', 'MIN(RC.G32) as G32', 0);
      sSQL := StringReplace(sSQL, 'RC.RELEASE_G35, RC.RELEASE_G311, RC.RELEASE_G42', 'SUM(RC.RELEASE_G35) as RELEASE_G35, SUM(RC.RELEASE_G311) as RELEASE_G311, SUM(RC.RELEASE_G42) as RELEASE_G42', 0);
      sSQL := StringReplace(sSQL, 'ISNULL(RC.RELEASE_OUT_DATE, R.OUT_DATE)', 'MIN(ISNULL(RC.RELEASE_OUT_DATE, R.OUT_DATE))', 0);
      sSQL := sSQL + '  GROUP BY   RC.RELEASE_G33, KC.G33, KC.G42_Currency, KC.ValCode, CAST(KC.G312 as VARCHAR(1000))';
      //sSQL := sSQL + '  ,OUT_DATE';
      //showmessage (sSQL);
      qryRC.SQL.Text := sSQL;
  end;
                                                              
  qryRC.Params.ParamByName('PID').Value := iPlaceid;      
  qryRC.Params.ParamByName('ID').Value := iID;      
  qryRC.Params.ParamByName('COUNTER').Value := iCOUNTER;
  qryRC.Active := true;                                                          

                       
  with qryRC.DataSet do begin                 
      First;                                         
      While Eof=0 do begin         
          qDTGoods.Params.ParamByName('DOC_NO').Value := sDTNum; 
          qDTGoods.Params.ParamByName('G33').Value := FieldByName('G33').Value;        
          qDTGoods.Active := true;    
          
          if qDTGoods.IsEmpty and CheckBy4Symbol.Checked then begin
              qDTGoods.Active := false;
              sSQL := qDTGoods.SQL.Text;  
              sSQL := StringReplace(sSQL, 'G.GoodsTNVEDCODE=', 'SUBSTRING(G.GoodsTNVEDCODE,1,4)=', 0); 
              qDTGoods.Params.ParamByName('G33').Value := COPY(FieldByName('G33').Value, 1,4);                                                               
              
              qDTGoods.SQL.Text := sSQL;
              qDTGoods.Active := true;
          end; 
          if not qDTGoods.IsEmpty then iDTId := qDTGoods.FieldByName('JMID').Value;  
          AddGoodsToGrid(0);

          qDTGoods.Active := false; 
          Next;                     
      end;                           
  end;  
  
  qryRC.Active := false; 
  
  sSQL := '';
  sSQL := sSQL + 'SELECT G.GoodsTNVEDCODE, G.GoodsDescription, G.CurrencyCode, G.PlaceNumber, G.PlaceDescription'; 
  sSQL := sSQL + ' ,G.InvoiceCost, G.BruttoVolQuantity, G.MeasureQuantity ';                
  sSQL := sSQL + ' ,J.PrDocumentNumber, CAST((CAST(J.SendDate as varchar(12)) +' + QuotedStr(' ') + '+ J.SendTime) as DateTime) as SendDate, J.ReleaseDate, G.Journal_Master_id as JMID'    ;
  sSQL := sSQL + ' FROM GOODINFO2 G';                                                                                                                       
  sSQL := sSQL + ' Inner Join JrGoodOut2 J On (J.JOURNAL_MASTER_ID=G.JOURNAL_MASTER_ID)';  
  sSQL := sSQL + ' WHERE ';
  sSQL := sSQL + ' J.PrDocumentNumber=:DOC_NO ';
  if sParsedG33 <> '' then sSQL := sSQL + ' AND G.GoodsTNVEDCODE not in('+sParsedG33+')';
  
  qDTGoods.Sql.Text := sSQL;
  //showmessage(sSQL);
  qDTGoods.Params.ParamByName('DOC_NO').Value := sDTNum;                                                                                                     
  qDTGoods.Active := true;
  if not qDTGoods.IsEmpty then 
     with qDTGoods.DataSet do begin 
         iDTId := FieldByName('JMID').Value;  
         First;    
         while eof=0 do begin
             AddGoodsToGrid(1);                                                                             
             next;
         end;
     end;
  qDTGoods.Active := false;
                     
  SetColumnsVisible;
  
  cxGrgGoodsTV.Controller.FocusedRecordIndex := 0;
  if CheckTSDinDOandDT.Checked  then begin
      qryKR_Paper := OpenQuery('STS_DB', 'SELECT DISTINCT PAPERNO FROM KR_PAPER WHERE ID='+ IntToStr(iID) +'  AND PAPERCODE LIKE ''02%''
                                          UNION 
                                          SELECT DISTINCT PAPERNO FROM KRD_DCD WHERE ID='+ IntToStr(iID)
      ); 
    
      with qryKR_Paper do begin
          First;
          While Eof=0 do begin                  
             if sPaperNo<>'' then sPaperNo:= sPaperNo + ',';
             sPaperNo := sPaperNo + #39 + FieldByName('PAPERNO').Value + #39;  
             iCounterDoc := iCounterDoc + 1;
             next;
          end;
          Free;
      end;   
      qryDT_Doc := OpenQuery('dbJournals', 'SELECT DISTINCT COUNT (DISTINCT prDocumentNumber) as DocCount FROM TransportDoc2 
                                            WHERE JOURNAL_MASTER_ID='+IntToStr(iDTId)+' AND prDocumentNumber in ('+sPaperNO+') ');
                                            
      if iCounterDoc > qryDT_Doc.FieldByName('DocCount').Value then 
         iDo2andDtIsDifference := 1
      else SetNormalToshowDOandDTDocsButton;
  end    
  else SetNormalToshowDOandDTDocsButton; 
  Result := iDo2andDtIsDifference;      
                                                                           
end;                                                                                                                             

     
procedure cxGrgGoodsTVCustomDrawCell(Sender: TcxGridBandedTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
begin                                      
     if(AViewInfo.GridRecord.Values[13]<>'') and (AViewInfo.GridRecord.Values[13]<>Null) then begin
         //showmessage(AViewInfo.GridRecord.Values[13]);
         ACanvas.Brush.Color := $A0B0FF;    
     end    
     else                   
         ACanvas.Brush.Color := $c1ffb2;   
 
end;                                    
 
procedure SaveWindowOptions;
begin
    cRegIni.WriteBool(cKey,'gbOptions', gbOptions.Visible); 
    cRegIni.WriteInteger(cKey, 'WindowState', WindowState);
    cRegIni.WriteInteger(cKey, 'FormWidth', Width);
    cRegIni.WriteInteger(cKey, 'FormHeight', Height); 
    cRegIni.WriteInteger(cKey, 'FormLeft', Left);
    cRegIni.WriteInteger(cKey, 'FormTop', Top);     
end;
   
procedure ReloadForm;
begin
    Close;                                                 
    ModalResult := mrRetry; 
end;
                                             
procedure CheckOptionsChanged(Sender: TcxCheckBox);
begin 
    cRegIni.WriteBool(cKey, Sender.Name, Sender.Checked); 
    SaveWindowOptions;     
    ReloadForm; 
end;                                                                  
                     
procedure btOptionsClick(Sender: TObject); 
begin  
   if gbOptions.Visible 
   then begin                                   
       gbOptions.Visible := false
       btOptions.Caption := 'Настройки проверки'       
   end                                       
   else begin
       gbOptions.Visible := true;                             
       btOptions.Caption := 'Скрыть настройки'    
   end;    
end;                                    
  

  
procedure Form2Resize(Sender: TObject);  
var prw,prh:real;i:integer;
oComponent : TcxCheckBox
begin 
    if w=Null then w:= 1000; 
    if h=Null then h:= 700;
    prw:=Width/w;  
    prh:=height/h;
    for i:=0 to gbOptions.ControlCount-1 do
        if (gbOptions.controls[i] is tcxCheckBox) then
        begin   
            oComponent := gbOptions.Controls[i]; 
            oComponent.OnClick:='CheckOptionsChanged';
            oComponent.Left:=round(oComponent.Left*prw);
            oComponent.width:=round(oComponent.width*prw);              
        end;  
 
    w:=Width;        
    h:=Height;    
end;
 

procedure btCloseClick(Sender: TObject);
begin
    SaveWindowOptions;
end;

procedure btResetAllOptionsClick(Sender: TObject);
var 
oComponent : TcxCheckBox;
i : integer;
begin               
    cRegIni.WriteBool(cKey,'gbOptions', false);
    cRegIni.WriteInteger(cKey, 'WindowState', 0);
    cRegIni.WriteInteger(cKey, 'FormWidth', 0);
    cRegIni.WriteInteger(cKey, 'FormHeight', 0); 
    cRegIni.WriteInteger(cKey, 'FormLeft', 0);
    cRegIni.WriteInteger(cKey, 'FormTop', 0); 
    for i:=0 to gbOptions.ControlCount-1 do
        if (gbOptions.controls[i] is tcxCheckBox) then
        begin   
            oComponent := gbOptions.Controls[i]; 
            cRegIni.WriteBool(cKey, oComponent.Name, True);   
        end;      
    
    ReloadForm;
end;

procedure showDOandDTDocsClick(Sender: TObject);
var
frDODocsDtDocs : TfrDODocsDtDocs;
begin
   frDODocsDtDocs := TfrDODocsDtDocs.Create(Self);  
   frDODocsDtDocs.DODtDocsConstract(iId,iDTId);
   frDODocsDtDocs.ShowModal; 
   frDODocsDtDocs.Free;                  
end;

begin                    

                                                 
end;                                                                                          
