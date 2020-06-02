{$FORM TForm2, Unit2.sfm}                      

uses
  Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, IdTCPConnection,IdHTTP, Registry;
 

const
  REGSTR_InternetSettings = 'Software\Microsoft\Windows\CurrentVersion\Internet Settings';
  KEY_READ = 131097;
  HKEY_CURRENT_USER = -2147483647;

function SplitStr(St : string; var Str1, Str2 : string;
        SepChar: string): Boolean;
var
  i : Integer;
begin     
  i := Pos(SepChar, St);
  Result := i > 0;
  if Result then begin
    Str1 := Copy(St, 1, i - 1);
    Str2 := Copy(St, i + Length(SepChar), Length(St));
  end else begin      
    Str1 := St;
    Str2 := St
  end
end;

function GetProxyServerParams(var aServerHttpAddr, aServerHttpPort: string): Boolean;
begin
  aServerHttpAddr := ''; aServerHttpPort := '';
  with TRegistry.Create do try 
    Access := KEY_READ;        
    RootKey := HKEY_CURRENT_USER;
    if OpenKey(REGSTR_InternetSettings, False) then try
      if ValueExists('ProxyEnable') and ReadBool('ProxyEnable') and ValueExists('ProxyServer') then begin
        with TStringList.Create do try
          Delimiter := ';';
          DelimitedText := ReadString('ProxyServer');
          if Count > 0 then begin
            if Count = 1 then
              SplitStr(Strings[0], aServerHttpAddr, aServerHttpPort, ':')
            else if IndexOfName('http') <> -1 then
              SplitStr(Values['http'], aServerHttpAddr, aServerHttpPort, ':')
          end
        finally
          Free
        end
      end
    finally
      CloseKey
    end 
  finally
    Free
  end;
 
  Result := (aServerHttpAddr <> '') and (aServerHttpPort <> '')

end;



procedure Button1Click(Sender: TObject);
var
  a: TidHTTP;                       
  LoadStream: TMemoryStream;
  ServerHttpAddr, ServerHttpPort : string; 
begin                                 
  LoadStream := TMemoryStream.Create;
  try
    a := TidHTTP.Create (Application);
    a.HandleRedirects := True;
    a.InitSecureChannel(True); 
    IF GetProxyServerParams(ServerHttpAddr, ServerHttpPort) then begin
       a.InitHttpProxyParams(ServerHttpAddr, ServerHttpPort, 'a.nerchenko@ctm.ru', 'rfgh');
       a.Get('https://download.teamviewer.com/download/TeamViewer_Setup_ru.exe', LoadStream);  
    end;
    LoadStream.SaveToFile('c:\ctm\test3.exe');
  finally                                          
    LoadStream.Free
  end                  
end;

begin
end;                                                                                           
