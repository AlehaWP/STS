{$FORM TfrDODocsDtDocs, Unit3.sfm}                                           

uses
  Classes, Graphics, Controls, Forms, Dialogs, cxGrid, 
  cxGridBandedTableView, cxGridCustomTableView, 
  cxGridCustomView, cxGridDBBandedTableView, cxGridLevel, 
  UniDB;

procedure DODtDocsConstract(pID,pJMID:integer);
begin
  qryDO1Doc.Params.ParamByName('ID').Value:=pID;
  qryDTDoc.Params.ParamByName('JMID').Value:=pJMID; 
  qryDO1Doc.Active := true;  
  if (pJMID <> 0) and (pJMID <> Null) then  
  qryDTDoc.Active := true;

end;    

    
procedure cxGrid1DBTableView1CustomDrawCell(Sender: TcxCustomGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
begin
     if (qryDTDoc.DataSet.IsEmpty = false) and  (AViewInfo.GridRecord.Values[0]<>'') and (AViewInfo.GridRecord.Values[0]<>Null) then begin
         if qryDTDoc.Locate('PrDocumentNumber', AViewInfo.GridRecord.Values[0], 0) then 
             ACanvas.Brush.Color := $c1ffb2; 
         else                   
             ACanvas.Brush.Color := $A0B0FF;
     end;    
end;          

begin
end;                       
