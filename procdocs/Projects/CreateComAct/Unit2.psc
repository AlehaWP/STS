{$FORM TLinkGoods, Unit2.sfm}                                                                                                                                                                                       

uses
  Classes, Graphics, Controls, Forms, Dialogs, UniDB, DB, ADODB, 
  Menus, DBTables, cxGrid, cxGridBandedTableView, 
  cxGridCustomTableView, cxGridCustomView, 
  cxGridDBBandedTableView, cxGridLevel, Buttons, ExtCtrls, 
  StdCtrls;  
  
Var
//qryDOGoods : TTable;
qryKRD_COMM : TUniQuery;
UvCutJCHID : integer; 
iDOGoodsCount : integer;
iUVGoodsCount : integer; 
iPlaceID, iID, iG32 : integer; 
sSQL : string;
                                

procedure LinkGoodsActivate(Sender: TObject);
var                    
i, iNeedAdd : integer;   
iG32 : integer; 
begin 

     qryKRD_COMM := KRD_COMM;
     //UpQuery.SQL.Text := 'UPDATE GOODINFO2 SET G32=JOURNAL_CHILD_ID';// WHERE G32 IS NULL';
    // UpQuery.ExecSQL;                                                    
     qryUvGoods.Active := true;   
     With qryUvGoods.DataSet do begin
          First;
          iG32 := 0;
          While EOF=0 do begin 
               IF (FieldByName('G32').Value = NULL) or (FieldByName('G32').Value <> (iG32+1)) then begin
                  iG32 := iG32 + 1;
                  Edit;      
                  FieldByName('G32').Value := iG32;
                  Post;
               end
               else begin                         
                   iG32 := FieldByName('G32').Value;
               end;
                  
               Next;               
          end;                                   
     end;                                             
                  
     //qryDOGoods := KRD_COMM;
     //dsDOGoods.DataSet := qryDOGoods;
     cxGridDOGoodsG32.Focused:= true;
                                                      

     iUVGoodsCount := qryUvGoods.Recordcount;
     iDOGoodsCount := qryKRD_COMM.RecordCount; 
     
     qryTmpGoods.Active := true;
     iG32 := qryTmpGoods.FieldByName('G32Max').Value;
     IF iG32=Null then iG32 := 0;
     qryTmpGoods.Active := false; 
     showmessage (iG32);
     IF (iG32 < iUVGoodsCount) then 
     begin                               
          while iG32 <= iUVGoodsCount do begin  
               iG32 := iG32 + 1;
               sSQL := 'INSERT INTO KRD_COMM (PLACEID, ID, G32, G312) VALUES (5500,5500,'+IntToStr(iG32)+','+chr(39)+ 'Дополнительный' +chr(39)+')';                
               upQuery.SQL.Text := sSQL;                                                                    
               upQuery.ExecSQL;
          end;
          
     end;
    
     iPlaceID := qryKRD_COMM.FieldByName('PLACEID').Value; 
     iID := qryKRD_COMM.FieldByName('ID').Value;
                                             
     qryDOGoods.Params.ParamByName('iPlaceid').Value := iPlaceid;
     qryDOGoods.Params.ParamByName('iID').Value := iID;
     qryDOGoods.Params.ParamByName('iG32Count').Value := iDOGoodsCount;
     qryDOGoods.Params.ParamByName('iUvCount').Value := iUVGoodsCount; 
     
     qryDOGoods.Active := True;                           


     {  
     
     iUVGoodsCount := qryUvGoods.Recordcount; 
     iDOGoodsCount := qryDOGoods.RecordCount;      
     IF iDOGoodsCount < iUVGoodsCount then begin 
         i := 0;
         iNeedAdd := iUVGoodsCount-iDOGoodsCount;
         while i<iNeedAdd do begin
               qryDOGoods.DataSet.Insert; 
               qryDOGoods.FieldByName('G312').Value := 'Дополнительный'
               i := i + 1;
         end;
         
     end;
     }
end;                            

                      
procedure cxGrid1DBTableView1FocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
begin
     
end;

                              


                                     
procedure cxGrid1DBTableView1DragDrop(Sender, Source: TObject; X, Y: Integer);
begin                                                                     
  showmessage(1);
end;

procedure cxGrid1DBTableView1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  
end;

procedure PopupMenu1_NewItem1Click(Sender: TObject);
begin
  
end;

procedure DelDoGoodsFromCAClick(Sender: TObject);
begin 
     KRD_COMM.Filtered := false; 
//     KRD_COMM.Filter <> '' then KRD_COMM.Filter := KRD_COMM.Filter + ' AND '              
     KRD_COMM.Filter := 'G32<>'+IntToStr(KRD_COMM.FieldByName('G32').Value);
     KRD_COMM.Filtered := true;   
end;

procedure ShowAllGoodsClick(Sender: TObject);
begin
     KRD_COMM.Filtered := false; 
     KRD_COMM.Filter := '';  
end;

procedure ChangeNum (Goods1 : variant; Goods2 : Variant; iG32Goods1 : integer);
var                                                         
iG32Goods2 : integer                                                 
begin       
     WITH qryUvGoods.DataSet do begin  
          LOCATE('JOURNAL_MASTER_ID;JOURNAL_CHILD_ID',Goods2,0); 
          iG32Goods2 := FieldByName('G32').Value; 
          Edit;
          FieldByName('G32').Value := iG32Goods1;   
          Post;
          LOCATE('JOURNAL_MASTER_ID;JOURNAL_CHILD_ID',Goods1,0); 
          Edit;           
          FieldByName('G32').Value := iG32Goods2;
          Post;
          Active := false;                                      
          Active := true;  
          LOCATE('JOURNAL_MASTER_ID;JOURNAL_CHILD_ID',Goods1,0); 
     end;
end;


procedure btUpDownClick(Sender: TcxButton);
var 
ParamOfLocateGoods1 : Variant;
ParamOfLocateGoods2 : Variant;
iG32Goods1: integer; 
iUp, iDown : integer; 
begin
    IF Sender.Name = 'btUp' 
       then iUp:=1   
       else iUp:=0;  
       
       
     WITH qryUvGoods.DataSet do begin       
         IF (((iUp=1)*(BOF=false)) or 
            ((iUp=0)*(EOF=false))) then 
         begin  
            ParamOfLocateGoods1 := VarArrayCreate([0,1], 3); 
            ParamOfLocateGoods1[0]:=FieldByName('JOURNAL_MASTER_ID').Value;                             
            ParamOfLocateGoods1[1]:=FieldByName('JOURNAL_CHILD_ID').Value;
            iG32Goods1 := FieldByName('G32').Value;
            IF iUp 
               then Prior   
               else Next;  
            ParamOfLocateGoods2 := VarArrayCreate([0,1], 3);   
            ParamOfLocateGoods2[0]:=FieldByName('JOURNAL_MASTER_ID').Value;                             
            ParamOfLocateGoods2[1]:=FieldByName('JOURNAL_CHILD_ID').Value;              
                        
            ChangeNum (ParamOfLocateGoods1, ParamOfLocateGoods2, iG32Goods1);    
         end;                  
     end;  
end; 

procedure UvGoodsPopup_CutClick(Sender: TObject);
begin 
  UvCutJCHID := qryUvGoods.FieldByName('JOURNAL_CHILD_ID').Value;
  qryUvGoods.Filter := 'JOURNAL_CHILD_ID<>'+IntToStr(qryUvGoods.FieldByName('JOURNAL_CHILD_ID').Value);
  qryUvGoods.Filtered := true; 
end;

procedure UvGoodsPopup_PasteClick(Sender: TObject);
VAR 
iNowJMID : integer; 
iNowJCHID : integer; 
iNowG32 : integer;
begin
     qryUvGoods.Filtered := false;
     qryUvGoods.Filter := 'JOURNAL_CHILD_ID<>'+IntToStr(qryUvGoods.FieldByName('JOURNAL_CHILD_ID').Value);
      
     iNowJMID := qryUvGoods.FieldByName('JOURNAL_MASTER_ID').Value;  
     iNowJCHID := qryUvGoods.FieldByName('JOURNAL_CHILD_ID').Value;
     iNowG32 := qryUvGoods.FieldByName('G32').Value;
     qryUvGoods.Active := false;
                                                             
     UpQuery.SQL.Text := 'UPDATE GOODINFO2 SET G32='+IntToStr(iNowG32)+' WHERE JOURNAL_CHILD_ID ='+IntToStr(UvCutJCHID)+ ' AND JOURNAL_MASTER_ID='+IntToStr(iNowJMID);
     UpQuery.ExecSQL;                                                                                                                                               
                                                                                                                                                       
     UpQuery.SQL.Text := 'UPDATE GOODINFO2 SET G32='+IntToStr(iNowG32+1)+' WHERE JOURNAL_CHILD_ID ='+IntToStr(iNowJCHID)+ ' AND JOURNAL_MASTER_ID='+IntToStr(iNowJMID);
     UpQuery.ExecSQL;                                                                                                                                            
     
     UpQuery.SQL.Text := 'UPDATE GOODINFO2 SET G32=G32+1 WHERE  JOURNAL_MASTER_ID='+IntToStr(iNowJMID)+ ' AND G32>'+IntToStr(iNowG32)+' AND JOURNAL_CHILD_ID<>'+IntToStr(iNowJCHID);
     UpQuery.ExecSQL;                                                                                                                 
                                              
     qryUvGoods.Active := true;                                                                                                                                     
end;

procedure SelectUVClick(Sender: TObject);
begin
  
end;

procedure btChangeG32Click(Sender: TObject);
var
ParamOfLocateGoods1 : Variant;
ParamOfLocateGoods2 : Variant;
iG32Goods1: integer; 
begin
       WITH cxGrid1DBTableView1.Controller do       
          IF SelectedRecordCount = 2 then begin
             ParamOfLocateGoods1 := VarArrayCreate([0,1], 3);
             ParamOfLocateGoods1[0]:=SelectedRecords[0].Values[0];                             
             ParamOfLocateGoods1[1]:=SelectedRecords[0].Values[1];                                                 
             iG32Goods1 := SelectedRecords[0].Values[2];
             
             ParamOfLocateGoods2 := VarArrayCreate([0,1], 3);
             ParamOfLocateGoods2[0]:=SelectedRecords[1].Values[0];                             
             ParamOfLocateGoods2[1]:=SelectedRecords[1].Values[1]; 
                                                                                          
             ChangeNum (ParamOfLocateGoods1, ParamOfLocateGoods2, iG32Goods1); 
                                                                                   
          end
          else Showmessage ('Вsделенно <>2 товаров');
end;
                    
procedure cxGrid1DBTableView1TopRecordIndexChanged(Sender: TObject);
begin
  //showmessage(1);
    cxGridDOGoods.Controller.TopRecordIndex := cxGrid1DBTableView1.Controller.TopRecordIndex; 
end;

procedure cxGridDOGoodsTopRecordIndexChanged(Sender: TObject);
begin
    cxGrid1DBTableView1.Controller.TopRecordIndex := cxGridDOGoods.Controller.TopRecordIndex;
end;



begin           
                                                                                                                                              
end;    
