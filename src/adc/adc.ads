with Beta_Types;

package Adc is
   procedure Init_ADC;
   function Read_Group(Input: Integer) return Beta_Types.UInt32;
end Adc;
