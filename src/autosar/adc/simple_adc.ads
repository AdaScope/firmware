with Interfaces.C;

package Simple_Adc is
   package IC renames Interfaces.C;
   subtype Group_T is IC.unsigned range 1 .. 3; -- We support only 3 groups.
   subtype Data_T is IC.unsigned;
   type Status_T is (Ok, Not_Ok);
   for Status_T use (Ok => 0, Not_Ok => 1);
   procedure Start_Group_Conversion (Group : Group_T) with
      Export        => True,
      Convention    => C,
      External_Name => "Ada_Adc_Start_Group_Conversion";
   function Read_Group (Group : Group_T; Data : in out Data_T) return Status_T with
      Export        => True,
      Convention    => C,
      External_Name => "Ada_Adc_Read_Group";
end Simple_Adc;
