{$FORM TfrRelGoods, EditDO2.sfm}                                          

uses
  Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, DB, 
  DBTables, cxGrid, cxGridBandedTableView, cxGridCustomTableView, 
  cxGridCustomView, cxGridDBBandedTableView, cxGridLevel;

VAR 
qryRelease : TTable;
qryReleaseGoods : TTable; 

//Функция сохранения данных                           
Procedure PostDataSet(qryParam: TUniQuery);
begin                                                                                                                       
     //RecordCount на БД SQL периодически подглючивает
     IF (qryParam <> NULL) and (qryParam.DataSet.IsEmpty  = false) then                                                       
        IF (qryParam.DataSet.State = 2) or (qryParam.DataSet.State = 3) then           
           qryParam.Dataset.Post;                   
                 
end; 

                     
function FormRelGoodsConstruct(qryRel2Param : TTable; qryRel2CommParam : TTable):integer;
begin        
     qryRelease := qryRel2Param;
     qryReleaseGoods :=qryRel2CommParam;             
      
end; 
                                    
procedure frRelGoodsActivate(Sender: TObject);
begin
    ds_ReleaseGoodsFrorm.DataSet :=  qryRelease; 
    qryRelGoods.Params.ParamByName('iPLCID').Value := qryRelease.FieldByName('PLACEID').Value;
    qryRelGoods.Params.ParamByName('iID').Value := qryRelease.FieldByName('ID').Value;
    qryRelGoods.Params.ParamByName('iCounter').Value := qryRelease.FieldByName('COUNTER').Value;
    qryRelGoods.Active := true;

    ds_EditRelGoods.DataSet := qryReleaseGoods;
end;

procedure cxSaveDO2Click(Sender: TObject);
begin                  
     PostDataSet (qryRelease);
     PostDataSet (qryReleaseGoods);
     qryRelGoods.Active := false; 
end;

procedure cxBtCancelDO2Click(Sender: TObject);
begin
  //   qryRelGoods.Cancel;
     qryRelGoods.Active := false;
end;

procedure cxGrid1DBTableView1CellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
     qryReleaseGoods.Locate('G32', qryRelGoods.FieldByName('G32').Value,''); 
end;

procedure UpdateqryRelGoods;
begin             
     PostDataSet (qryReleaseGoods);  
     //showmessage (1); 
     //qryRelGoods.Close;
     //qryRelGoods.Open;        
     //ds_RelGoods.DataSet := qryRelGoods;
end;

begin
end;
