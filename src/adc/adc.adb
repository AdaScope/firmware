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

   Controller : DMA_Controller renames DMA_2;

   Converter     : Analog_To_Digital_Converter renames ADC_1;
   Converter_Access : access Analog_To_Digital_Converter := ADC_1'Unchecked_Access;
   Input_Channel_1 : constant Analog_Input_Channel := 13;
   Input_1         : constant GPIO_Point           := PC3;

   Stream_Adc_1     : constant DMA_Stream_Selector := Stream_0;

   Counts_1     : Beta_Types.UInt32 with Volatile;

   Converter_2     : Analog_To_Digital_Converter renames ADC_2;
   Converter_Access_2 : access Analog_To_Digital_Converter := ADC_2'Unchecked_Access;
   Input_Channel_2 : constant Analog_Input_Channel := 12;
   Input_2         : constant GPIO_Point           := PC2;

   Stream_Adc_2     : constant DMA_Stream_Selector := Stream_1;

   Counts_2     : Beta_Types.UInt32 with Volatile;

   procedure Start_Group_Conversion is
   begin
      Enable (Converter_Access.all);
      Start_Transfer
        (Controller, Stream_Adc_1, Source => Data_Register_Address (Converter_Access.all),
         Destination                => Counts_1'Address, Data_Count => 1);
      Start_Conversion (Converter_Access.all);

      Enable (Converter_Access_2.all);
      Start_Transfer
        (Controller, Stream_Adc_2, Source => Data_Register_Address (Converter_Access_2.all),
         Destination                => Counts_2'Address, Data_Count => 1);
      Start_Conversion (Converter_Access_2.all);
   end Start_Group_Conversion;

   procedure Read_Group (Input: Integer; Data : in out Beta_Types.UInt32) is
    Voltage : Beta_Types.UInt32;
   begin
      if Input = 1 then
         Voltage := ( Counts_1 * ADC_Supply_Voltage) / 16#FFF#;
      else
         Voltage := ( Counts_2 * ADC_Supply_Voltage) / 16#FFF#;
      end if;
      Data := Voltage;
   end Read_Group;

   procedure Init_ADC is

      procedure Initialize_DMA is
         Config : DMA_Stream_Configuration;
      begin
         Enable_Clock (Controller);

         Reset (Controller, Stream_0);
         Reset (Controller, Stream_1);

         Config.Channel                      := Channel_0;
         Config.Direction                    := Peripheral_To_Memory;
         Config.Memory_Data_Format           := HalfWords;
         Config.Peripheral_Data_Format       := HalfWords;
         Config.Increment_Peripheral_Address := False;
         Config.Increment_Memory_Address     := False;
         Config.Operation_Mode               := Circular_Mode;
         Config.Priority                     := Priority_Very_High;
         Config.FIFO_Enabled                 := False;
         Config.Memory_Burst_Size            := Memory_Burst_Single;
         Config.Peripheral_Burst_Size        := Peripheral_Burst_Single;

         Configure (Controller, Stream_0, Config);

         Config.Channel := Channel_1;

         Configure (Controller, Stream_1, Config);

         Clear_All_Status (Controller, Stream_0);
         Clear_All_Status (Controller, Stream_1);
      end Initialize_DMA;

      procedure Initialize_ADC is
         --TODO
         --All_Regular_Conversions : constant Regular_Channel_Conversions :=
         --  (1 => (Channel => Input_Channel_1, Sample_Time => Sample_480_Cycles),
         --  2 => (Channel => Input_Channel_2, Sample_Time => Sample_480_Cycles));
         All_Regular_Conversions_1 : constant Regular_Channel_Conversions :=
           (1 => (Channel => Input_Channel_1, Sample_Time => Sample_480_Cycles));

         All_Regular_Conversions_2 : constant Regular_Channel_Conversions :=
           (1 => (Channel => Input_Channel_2, Sample_Time => Sample_480_Cycles));

         procedure Configure_Analog_Input is
         begin
            Enable_Clock (Input_1);
            Configure_IO (Input_1, (Mode => Mode_Analog, Resistors => Floating));

            Enable_Clock (Input_2);
            Configure_IO (Input_2, (Mode => Mode_Analog, Resistors => Floating));
         end Configure_Analog_Input;
      begin
         Configure_Analog_Input;

         Enable_Clock (Converter);

         Reset_All_ADC_Units;

         Configure_Common_Properties
           (Mode     => Independent, Prescalar => PCLK2_Div_2,
            DMA_Mode => Disabled, Sampling_Delay => Sampling_Delay_5_Cycles);

         Configure_Unit
           (Converter, Resolution => ADC_Resolution_12_Bits,
            Alignment             => Right_Aligned);

         Configure_Unit
           (Converter_2, Resolution => ADC_Resolution_12_Bits,
            Alignment             => Right_Aligned);

         Configure_Regular_Conversions
           (Converter, Continuous => True, Trigger => Software_Triggered,
            Enable_EOC => False, Conversions => All_Regular_Conversions_1);
         
         Configure_Regular_Conversions
           (Converter_2, Continuous => True, Trigger => Software_Triggered,
            Enable_EOC => False, Conversions => All_Regular_Conversions_2);

         Enable_DMA (Converter);
         Enable_DMA (Converter_2);

         Enable_DMA_After_Last_Transfer (Converter);
         Enable_DMA_After_Last_Transfer (Converter_2);
      end Initialize_ADC;
   begin
      Initialize_DMA;
      Initialize_ADC;
   end Init_ADC;
end Adc;