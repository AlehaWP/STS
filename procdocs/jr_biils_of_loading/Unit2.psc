{$FORM TfrmBillOfLoading, Unit2.sfm}                                                                                                                                                                     

uses
  Classes, Graphics, Controls, Forms, Dialogs,
  XmlDoc, XMLIntf, StdCtrls, SysUtils;

var
  XmlDocument: TXMLDocument;
  Node, BillofLadingNode, parentNode, ChildNode : TXMLNode;
  

procedure btnSaveClick(Sender: TObject);
var
  parentNode : TXMLNode;
begin                   
//  XmlDocument := NewXMLDocument;
  XMLDocument := TXMLDocument.Create(nil);                                  
                                  
  try                    
    XMLDocument.Options := XMLDocument.Options + doNodeAutoIndent;  
    XMLDocument.Active := True;                                      
    BillofLadingNode := XMLDocument.Node.AddChild('bol:BillofLading');                                               
    BillofLadingNode.DeclareNamespace('bol', 'urn:customs.ru:Information:TransportDocuments:Sea:BillofLading:5.12.0');
    BillofLadingNode.DeclareNamespace('cat_ru', 'urn:customs.ru:CommonAggregateTypes:5.10.0');
    BillofLadingNode.DeclareNamespace('catTrans_ru', 'urn:customs.ru:Information:TransportDocuments:TransportCommonAgregateTypesCust:5.12.0');    
    BillofLadingNode.Attributes['DocumentModeID'] := '1003202E';
    parentNode := BillofLadingNode.AddChild('bol:RegistrationDocument');
    parentNode.AddChild('cat_ru:PrDocumentName').NodeValue := 'ÊÎÍÎÑÀÌÅÍÒ';         
    parentNode.AddChild('cat_ru:PrDocumentNumber').NodeValue := teBOL_Number.Text;                 
    if deBOL_Date.GetTextLen > 0 then                                             
      parentNode.AddChild('cat_ru:PrDocumentDate').NodeValue := FormatDateTime ('YYYY-MM-DD', deBOL_Date.Date);         
    
    XMLDocument.SaveToFile('D:\TEMP\BillOfLoading.xml');              
  finally                                                        
    XMLDocument.Free; 
  end;
end;
         
function FormatXmlDate(DateStr : String): TDateTime;
begin         
  result := EncodeDate(StrToIntDef(copy(DateStr, 0, 4), 0), StrToIntDef(copy(DateStr, 6, 2), 0), StrToIntDef(copy(DateStr, 9, 2), 0))
end;
                                                                                                 
procedure frmBillOfLoadingCreate(Sender: TObject);
var 
  i : Integer;
  fmt : TFormatSettings; 
  test : IXMLNode;
begin
  XMLDocument := TXMLDocument.Create(nil);  
  
  try
    XMLDocument.LoadFromFile('D:\TEMP\BillOfLoading.xml');
    BillofLadingNode := XmlDocument.Node;         
    parentNode := BillofLadingNode.ChildNodes[0].ChildNodes[0];
//    parentNode.
//    test := XmlDocument.ChildNodes.FindNode('bol:RegistrationDocument');    
//    showmessage (test.ChildNodes.FindNode('cat_ru:PrDocumentName'));                                            
//    teBooking_Number.Text := parentNode.GetChildNode('cat_ru:PrDocumentName');
    if parentNode then
      begin                                                                       
//        teBooking_Number.Text := parentNode.NodeName;                                                              
        showmessage (parentNode.ChildNodes[1].NodeName);
        showmessage (parentNode.GetChildValue('cat_ru:PrDocumentNumber'));
        teBOL_Number.Text := parentNode.GetChildValue(1);                                                                                             
        if Length(parentNode.GetChildValue(2)) > 0 then  
          deBOL_Date.Date := FormatXmlDate(parentNode.GetChildValue(2));                                                
      end;
  finally                                                            
    XMLDocument.Free; 
  end;                 
end;          

begin
end;                                                                 
