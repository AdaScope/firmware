with STM32.Device; use STM32.Device;

with STM32.Board;  use STM32.Board;
with STM32.Device; use STM32.Device;

with HAL;        use HAL;

with Ada.Real_Time; use Ada.Real_Time;

with STM32.ADC;  use STM32.ADC;
with STM32.DMA;  use STM32.DMA;
with STM32.GPIO; use STM32.GPIO;
with Beta_Types; use Beta_Types;

package body Adc is

   Converter     : Analog_To_Digital_Converter renames ADC_1;
   Input_Channel : constant Analog_Input_Channel := 5;
   Input         : constant GPIO_Point := PA5;

   Converter_2     : Analog_To_Digital_Converter renames ADC_2;
   Input_Channel_2 : constant Analog_Input_Channel := 13;
   Input_2         : constant GPIO_Point := PC3;
   --  See the mapping of channels to GPIO pins at the top of the ADC package.
   --  Also see the board's User Manual for which GPIO pins are available.
   --  For example, on the F429 Discovery board, PA5 is not used by some
   --  other device, and maps to ADC channel 5.

   All_Regular_Conversions : constant Regular_Channel_Conversions :=
          (1 => (Channel => Input_Channel, Sample_Time => Sample_144_Cycles));

   All_Regular_Conversions_2 : constant Regular_Channel_Conversions :=
          (1 => (Channel => Input_Channel_2, Sample_Time => Sample_144_Cycles));


   Successful : Boolean;

   Successful_2 : Boolean;

   function Read_Group (Input: Integer) return Beta_Types.UInt32 is
   begin
      if Input = 1 then
         Start_Conversion (Converter);
         Poll_For_Status (Converter, Regular_Channel_Conversion_Complete, Successful);
         return (Beta_Types.UInt32 (Conversion_Value (Converter))) * ADC_Supply_Voltage / 16#FFF#;
      else
         Start_Conversion (Converter_2);
         Poll_For_Status (Converter_2, Regular_Channel_Conversion_Complete, Successful);
         return (Beta_Types.UInt32 (Conversion_Value (Converter_2))) * ADC_Supply_Voltage / 16#FFF#;
      end if;
   end Read_Group;

   procedure Init_ADC is

      procedure Configure_Analog_Input is
      begin
         Enable_Clock (Input);
         Configure_IO (Input, (Mode => Mode_Analog, Resistors => Floating));

         Enable_Clock (Input_2);
         Configure_IO (Input_2, (Mode => Mode_Analog, Resistors => Floating));
      end Configure_Analog_Input;

   begin
      Configure_Analog_Input;

      Enable_Clock (Converter);
      Enable_Clock (Converter_2);

      Reset_All_ADC_Units;

      Configure_Common_Properties
      (Mode           => Independent,
         Prescalar      => PCLK2_Div_2,
         DMA_Mode       => Disabled,
         Sampling_Delay => Sampling_Delay_5_Cycles);

      Configure_Unit
      (Converter,
         Resolution => ADC_Resolution_12_Bits,
         Alignment  => Right_Aligned);

      Configure_Unit
      (Converter_2,
         Resolution => ADC_Resolution_12_Bits,
         Alignment  => Right_Aligned);

      Configure_Regular_Conversions
      (Converter,
         Continuous  => False,
         Trigger     => Software_Triggered,
         Enable_EOC  => True,
         Conversions => All_Regular_Conversions);

      Configure_Regular_Conversions
      (Converter_2,
         Continuous  => False,
         Trigger     => Software_Triggered,
         Enable_EOC  => True,
         Conversions => All_Regular_Conversions);

      Enable (Converter);
      Enable (Converter_2);
   end Init_ADC;
end Adc;