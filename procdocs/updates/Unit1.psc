uses
  Classes, Graphics, Controls,
  FuncScript,
  WinInet, UrlMon, SysUtils, AnsiStrings;


const
  cUpdateIni = 'http://ftp.ctm.ru/INCOMING/STS/SCRIPTSUPDATE/update.ini';
  cUpdateZip = 'http://ftp.ctm.ru/INCOMING/STS/SCRIPTSUPDATE/update.zip';
  cPatchInfo = 'http://ftp.ctm.ru/INCOMING/STS/patchinfo.txt';
  cDefaultDate = '01.01.2020';

var
  sProgVersion, sUpdateIni, sUpdateZip, sUpdateAt, sPatchInfo : String;
  dtCurrentDate, dtUpdateDate : TDateTime;
  iCurrentUpdateVersion, iUpdateVersion : Integer;


function GetStsUpdateFile(sUrl:String): string;
var  sFileName, sFileExt : string;
begin
  Result := '';
  try
    sFileExt := ExtractFileExt(sUrl);
    if length(sFileExt) = 0 then sFileExt := '.txt';
    sFileName := IncludeTrailingBackslash(ExecuteFuncScript('TempDirectory ()')) + 'STS_UPDATE_' + ExecuteFuncScript('GENERATEUUID ()') + sFileExt;
    DeleteUrlCacheEntry(sUrl);
    URLDownloadToFile(nil, sUrl, sFileName, 0, nil);
    Result := sFileName;
  except
    Result := '';
  end;
end;


procedure ApplyPatch(pUpdateVersion: Integer; pUpdateAt: String);
begin
  sUpdateZip := GetStsUpdateFile (cUpdateZip);
  // ������ �������� ������ ���� ���� zip-�����
  if FileExists(sUpdateZip) then begin
    ExecuteFuncScript('ZIPEXTRACTFILE ("' + sUpdateZip + '", PROGRAMPATH ())');
    ExecuteFuncScript('WRITEINIFILE ("STS", "UpdateVersion", "' + IntToStr(pUpdateVersion) + '")');
    ExecuteFuncScript('WRITEINIFILE ("STS", "UpdateAt", "' + pUpdateAt + '")');
    sPatchInfo := GetStsUpdateFile (cPatchInfo);
    // ���� ������� �������� �������� ����������, �� ���������� ���
    if FileExists(sPatchInfo) then begin
      if length(pUpdateAt) > 0 then
        ExecuteFuncScript('SHOWMESSAGE (STRINGFROMFILE ("' + sPatchInfo + '"), 0, "����������� ���������� �� ' + pUpdateAt + '")')
      else
        ExecuteFuncScript('SHOWMESSAGE (STRINGFROMFILE ("' + sPatchInfo+ '"), 0, "����������� ����������")');
    end;
  end;
end;


begin
  sUpdateIni := GetStsUpdateFile (cUpdateIni);
  if FileExists(sUpdateIni) then begin
    // ����� ������ ��������� ���-�����
    sProgVersion := ExecuteFuncScript('INIFILE ("STS", "Version", "", INCLUDETRAILINGBACKSLASH (PROGRAMPATH ()) + "setup.ini")');

    // ������ ���������� �������������� ����������
    iCurrentUpdateVersion := Int(ExecuteFuncScript('INIFILE ("STS", "UpdateVersion", 0)'));
    // ���� ���������� �������������� ����������
    dtCurrentDate := ExecuteFuncScript('STRTODATE (INIFILE ("STS", "UpdateAt", "' + cDefaultDate + '"), "DD.MM.YYYY", ".")');

    // ������ �������� ����������
    iUpdateVersion := Int(ExecuteFuncScript('INIFILE ("' + sProgVersion + '", "UpdateVersion", 0, "' + sUpdateIni + '")'));
    // ���� �������� ����������
    sUpdateAt := ExecuteFuncScript('INIFILE ("' + sProgVersion + '", "UpdateAt", "' + cDefaultDate + '", "' + sUpdateIni + '")');
    dtUpdateDate  := ExecuteFuncScript('STRTODATE (INIFILE ("' + sProgVersion + '", "UpdateAt", "' + cDefaultDate + '", "' + sUpdateIni + '"), "DD.MM.YYYY", ".")');

    // ���� ��� ���������� ��� ������� ������ ���-�����
    if iUpdateVersion = 0 then begin
      ExecuteFuncScript('WRITEINIFILE ("STS", "UpdateVersion", "")');
      ExecuteFuncScript('WRITEINIFILE ("STS", "UpdateAt", "' + cDefaultDate + '")');
    end
    else begin
      // ���� ���� �������� ���������� � ����� update.ini ������ ���� ���������� �������������� ����������
      // ��� ������ ����, ��� � ���������,
      // �� ��������� ����
      if (StrToDate(dtUpdateDate) > StrToDate(dtCurrentDate)) then begin
        ApplyPatch(iUpdateVersion, sUpdateAt);
      end
      else if (StrToDate(dtUpdateDate) = StrToDate(dtCurrentDate)) and (iCurrentUpdateVersion < iUpdateVersion) then begin
        ApplyPatch(iUpdateVersion, sUpdateAt);
      end;
    end;
  end;
end;
