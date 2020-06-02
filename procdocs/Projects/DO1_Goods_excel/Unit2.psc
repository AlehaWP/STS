{$FORM TForm2, Unit2.sfm}                                                                                                                                                                             

uses
  Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, 
  cxGrid, cxGridBandedTableView, cxGridCustomTableView, 
  cxGridCustomView, cxGridDBBandedTableView, cxGridLevel, 
  UniDB, ComCtrls, ExtCtrls, FuncScript, Mask, SysUtils, AnsiStrings, IniFiles, StrUtils;

var  
  iID, iPlaceID, iG32 : integer;
  sProgPath : string;  
  Ini : TIniFile; 
  
//Функция сохранения данных                           
Procedure PostDataSet(qryParam: TUniQuery);
begin          
     //RecordCount на БД SQL периодически подглючивает    
     IF (qryParam <> NULL) and (qryParam.DataSet.IsEmpty  = false) then                                                       
        IF (qryParam.DataSet.State = 2) or (qryParam.DataSet.State = 3) then           
           qryParam.Dataset.Post;                                                                                      
end;                         

//Выполнение функции EXECUTESQL средствами FuncScript                                  
procedure ExecuteSQL(sDBName : strng; sSQL: string);
Var
ExQry: TUniQuery;
begin  

    ExQry:= TUniQuery.Create('self');
    ExQry.DatabaseName := sDBName;                      
    //try
       ExQry.SQL.Text := sSQL;              
       ExQry.ExecSQL;                                      
    //except 
      // showmessage(sSQL);                       
   // end;                                         

    ExQry.Free;                                                  
end;    

procedure ReadExcelCreatGoodsInDataBase(pExcelPath: string; pPlaceid: string; pID: string; pStartG32: integer; pNBD: string; pDoDate: datetime);  
var
    Excel, WB,Sheet : variant;      
    pG32, Columns, Sheets,i,iRow,iEmptyRows : Integer;  
    sSQLComm, sSqlKRCP, sKRDCommsValues, sKRCPValues : string; 
    sG33, sStorageDateStart, sAcceptDate : string;   
    sBoxNoAdd : string;         
begin
    IF pExcelPath<>'' then begin  
         //ExecuteFuncScriptFromFile(sProgPath + 'ProcDocs\data.prd');  
         sKRDCommsValues := ''; 
         sKRCPValues := '';
         pG32:= pStartG32;  
         iEmptyRows := 0;      
         sBoxNoAdd := '';
        // showmessage(cxBoxNo.Style.Color);
         if cxBoxNo.Style.Color <> clGray  then sBoxNoAdd := ' ' + cxBoxNo.Text;    
         //showmessage(sBoxNoAdd);
         Excel := CreateOleObject('Excel.Application');  
         Excel.Visible := False;
         WB := Excel.Workbooks.Open(pExcelPath);
 
         sSQLComm := 'INSERT INTO KRD_COMM (PLACEID, ID, G32, N_TTN, N_TTN_G32, G33, G312, G35, G42, G42_CURRENCY, 
                      VALCODE, ACCEPTDATE, STORAGE_DATE, STORE_PERIOD, STORAGE_TYPE, LEG_PERIOD, BOXNO, REMARK ) VALUES ';  
         sSqlKRCP :=  'INSERT INTO KR_C_P (PLACEID, ID, G32, DOC_COUNTER, DOC_TYPE) VALUES ';             

         sAcceptDate := #39 + FormatDateTime('DD.MM.YYYY HH:MM', pDoDate) + #39;   
         sStorageDateStart := #39 + FormatDateTime('DD.MM.YYYY', (pDoDate + 1)) + #39;    

         for i := 1 to WB.WorkSheets.Count do begin    
             Sheet := WB.Sheets[i];       
             for iRow := 1 to Sheet.UsedRange.Rows.Count do begin
                 sG33 := Sheet.Cells[iRow,1].Text;         
                 if sG33 <> '' then begin
                     pG32 := pG32 + 1; 
                     if sKRDCommsValues <> '' then sKRDCommsValues := sKRDCommsValues + ',';           
                     sKRDCommsValues := sKRDCommsValues + '(';
                     sKRDCommsValues := sKRDCommsValues + pPlaceid; 
                     sKRDCommsValues := sKRDCommsValues + ',' + pID;  
                     sKRDCommsValues := sKRDCommsValues + ',' + IntToStr(pG32); 
                     sKRDCommsValues := sKRDCommsValues + ',1';           
                     sKRDCommsValues := sKRDCommsValues + ',' + IntToStr(pG32); 
                     sKRDCommsValues := sKRDCommsValues + ',' + #39 + sG33 + #39;
                     sKRDCommsValues := sKRDCommsValues + ',' + #39 + ReplaceStr(ReplaceStr(Sheet.Cells[iRow,2].Text,#39,#39 + #39),#34,#34 + #34) + #39;  
                     sKRDCommsValues := sKRDCommsValues + ',' + ReplaceStr(ReplaceStr(Sheet.Cells[iRow,3].Text, ',', '.'), ' ','');   
                     sKRDCommsValues := sKRDCommsValues + ',' + ReplaceStr(ReplaceStr(Sheet.Cells[iRow,4].Text, ',', '.'), ' ','');                      
                     sKRDCommsValues := sKRDCommsValues + ',' + #39 + ExecuteFuncScript('CURRENCYCODE("'+Sheet.Cells[iRow,5].Text+'")')+ #39; 
                     sKRDCommsValues := sKRDCommsValues + ',' + #39 + Sheet.Cells[iRow,5].Text + #39;  
                     sKRDCommsValues := sKRDCommsValues + ',' + sAcceptDate;   
                     sKRDCommsValues := sKRDCommsValues + ',DATEADD(month, 4, ' + sStorageDateStart + ')';      
                     sKRDCommsValues := sKRDCommsValues + ',CAST(DATEADD(month, 4, ' + sStorageDateStart + ')-' + sStorageDateStart + ' as integer)'; 
                     sKRDCommsValues := sKRDCommsValues + ',' + #39 + 'НОР' + #39; 
                     sKRDCommsValues := sKRDCommsValues + ',CAST(DATEADD(month, 4, ' + sStorageDateStart + ')-' + sStorageDateStart + ' as integer)';                
                     sKRDCommsValues := sKRDCommsValues + ',' + #39 + pNBD + '/' + RIGHTSTR('00000' + IntToStr(pG32), 6) + sBoxNoAdd + #39; 
                     sKRDCommsValues := sKRDCommsValues + ',' + #39 + cxRemark.Text + #39; 
                     sKRDCommsValues := sKRDCommsValues + ')';  
                     
                     if sKRCPValues <> '' then sKRCPValues := sKRCPValues + ',';           
                     sKRCPValues:= sKRCPValues + '(';
                     sKRCPValues := sKRCPValues + pPlaceid; 
                     sKRCPValues := sKRCPValues + ',' + pID;  
                     sKRCPValues := sKRCPValues + ',' + IntToStr(pG32); 
                     sKRCPValues := sKRCPValues + ',1';   
                     sKRCPValues := sKRCPValues + ',13'; 
                     sKRCPValues := sKRCPValues + ')'; 
                     //Если оч.много товаров, то начинаются трудности "слишком большой SQL запрос" поэтому каждые 100 товаров закидываем в базу.
                     if pG32 mod 50 = 0 then begin           
                         ExecuteSQL('STS_DB', sSQLComm + sKRDCommsValues);  
                         sKRDCommsValues := '';     
                     end;    
                      
                 end                                                                
                 else begin                                  
                     //UsedRange возвращает все строки, побороть не удалось. Пришлось заканчивать чтение по определенному кол-ву пустых данных  
                     iEmptyRows := iEmptyRows + 1;
                     if iEmptyRows > 10 then  Break;
                 end;    
             end;                        
         end;    
        // showmessage(sKRDCommsValues); 
         
         //Грузим в базу товары и связи с накладной          
         if sKRDCommsValues <> '' then ExecuteSQL('STS_DB', sSQLComm + sKRDCommsValues); 
         if sKRCPValues <> '' then ExecuteSQL('STS_DB', sSqlKRCP+ sKRCPValues); 

         WB.Close;
         Excel.Quit;  
    end;        
end;

function CreateDO1(pPlaceid: string; pID: string; pDoDate: datetime): string;  
var 
    sSQL, sFuncNBD sShowNBD : string;
begin 
	KRD_MAIN.Locate('Placeid', iPlaceid, 0);  		
    sFuncNBD := RightStr('000000' + ExecuteFuncScript(Ini.ReadString('Docs', 'MakeBD_NO', '1')), 7); 
    sShowNBD := FormatDateTime('YYYYMMDD', pDoDate)+RIGHTSTR(sFuncNBD, 5);
    sSQL := 'INSERT INTO KRD_MAIN (PLACEID, ID, MAIN_ID, BD_DATE, BEG_KEEP, NBD, SHOW_NBD,
                                   G142,G143,G144, G1440, G145) 
            SELECT                                                    
             '+pPlaceid+','+pid+', '+pid+', '+#39+ VarToStr(pDoDate) +#39+', '+#39+ VarToStr(pDoDate+1) +#39+'  
             ,'+#39+ sFuncNBD +#39+', '+#39+ sSHOWNBD +#39+'
             , NAME, ADDRESS, LICENCENO, LICENCETYPE , LICENCEDATE                                  
             FROM STORES WHERE PLACEID='+pPlaceID;
    ExecuteSQL('STS_DB', sSql); 
    Result := sFuncNBD;
end;

procedure CreateWayBill(pPlaceid: string; pID: string);
var 
    sSQL : string;  
begin   
    sSQL := 'INSERT INTO KR_PAPER (PLACEID, ID, COUNTER, PAPERNAME, PAPERCODE, PAPERNO) VALUES 
             ('+pPlaceid+','+pid+',1, (SELECT MAX(PAPERNAME) FROM PAPERS WHERE PAPER_DOCG44_CODE='+#39+ refWayBillCode.Text +#39+')
             ,'+#39+ refWayBillCode.Text  +#39+', '+#39+ tcxWayBill.Text +#39+')
    ';
    ExecuteSQL('STS_DB', sSql);
end;

procedure btOkClick(Sender: TObject);                        
var 
    dtDoDate : datetime;
    sNBD : string;
begin
  if rbCreateNewDO.Checked then  begin 
      iPlaceID := qryStores.FieldByName('PLACEID').Value;   
      
      qryMaxID.Active := true;                               
      iID :=qryMaxID.FieldByName('ID').Value; 
      qryMaxID.Active := false; 
      
      iG32 := 0; 
      dtDoDate := NOW();
      
      sNBD := CreateDO1(IntToStr(iPlaceid), IntToStr(iID), dtDoDate); 
      CreateWayBill(IntToStr(iPlaceid), IntToStr(iID));                           
  end;                                                                                                               
  if rbLoadToActiveDo.Checked then begin          
      iPlaceID := KRD_MAIN.FieldByName('PLACEID').Value;  
      iID := KRD_MAIN.FieldByName('ID').Value;
      sNBD := KRD_MAIN.FieldByName('NBD').Value;
      
      qryMaxG32.Params.ParamByName('ID').Value := iID;
      qryMaxG32.Active := true;
      iG32 := qryMaxG32.FieldByName('G32').Value; 
      qryMaxG32.Active := false; 
      
      dtDoDate :=  KRD_MAIN.FieldByName('BD_DATE').Value;
  end;             
                                                               
  ReadExcelCreatGoodsInDataBase(feFileExcelPath.Text, IntToStr(iPlaceid), IntToStr(iID), IntToStr(iG32), sNBD, dtDoDate); 
  
  if rbLoadToActiveDo.Checked then KRD_COMM.Refresh 
  else begin 
      KRD_MAIN.Refresh;
      KRD_MAIN.Locate('ID', iID, 0);
      KRD_COMM.Refresh;
  end;         
end;                                               
                                        
procedure rbHowCreateDoClick;   
begin                                                
  if rbCreateNewDO.Checked then begin 
      gbPlaceid.Visible := true  
      Height := Constraints.MaxHeight;
  end    
  else begin 
      gbPlaceid.Visible := false; 
      Height := Constraints.MinHeight;
  end;                        
end; 

procedure Form2Activate(Sender: TObject);
begin               
   sProgPath := ExtractFilePath(Application.ExeName);  
   Ini := TIniFile.Create(sProgPath + '\sts.ini'); 
   
   qryStores.Active := true;                           
   qryStores.Last;
   cxLicNo.EditValue := qryStores.FieldByName('LICENCENO').Value; 
   
   Height := Constraints.MinHeight;          
                                                  
   tcxWayBill.Text := '№ ТТН'; 
   refWayBillCode.Text := '02015';
   
   rbHowCreateDoClick; 
   
   btOk.Enabled := false;

end;                                           

procedure tcxWayBillEnter(Sender: TcxTextEdit);
begin
     if Sender.Text = '№ ТТН' then begin 
         Sender.Text := '';
         Sender.Style.TextColor := clBlack; 
     end;
end;

procedure tcxWayBillExit(Sender: TcxTextEdit);
begin
     if Sender.Text = '' then begin 
         Sender.Text := '№ ТТН';
         Sender.Style.TextColor := clGray; 
     end;                                   
end;


procedure cxBoxNoEnter(Sender: TcxTextEdit);
begin
   if Sender.Text = 'Место разм.' then begin 
       Sender.Text := '';
       Sender.Style.TextColor := clBlack; 
   end;     
end;

procedure cxBoxNoExit(Sender: TcxTextEdit);
begin
   if Sender.Text = '' then begin 
       Sender.Text := 'Место разм.';
       Sender.Style.TextColor := clGray;
   end;   
end;

procedure refWayBillCodeExit(Sender: TObject);
begin
  if refWayBillCode.Text='' then refWayBillCode.Text := '02015';
end;

procedure feFileExcelPathAfterDialog(Sender: TObject; var aText: string; var aAction: Boolean);
begin      
  if Pos('xlsx', aText) then begin 
      btOk.Enabled := true;
      feFileExcelPath.Style.TextColor := clBlack;
  end                                            
  else  btOk.Enabled := false;
end;

begin
end;
