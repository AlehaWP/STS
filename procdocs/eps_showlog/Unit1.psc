uses                                                
  Classes, Graphics, Controls, Forms, Dialogs, 
  FuncScript, Unit2;

var
  MainForm: TfrmLogEPS;
begin                      
  if ExecuteFuncScript ('BOOKOPENED()') = '1' then 
    begin
      MainForm := TfrmLogEPS.Create(Application);
      MainForm.ShowModal;
    end
  else
    begin                    
      showmessage('��� ���: ���������� ��������, ��� ��� ������� ����� �����.'); 
    end;
end;
