uses                                                   
  Classes, Graphics, Controls, Forms, Dialogs, DO2_List;

var
  MainForm: TfrDO2List;
begin
  MainForm := TfrDO2List.Create(Application); 
  IF MainForm.FormConstruct(REL_MAIN_2, REL_COMM_2) <> 0 then 
  MainForm.ShowModal;
end;
