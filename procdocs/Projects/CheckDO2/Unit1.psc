uses                                                                                              
  Classes, Graphics, Controls, Forms, Dialogs, Unit2;

var
MainForm: TForm2;

  
procedure CheckDO2;
var
  MainForm: TForm2;
  iFindMistake : integer; 
begin  
  iFindMistake := 0;
  MainForm := TForm2.Create(Application); 
  With MainForm do begin                                                         
      ExecuteFuncScript('SHOWINFORMATION("�������� ��2 �� ������������ ��")');   
      iFindMistake := CheckDoDt;      
      ExecuteFuncScript('HIDEINFORMATION()'); 
                                                      
      if not iFindMistake  then        
         if MessageDlg('������ �� ����������. �������� ���� ��������� ?', mtInformation, mbYesNo, 0) = 7 then 
             exit;       
      IF ShowModal = mrRetry then begin 
      
         Free;                                  
         CheckDO2;                                                                                
         Exit;                                                                                  
      end                                                 
      else
         Free;
  end;                                                                          
end;
 
begin
    IF not Release.IsEmpty then  
        CheckDO2
    else showmessage('����������� ��2');    
end;
