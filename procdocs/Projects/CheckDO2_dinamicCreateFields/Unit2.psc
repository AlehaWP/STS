{$FORM TForm2, Unit2.sfm}                                                         

uses
  Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, DB, 
  DBTables, cxGrid, cxGridBandedTableView, cxGridCustomTableView, 
  cxGridCustomView, cxGridDBBandedTableView, cxGridLevel, 
  UniDB, ADODB, Menus, ExtCtrls, Buttons, ComCtrls;
         
var
iElementCounter : integer;

procedure SetGbGoodsProp( ElementName : TcxGroupBox; ElementParent : TcxGroupBox; 
                             iAlign: integer; iTabOrder : integer; iHeight: integer; sCaption : string);
begin
    with ElementName do begin  
        Parent :=ElementParent;  
        AlignWithMargins := True
        Left := 597
        Top := 20
        Hint := ''         
        Align := iAlign
        Caption := sCaption
        ParentBackground := False
        ParentColor := False
        TabOrder := iTabOrder                                       
        Height := iHeight                                          
        Width := 180      
    end
end;  

procedure CreateGbDescriptionFields(ElementParent : TcxGroupBox; sText : string);
VAR 
Memo : TcxMemo;
begin
    Memo := TcxMemo.Create(ElementParent);
    with Memo do begin 
        Parent := ElementParent
        Left := 3
        Top := 17
        Hint := ''
        Align := alClient     
        Lines.Text := sText
        ParentColor := True
        Properties.ScrollBars := ssVertical
        Style.BorderColor := 15461611
        TabOrder := 0
        Height := 53
        Width := 579
    end;                     
    //cxMemo1.Lines.
end; 

procedure CreateTextEdit(ElementParent : TcxGroupBox; sText : string; sLabelText : string; iTop : integer; iTabOrder : integer);
VAR 
    edtLabel : TcxLabel;
    edtField : TcxTextEdit;
begin                     
    edtLabel := TcxLabel.Create(ElementParent);
    edtField := TcxTextEdit.Create(ElementParent);                                                                               
    with edtLabel do begin   
        Parent := ElementParent
        AlignWithMargins := True
        Left := 8
        Top := iTop
        Hint := ''
        Margins.Right := 10
        AutoSize := False
        Caption := sLabelText
        Properties.Alignment.Horz := taRightJustify
        Properties.Alignment.Vert := taCenter
        TabStop := False
        ParentFont := true
        Height := 23
        Width := 41   
    end;         
    with edtField do begin  
        Parent := ElementParent 
        Left := 54       
        Top := iTop
        Hint := ''
        AutoSize := False
        ParentColor := True
        Properties.Alignment.Horz := taRightJustify 
        ParentFont := true
        TabOrder := iTabOrder
        Text := sText
        Height := 23
        Width := 121    
    end;        
end;                   
              
procedure CreateGbGoodsFields(ElementParent : TcxGroupBox; sTextDO2 : string; sTextDT : string);
begin                                                                 
    CreateTextEdit(ElementParent, sTextDO2, 'ДО2', 19,0);
    CreateTextEdit(ElementParent, sTextDT, 'ДТ', 45,1);
end;           
     
procedure CreateGoodsGrid;
var
gbGoods, gbDescription, gbWeight, gbCost :  TcxGroupBox;
begin  
    gbGoods := TcxGroupBox.Create(GoodsScroll); 
    gbDescription := TcxGroupBox.Create(gbGoods);
    gbWeight := TcxGroupBox.Create(gbGoods);
    gbCost := TcxGroupBox.Create(gbGoods);
  
    SetGbGoodsProp(gbGoods,GoodsScroll, alTop, 0, 113,'Товар');
    SetGbGoodsProp(gbDescription,gbGoods, alClient, 0, 80,'Описание товара'); 
    SetGbGoodsProp(gbWeight,gbGoods, alRight, 1, 80, 'Вес'); 
    SetGbGoodsProp(gbCost,gbGoods, alRight, 2, 80, 'Стоимость'); 
    
    CreateGbDescriptionFields(gbDescription, 'Код товара и т.д. и т.п.'); 
    CreateGbGoodsFields (gbWeight,'Вес ДО2','Вес ДТ');  
    CreateGbGoodsFields (gbCost, 'Стоимость ДО2','Стоимость ДТ');      
end;          
                                                    
procedure Form2Activate(Sender: TObject);                                         
begin                   
  qryRC.Active := true;
  iElementCounter := 0;
   CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;
  CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;
  CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;
  CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;    
   CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;
  CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;
  CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;
  CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;  
   CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;
  CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;
  CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;
  CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;  
   CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;
  CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;
  CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;
  CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;  
   CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;
  CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;
  CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;
  CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;  
   CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;
  CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;
  CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;
  CreateGoodsGrid; 
  CreateGoodsGrid;
  CreateGoodsGrid;   
  
end;              
                         
procedure Form2Show(Sender: TObject);
begin
  
end;

begin  
end;                                                                                          
