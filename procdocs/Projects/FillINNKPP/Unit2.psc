{$FORM TForm2, Unit2.sfm}                                                                                                       

uses
  Classes, Graphics, Controls, Forms, Dialogs, cxGrid, 
  cxGridBandedTableView, cxGridCustomTableView, 
  cxGridCustomView, cxGridDBBandedTableView, cxGridLevel, UniDB, 
  DB, DBTables, Menus, StdCtrls;
var
sG082 : string; 

Procedure PostDataSet(qryParam: TQuery);
begin                                                                                                                       
     //RecordCount на БД SQL периодически подглючивает
     IF (qryParam <> NULL) and (qryParam.IsEmpty  = false) then                                                       
        IF (qryParam.State = 2) or (qryParam.State = 3) then           
           qryParam.Post;                   
                 
end; 

procedure UpEdit;
begin
     cxINN.Text := qryG082.FieldByName('G084C').Value; 
     cxKPP.Text := qryG082.FieldByName('G08_KPP').Value;  
end;
                                   
                                          
procedure UpData(g082Param : string; iLoc : integer);
begin
     sG082 := g082Param;
     upKRD_MAIN.SQL.Text := 'UPDATE KRD_MAIN SET G084C='+ chr(39) +cxINN.Text+ chr(39) +', G08_KPP='+ chr(39) +cxKPP.Text+ chr(39) +' WHERE G082='+ chr(39) +g082Param + chr(39);
     upKRD_MAIN.ExecSQL; 
     qryG082.Active := false;
     qryG082.Active := true;
     IF iLoc = 1 then begin   
        qryG082.Locate('G082',g082Param,0);  
     end;      
end;  

procedure Form2Activate(Sender: TObject);
begin
    qryG082.Active := true;
    UpEdit;
    sG082 := qryG082.FieldByName('G082').Value;
end; 

procedure cxNextClick(Sender: TObject);
begin
     UpData(sG082,1)
     qryG082.Next; 
     UpEdit; 
     sG082 := qryG082.FieldByName('G082').Value;
end;
 
procedure cxButton2Click(Sender: TObject);
begin
     UpData(sG082,1);
     qryG082.Prior;
     UpEdit;
     sG082 := qryG082.FieldByName('G082').Value;
end;

procedure cxGrid1DBTableView1CellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
sNewG082 : string;
begin 
     //showmessage (qryG082.FieldByName('G082').Value);
     sNewG082 := qryG082.FieldByName('G082').Value;
     UpData(sG082, 0); 
     
     qryG082.Locate('G082',sNewG082,0);
     UpEdit; 
     sG082 := qryG082.FieldByName('G082').Value;        
end;

begin 
end;
