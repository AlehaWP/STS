{$FORM TForm2, Unit2.sfm}                                                                        

uses
  Classes, Graphics, Controls, Forms, Dialogs,
  FuncScript, SysUtils, StdCtrls;

var
  iPlaceId : Integer;
  sLicenceNo, sLicenceDate, sLicenceName : String;      
                                
procedure beLicenceNoPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var                      
  sScriptText : String;    
begin
  sScriptText := 'VAR ("vPlaceId", Integer); VAR ("vLicenceNo", String); VAR ("vLicenceDate", String); VAR ("vSvhName", String);' +
      'SELECTVALUES ("Выбор складской площадки", "STORES_2", [["LICENCENO", "№ лицензии", 25], ["STORE_NO", "№ склада", 30], ["NAME", "Название склада", 40]], [["PLACEID", "vPlaceId"], ["LICENCENO", "vLicenceNo"], ["LICENCEDATE", "vLicenceDate"], ["NAME", "vSvhName"]], "PLACEID", "STS_DB");' +
      'CONVERT (vPlaceId, String) + "|" + vLicenceNo + "|" + vLicenceDate +  "|" + vSvhName';      
  sScriptText := ExecuteFuncScript(sScriptText); 
  if length(sScriptText) > 4 then begin
    //showmessage (ExecuteFuncScript('EXTRACTSTR (' +chr(39)+ sScriptText +chr(39)+ ', 2, ' +chr(39)+ '|' +chr(39)+ ');'));
     iPlaceId := Int(ExecuteFuncScript('EXTRACTSTR (' +chr(39)+ sScriptText +chr(39)+ ', 1, ' +chr(39)+ '|' +chr(39)+ ');'));
     beLicenceNo.Text := ExecuteFuncScript('EXTRACTSTR (' +chr(39)+ sScriptText +chr(39)+ ', 2, ' +chr(39)+ '|' +chr(39)+ ');');  
     sLicencedate := ExecuteFuncScript('EXTRACTSTR (' +chr(39)+ sScriptText +chr(39)+ ', 3, ' +chr(39)+ '|' +chr(39)+ ');');
     lblLicenceDate.Caption := 'от ' + sLicenceDate;
     teLicenceName.Text := ExecuteFuncScript('EXTRACTSTR (' +chr(39)+ sScriptText +chr(39)+ ', 4, ' +chr(39)+ '|' +chr(39)+ ');');     
   end                                                                          
   else                                                                  
     Raise('Отменено пользователем');
end;                                             

procedure btnOKClick(Sender: TObject);
var
  sScriptText : String;
begin
  sScriptText := 'WRITEINIFILE ("2636pril3", "LicenceNo", "' + beLicenceNo.Text + '");' +
      'WRITEINIFILE ("2636pril3", "LicenceDate", "' + sLicenceDate + '");' +      
      'WRITEINIFILE ("2636pril3", "LicenceName", ' +chr(39)+ teLicenceName.Text +chr(39)+ ');' +         
      'WRITEINIFILE ("2636pril3", "PlaceId", "' + VarToStr(iPlaceId) + '");' +             
      'WRITEINIFILE ("2636pril3", "PersonFullName", "' + tePersonFullName.Text + '");' +
      'WRITEINIFILE ("2636pril3", "PersonPost", "' + tePersonPost.Text + '");' +
      'WRITEINIFILE ("2636pril3", "Directory", "' + deDirectory.Text + '");' +
      'WRITEINIFILE ("2636pril3", "ReportNumber", "' + beReportNumber.Text + '");';
  if dtBegin.Date > 0 then
    sScriptText := sScriptText + 'WRITEINIFILE ("2636pril3", "Begin", "' + FormatDateTime('DD.MM.YYYY', dtBegin.Date) + '");';
  if dtEnd.Date > 0 then   
    sScriptText := sScriptText + 'WRITEINIFILE ("2636pril3", "End", "' + FormatDateTime('DD.MM.YYYY', dtEnd.Date) + '");'; 
//  showmessage(sScriptText);                                                                       
  ExecuteFuncScript (sScriptText);
  
  // сохранили заданные параметры в INI-файл и вызываем скрипт, он оттуда их загрузит
  ExecuteFuncScriptFromFile(ExtractFilePath(Application.Name) + 'ProcDocs\2636pril3\2636pril3.prd');
end;

procedure Form2Create(Sender: TObject);
var 
  sScriptText : String;
begin
  iPlaceId := Int(ExecuteFuncScript ('INIFILE ("2636pril3", "PlaceId", 0)'));         
  beLicenceNo.Text := ExecuteFuncScript ('INIFILE ("2636pril3", "LicenceNo", "");');
  sLicenceDate := ExecuteFuncScript ('INIFILE ("2636pril3", "LicenceDate", "")');
  lblLicenceDate.Caption := 'от ' + sLicenceDate;
  teLicenceName.Text := ExecuteFuncScript ('INIFILE ("2636pril3", "LicenceName", "");');  
  dtBegin.Date := StrToDate(ExecuteFuncScript ('INIFILE ("2636pril3", "Begin", Date());'));
  dtEnd.Date := StrToDate(ExecuteFuncScript ('INIFILE ("2636pril3", "End", Date());'));  
  tePersonFullName.Text := ExecuteFuncScript ('INIFILE ("2636pril3", "PersonFullName", "");');
  tePersonPost.Text := ExecuteFuncScript ('INIFILE ("2636pril3", "PersonPost", "");');    
  deDirectory.Text := ExecuteFuncScript ('INIFILE ("2636pril3", "Directory", "")');       
  beReportNumber.Text := ExecuteFuncScript ('GENNO("Номер отчета по приказу №2636 прил. 3", "2636pril3")');
end;                                                                                                                                                                        

procedure beReportNumberPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  beReportNumber.Text := ExecuteFuncScript ('GENNO("Номер отчета по приказу №2636 прил. 3", "2636pril3")');
end;

begin                                                  
end;                                                                            
