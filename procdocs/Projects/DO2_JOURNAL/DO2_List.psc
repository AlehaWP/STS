{$FORM TfrDO2List, DO2_List.sfm}                                           

uses
  Classes, Graphics, Controls, Forms, Dialogs, cxGrid, 
  cxGridBandedTableView, cxGridCustomTableView, 
  cxGridCustomView, cxGridDBBandedTableView, cxGridLevel, 
  UniDB, StdCtrls, DB, DBTables, EditDO2, Menus;
  
VAR                                    
   qryRel : TTable;
   qryRelComm : TTable; 
   frGoods : TfrRelGoods;
   
function FormConstruct(qryRelParam : TTable; qryRelCommParam : TTable):integer;
begin        
     IF  qryRelParam <> NULL then begin
         qryRel := qryRelParam;
         IF  qryRelCommParam <> NULL then
             qryRelComm := qryRelCommParam
         else 
             result := 0;
        // ds_Release.DataSet := qryRel.DataSet;                                
         result := 1;
         
     end                                  
     else result := 0;    
     
end;                                          



procedure frDO2ListActivate(Sender: TObject);
begin
  ds_Release.DataSet := qryRel;                                            
end;



procedure cxGrid1DBTableView1DblClick(Sender: TObject);
begin
     frGoods := TfrRelGoods.Create ('self'); 
     //qryRelComm.Active := false; 
     qryRelComm.Filter := 'ID='+IntToStr(qryRel.FieldByName('ID').Value)+ ' AND COUNTER='+IntToStr(qryRel.FieldByName('COUNTER').Value);
     qryRelComm.Filtered := true; 
     //qryRelComm.Active := true;
     Visible := false;
     frGoods.FormRelGoodsConstruct (qryRel, qryRelComm);
     frGoods.ShowModal; 
     Visible := true;
     qryRelComm.Filtered := false;
end;

begin
end;
