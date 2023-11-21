with Beta_Types;

package Adc is
   procedure Init_ADC;
   procedure Start_Group_Conversion;
   procedure Read_Group(Input: Integer; Data : in out Beta_Types.UInt32);
end Adc;
