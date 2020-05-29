{$FORM TMainForm, Unit2.sfm}                                                                    

uses
  Classes, Graphics, Controls, Forms, Dialogs, Mask, StdCtrls,
  FuncScript, SysUtils;

procedure MainForm_2Show(Sender: TObject);
begin
  cbxCreateDo1.Checked := ExecuteFuncScript('INIFILE ("WHInventoryDoc", "CreateDo1", "False")');
  mske_RegNumber.Text := STORES.Fields['CUSTOMS_CODE'].Value;    
//  mske_RegNumber.Text := STORES.Fields['CUSTOMS_CODE'].Value + '\' + FormatDateTime('DDMMYY', Date());
end;


procedure btnRequestInventoryClick(Sender: TObject);
var 
  slXml : TStringList;
  sIinPath, sUUID : String;
begin
  sUUID := ExecuteFuncScript('UserInfo("", "UserUUID")');
  sIinPath := ExtractFilePath(Application.ExeName) + 'STS-MED\iin\';
  if Length(sUUID) then 
    sIinPath := sIinPath + sUUID + '\';
    
  slXml := TStringList.Create;
  slXml.Add('<?xml version="1.0" encoding="windows-1251"?>');         
  slXml.Add('<InventoryRequest>' + mske_RegNumber.Text + '</InventoryRequest>');       
  slXml.SaveToFile(sIinPath + 'InventoryRequest_' + ExecuteFuncScript ('REPLACESTR ("' + mske_RegNumber.Text + '", "\", "-")') + '.xml');                 
  slXml.Free;

  ExecuteFuncScript('WRITEINIFILE ("WHInventoryDoc", "CreateDo1", "' + VarToStr(cbxCreateDo1.Checked) + '")');
  Close;
end;

procedure mske_RegNumberChange(Sender: TObject);
begin                                                            
  btnRequestInventory.Enabled := Length(Trim(mske_RegNumber.Text)) > 16;     
end;

begin                                                     
end;                                                                       
