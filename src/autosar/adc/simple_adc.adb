with Ada.Real_Time; use Ada.Real_Time;

with STM32.Board;  use STM32.Board;
with STM32.Device; use STM32.Device;

with HAL;        use HAL;
with STM32.ADC;  use STM32.ADC;
with STM32.DMA;  use STM32.DMA;
with STM32.GPIO; use STM32.GPIO;

with Beta_Types; use Beta_Types; 

package body Simple_Adc is
   
   Counts     : UInt16 with Volatile;
   Converter : access Analog_To_Digital_Converter;
   Controller : DMA_Controller renames DMA_2;
   Stream     : constant DMA_Stream_Selector := Stream_0;
   
   procedure Start_Group_Conversion (Group : Group_T) is
   begin
      case Group is
         when 1 =>
            Converter := ADC_1'Unchecked_Access;
         when 2 =>
            Converter := ADC_2'Unchecked_Access;
         when 3 =>
            Converter := ADC_3'Unchecked_Access;
      end case;
      Enable (Converter.all);
      Start_Transfer
        (Controller, Stream, Source => Data_Register_Address (Converter.all),
         Destination                => Counts'Address, Data_Count => 1);
      Start_Conversion (Converter.all);
   end Start_Group_Conversion;

   function Read_Group (Group : Group_T; Data : in out Data_T) return Status_T is
    Voltage : UInt32 := ((UInt32 (Counts)) * ADC_Supply_Voltage) / 16#FFF#;
   begin
      Data := IC.Unsigned (Voltage);
      return Ok;
   end Read_Group;
end Simple_Adc;
