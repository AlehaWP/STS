{$FORM TfrSelectGoods, AddUv.sfm}                                                                                                                     

uses
  Classes, Graphics, Controls, Forms, Dialogs, cxGrid, 
  cxGridBandedTableView, cxGridCustomTableView, 
  cxGridCustomView, cxGridDBBandedTableView, cxGridLevel, 
  StdCtrls, System, UniDB;

VAR 
{qryBID_GOODS_ForAdd : TUniQuery;                   
qryGateBid : TUniQuery;
//dsWBLGOODS  : TUniDataSource;   
iJMIDGateBid  : integer;
iJournalChildID : integer;
ParamOfLocate : variant;
 
Procedure FormConstruct (qryParamBid : TUniQuery; qryParamBidGoods : TUniQuery);
Begin                                                          
      
     qryBID_GOODS_ForAdd := qryParamBidGoods;
     qryGateBid := qryParamBid; 
     iJMIDGateBid := qryParamBid.FieldByName('JOURNAL_MASTER_ID').Value;
 
                                                                                               
end;                                      


procedure frSelectGoodsActivate(Sender: TObject);
begin
     qryWBLGoods.Params.ParamByName('iFID').Value := qryGateBid.FieldByName('FORWARDER_ID').Value;  
                                                             
     qryWBLGoods.Active := true;      
                                                       
end;  

procedure AddGoods; 
VAR
iBidChildNO :integer;     
qryMax_BIDGOODS : TUniQuery; 
begin 
                                     
                WITH qryBID_GOODS_ForAdd.DataSet do begin 
                     qryMax_BIDGOODS := TUniQuery.Create (Self);
                     qryMax_BIDGOODS.DataBaseName := 'dbJournals';
                     qryMax_BIDGOODS.SQL.Text := 'SELECT MAX(JOURNAL_CHILD_ID) as JOURNAL_CHILD_ID FROM GATE_BID_GOODS WHERE JOURNAL_MASTER_ID=:iID';
                     qryMax_BIDGOODS.Params.ParamByName('iId').Value := iJMIDGateBid;             
                     qryMax_BIDGOODS.Active := true;                                     
                                                                                
                     iBidChildNO:= qryMax_BIDGOODS.FieldByName('JOURNAL_CHILD_ID').Value + 1;
                                    
                     IF iBidChildNO = NULL then iBidChildNO:=1;       
                     qryMax_BIDGOODS.DataSet.Close;
                         
                     Insert;                                                     
                                                                                           
                     FieldByName('JOURNAL_MASTER_ID').VALUE := iJMIDGateBid; 
                     FieldByName('JOURNAL_CHILD_ID').VALUE := iBidChildNO;   
                     FieldByName('WBL_NO').VALUE :=  qryWBLGoods.FieldByName('WBL_NO').Value; 
                     FieldByName('PARTS_NO').VALUE := qryWBLGoods.FieldByName('PARTS_NO').Value;
                     FieldByName('CARGO_NO').VALUE :=  qryWBLGoods.FieldByName('CARGO_NO').Value;
                     FieldByName('NPP_IN_WBL').VALUE :=  qryWBLGoods.FieldByName('JCHID').Value; 
                     FieldByName('NAME_CARGO').VALUE :=  qryWBLGoods.FieldByName('NAME_CARGO').Value;
                     FieldByName('UNIT_TYPE').VALUE :=  qryWBLGoods.FieldByName('UNIT_TYPE').Value;
                     FieldByName('BRUTTO').VALUE :=  qryWBLGoods.FieldByName('BRUTTO_REST').Value;          
                     FieldByName('QTY_PLACE').VALUE :=  qryWBLGoods.FieldByName('QTY_PLACE_REST').Value;
                     FieldByName('WIDTH').VALUE :=  qryWBLGoods.FieldByName('WIDTH').Value;          
                     FieldByName('HEIGHT').VALUE :=  qryWBLGoods.FieldByName('HEIGHT').Value; 
                     FieldByName('LENGTH').VALUE :=  qryWBLGoods.FieldByName('LENGTH').Value;          
                     FieldByName('VOLUME').VALUE :=  qryWBLGoods.FieldByName('VOLUME').Value;
                     FieldByName('SEAL').VALUE :=  qryWBLGoods.FieldByName('SEAL_FACT').Value;
                     FieldByName('TC_NUM').VALUE :=  qryWBLGoods.FieldByName('TC_NUM_FACT').Value;
                     FieldByName('VIN').VALUE :=  qryWBLGoods.FieldByName('VIN_FACT').Value;
                     FieldByName('RT_NUM').VALUE :=  qryWBLGoods.FieldByName('RT_NUM_FACT').Value;
                     FieldByName('RT_WEIGHT').VALUE :=  qryWBLGoods.FieldByName('RT_WEIGHT').Value;
                     FieldByName('RT_TYPE').VALUE :=  qryWBLGoods.FieldByName('RT_TYPE').Value;
                     FieldByName('RT_SIZE').VALUE :=  qryWBLGoods.FieldByName('RT_SIZE').Value;  
                     FieldByName('TRAILER_NO').VALUE :=  qryWBLGoods.FieldByName('TRAILER_NO').Value;
                     FieldByName('REMARK').VALUE :=  qryWBLGoods.FieldByName('REMARK').Value;
                     FieldByName('DAMAGES').VALUE :=  qryWBLGoods.FieldByName('DAMAGES').Value;
                     FieldByName('DANGER_CLASS').VALUE :=  qryWBLGoods.FieldByName('DANGER_CLASS').Value;
                     FieldByName('TEMP_MODE').VALUE :=  qryWBLGoods.FieldByName('TEMP_MODE').Value;
                     FieldByName('WH_PLACE_NO').VALUE :=  qryWBLGoods.FieldByName('WH_PLACE_NO').Value;  
                     FieldByName('VES_NAME').VALUE :=  qryWBLGoods.FieldByName('VES_NAME').Value;
                     FieldByName('VOYAGE').VALUE :=  qryWBLGoods.FieldByName('VOYAGE').Value;
                     FieldByName('MARKING').VALUE :=  qryWBLGoods.FieldByName('MARKING').Value;
                     FieldByName('CONT_NO').VALUE :=  qryWBLGoods.FieldByName('CONT_NO_FACT').Value; 
                     FieldByName('WBL_DATE').VALUE := qryWBLGoods.FieldByName('WBL_DATE').Value;
                     // FieldByName('DOC_OUT_NAME').VALUE :=  cxDOC_OUT_NAME.Text; 
                     FieldByName('DOC_OUT_NO').VALUE := qryWBLGoods.FieldByName('DECL_NUM').Value;      
                                                                          
                     //  IF cxDOC_OUT_DATE.Date>0 then FieldByName('DOC_OUT_DATE').VALUE := cxDOC_OUT_DATE.Date;                     
                                                       //showmessage(qryWBLGoods.FieldByName('CARGO_NO').VALUE); 
                     Post;                                   
             end;        
end;
                              
procedure AddGoodsToBid;
Var                                                                     
i:integer;  
begin         
                                                          
     WITH cxPartGoodsDBTableView1.Controller do
          IF SelectedRecordCount > 0 then begin 
              For i:=0 to (SelectedRecordCount-1) do                                
              begin
                   ParamOfLocate := VarArrayCreate([0,1], varVariant);
                   ParamOfLocate[0]:=SelectedRecords[i].Values[0];                             
                   ParamOfLocate[1]:=SelectedRecords[i].Values[1];                                                 
                          
                   qryWBLGoods.DataSet.LOCATE('Parts_NO;Cargo_NO', ParamOfLocate,0);   
                                                                                          
                   AddGoods; 
                                                                                   
              end;                                                                                                                                                             
         end                                            
         else AddGoods; 
end;

procedure BtGetGoodsClick(Sender: TObject); 
begin 
    AddGoodsToBid; 
end;                     





procedure cxPartGoodsDBTableView1DblClick(Sender: TObject);
begin
     BtGetGoodsClick(BtGetGoods); 
     ModalResult := mrOk;
end;
   }
begin
end;
