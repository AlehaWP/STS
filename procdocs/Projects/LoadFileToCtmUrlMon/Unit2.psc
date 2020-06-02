{$FORM TForm2, Unit2.sfm}                      

uses
  Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, UrlMon, WinInet, ShellApi, SysUtils, FuncScript;
 
                                                                                     

procedure LoadFileFromUrlToFolder (sUrl: string; sFolderForSave : string); 
Var                                                                                          
 res : integer;
 sFileName : string;
begin
     //�������� ��� ������������, ����� ��������� ����
     With TStringList.Create do
     begin
         Delimiter := '/';
         DelimitedText := sUrl; 
         IF Count > 0 then
            sFileName := Strings [Count-1];     
     end;
     IF (sFileName <> '') and (sFileName <> Null) then 
     begin 
         sFolderForSave := IncludeTrailingPathDelimiter(sFolderForSave)
         ForceDirectories(sFolderForSave);  
         sFileName := sFolderForSave  + sFileName;
         
         //���� ���� ��� ����, �� ��������� 
         IF FileExists(sFileName) then   
            res := 0       
         else begin         
            //������� ��� IE ����� ���������, ����� ������ ��� ����� �� ������
            DeleteUrlCacheEntry(sUrl);
            res := URLDownloadToFile(nil,sUrl,sFileName, 0,nil); 
         end;
         
         //���� �� ���� ������� � ��������� �������� ������� ����
         If res = 0 then                                                                                                                                                            
             IF FileExists(sFileName) then ShellExecute(Handle, 'Open', sFileName, nil, nil, 5)
         else 
             MessageDlg('������ ��������', 1, 0, nil);
     end
     else MessageDlg('�� ������ URL', 0, 0, nil);                              
end;                                     
                                                              
procedure Button1Click(Sender: TObject);
begin      
     LoadFileFromUrlToFolder('http://ftp.ctm.ru/ctm/SUPPORT/TeamViewerQS_ru.exe', ExecuteFuncScript('PROGRAMPATH()')+'Download');
end;

begin                                                                                                                                  
end;  
                                                                                        
