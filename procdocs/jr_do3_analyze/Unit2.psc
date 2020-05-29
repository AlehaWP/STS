{$FORM TForm2, Unit2.sfm}                            

uses
  Classes, Graphics, Controls, Forms, Dialogs, UniDB, cxGrid, 
  cxGridBandedTableView, cxGridCustomTableView, 
  cxGridCustomView, cxGridDBBandedTableView, cxGridLevel, 
  ExtCtrls, StdCtrls,
  FuncScript; 
  
var 
  PLACEID : Integer;
 
procedure Form2Show(Sender: TObject);
begin           
  qDO3.Database := 'Database';
  qDO3.DatabaseName := 'STS_DB';
  qDO3.Params.ParamByName('placeid').Value := PLACEID; 
  qDO3.Active := True;
  btnOpenDocument.Enabled := qDO3.RecordCount > 0;
end;

procedure btnOpenDocumentClick(Sender: TObject);
var 
  sScript : String;
begin
  sScript := 'STSDOCUMENTEDIT (1, ' + qDO3.FieldByName('PLACEID').AsString + ',' + qDO3.FieldByName('ID').AsString + ', 0);';
  ExecuteFuncScript (sScript);
end;

procedure cxGrid1DBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  btnOpenDocumentClick(Sender);  
end;

begin
end;
