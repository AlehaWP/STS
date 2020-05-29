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
  // дальше работаем только если есть zip-архив
  if FileExists(sUpdateZip) then begin
    ExecuteFuncScript('ZIPEXTRACTFILE ("' + sUpdateZip + '", PROGRAMPATH ())');
    ExecuteFuncScript('WRITEINIFILE ("STS", "UpdateVersion", "' + IntToStr(pUpdateVersion) + '")');
    ExecuteFuncScript('WRITEINIFILE ("STS", "UpdateAt", "' + pUpdateAt + '")');
    sPatchInfo := GetStsUpdateFile (cPatchInfo);
    // если удалось получить описание обновления, то показываем его
    if FileExists(sPatchInfo) then begin
      if length(pUpdateAt) > 0 then
        ExecuteFuncScript('SHOWMESSAGE (STRINGFROMFILE ("' + sPatchInfo + '"), 0, "Оперативное обновление от ' + pUpdateAt + '")')
      else
        ExecuteFuncScript('SHOWMESSAGE (STRINGFROMFILE ("' + sPatchInfo+ '"), 0, "Оперативное обновление")');
    end;
  end;
end;


begin
  sUpdateIni := GetStsUpdateFile (cUpdateIni);
  if FileExists(sUpdateIni) then begin
    // номер версии программы ВЭД-Склад
    sProgVersion := ExecuteFuncScript('INIFILE ("STS", "Version", "", INCLUDETRAILINGBACKSLASH (PROGRAMPATH ()) + "setup.ini")');

    // версия последнего установленного дополнения
    iCurrentUpdateVersion := Int(ExecuteFuncScript('INIFILE ("STS", "UpdateVersion", 0)'));
    // дата последнего установленного дополнения
    dtCurrentDate := ExecuteFuncScript('STRTODATE (INIFILE ("STS", "UpdateAt", "' + cDefaultDate + '"), "DD.MM.YYYY", ".")');

    // версия текущего дополнения
    iUpdateVersion := Int(ExecuteFuncScript('INIFILE ("' + sProgVersion + '", "UpdateVersion", 0, "' + sUpdateIni + '")'));
    // дата текущего дополнения
    sUpdateAt := ExecuteFuncScript('INIFILE ("' + sProgVersion + '", "UpdateAt", "' + cDefaultDate + '", "' + sUpdateIni + '")');
    dtUpdateDate  := ExecuteFuncScript('STRTODATE (INIFILE ("' + sProgVersion + '", "UpdateAt", "' + cDefaultDate + '", "' + sUpdateIni + '"), "DD.MM.YYYY", ".")');

    // если нет обновлений для текущей версии ВЭД-Склад
    if iUpdateVersion = 0 then begin
      ExecuteFuncScript('WRITEINIFILE ("STS", "UpdateVersion", "")');
      ExecuteFuncScript('WRITEINIFILE ("STS", "UpdateAt", "' + cDefaultDate + '")');
    end
    else begin
      // если дата текущего дополнения в файле update.ini больше даты последнего установленного дополнения
      // или версия выше, чем в программе,
      // то скачиваем патч
      if (StrToDate(dtUpdateDate) > StrToDate(dtCurrentDate)) then begin
        ApplyPatch(iUpdateVersion, sUpdateAt);
      end
      else if (StrToDate(dtUpdateDate) = StrToDate(dtCurrentDate)) and (iCurrentUpdateVersion < iUpdateVersion) then begin
        ApplyPatch(iUpdateVersion, sUpdateAt);
      end;
    end;
  end;
end;
