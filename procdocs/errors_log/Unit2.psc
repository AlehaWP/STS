{$FORM TMForm, Unit2.sfm}                                               

uses                                                                            
  Classes, Graphics, Controls, Forms, Dialogs, cxGrid,         
  cxGridBandedTableView, cxGridCustomTableView, 
  cxGridCustomView, cxGridDBBandedTableView, cxGridLevel, 
  UniDB, FuncScript, StdCtrls;
 
          
var
  sListId : String;

procedure FormShow(Sender: TObject);
begin

  qErrorsList.Active := True;
                                                    
  qErrorsList.Params['list_id'].Value := sListId;  
                                                
  qErrorsList.Reopen;            
end;                                     
     
procedure btnCloseClick(Sender: TObject);
begin
  Close;                                                   
end;                            

procedure LoadParams(InputParam : String);
begin
  sListId := InputParam;     
end;

procedure gdErrorsListDBTableView1CustomDrawCell(Sender: TcxCustomGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
begin
  Case AViewInfo.Item.Index of    
    2: begin
//      ACanvas.Canvas.Font.Style := [fsBold];    
    end;
    3: begin
      // красный $5b5af6, $737AFF, $aaaaff       
      Case VarToStr(AViewInfo.GridRecord.Values[6]) of
          'ОШ.': begin
            ACanvas.Brush.Color := $aaaaff;
          end;
          'ПР.': begin
            ACanvas.Brush.Color := $7eebfb;
          end;
          else begin
            ACanvas.Brush.Color := $aaaaff;
          end;
      end; // Case
    end;
    4: begin
      // зеленый $6FF7C9, $acffeb, $99f1bf
      ACanvas.Brush.Color := $99f1bf;    
    end;
  end;  // case
  
end;

procedure gdErrorsListDBTableView1CustomDrawGroupCell(Sender: TcxCustomGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableCellViewInfo; var ADone: Boolean);
begin
  ACanvas.Canvas.Font.Style := [fsBold];
end;

procedure MFormClose(Sender: TObject; var Action: TCloseAction);
var
  sSQL, sScript : string;  
begin                                            
  sSQL := 'DELETE FROM ERRORS_LIST WHERE LIST_ID=' +chr(39)+ sListId +chr(39); 
  sScript := 'EXECUTESQL ("STS_DB", "' + sSQL + '")';          
  ExecuteFuncScript(sScript);  
end;

procedure MFormCreate(Sender: TObject);
begin

  if Height > Screen.Height then Height := Screen.Height;
  if Width > Screen.Width then Width := Screen.Width;

  WindowState := wsMaximized;

end;

begin       
end;
