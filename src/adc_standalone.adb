with Ada.Real_Time; use Ada.Real_Time;
with My_Min_Ada;

with STM32;
with STM32.Device; use STM32.Device;

with STM32.GPIO; use STM32.GPIO;
with STM32.SPI;  use STM32.SPI;
with STM32.USARTs;  use STM32.USARTs;

with HAL.Framebuffer; use HAL.Framebuffer;
with BMP_Fonts; use BMP_Fonts;

with HAL;           use HAL;

with STM32.Board;

with STM32.PWM;

with Bitmapped_Drawing;
with Cortex_M.Cache;
with HAL.Bitmap;

with Ada.Characters.Latin_1; use Ada.Characters.Latin_1;

with Uart_For_Board;
with Simple_Adc;
with Adc;

with Beta_Types;

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Textures.Autosar;

with Min_Ada;

procedure Adc_Standalone is

   Frame_Count             : Integer := 10;
   Data_Points_Per_Payload : Integer := 120;

   type Payload_Arr is
      array (1 .. Frame_Count) of Min_Ada.Min_Payload;

   Period          : constant Time_Span := Milliseconds (250);  -- arbitrary
   Next_Release    : Time := Clock;
   Temp            : Unbounded_String;
   Context         : Min_Ada.Min_Context;
   Payload_Index   : Integer;
   Data_Count      : Integer;
   Frame_Index     : Integer;
   Payloads        : Payload_Arr;
   Payload_Indexes : array (1 .. Frame_Count) of Integer;

   D : constant := 0.1;
   type ADC_Reading is delta D range 0.0 .. 3000.0;

   type ADC_Reading_Bytes is array (1 .. 2) of Min_Ada.Byte;

   Value            : ADC_Reading;
   Value_Bytes      : ADC_Reading_Bytes with Address => Value'Address;

   --Value  : Beta_Types.UInt32 := 0;
   --Result : Simple_Adc.Status_T;

   procedure Collect_Data(Input : Integer) is
   begin
      Frame_Index := 1;
      --  Iterate through all the frames
      while Frame_Index < Frame_Count + 1 loop

         --  Iterate through all the data points
         while Data_Count < Data_Points_Per_Payload loop
            Value := ADC_Reading (Adc.Read_Group (Input));
            Payloads (Frame_Index) (Min_Ada.Byte (Payload_Index)) := 
               Value_Bytes (2);
            Payload_Index := Payload_Index + 1;
            Payloads (Frame_Index) (Min_Ada.Byte (Payload_Index)) := 
               Value_Bytes (1);
            Payload_Index := Payload_Index + 1;
            Data_Count := Data_Count + 1;
         end loop;
         Payload_Indexes (Frame_Index) := Payload_Index;
         Frame_Index := Frame_Index + 1;
         Data_Count := 0;
         Payload_Index := 1;
      end loop;
   end Collect_Data;

   procedure Send_Data(Input : Integer) is
   begin
      Frame_Index := 1;
      while Frame_Index < Frame_Count + 1 loop
         if Frame_Index = 1 then
            Min_Ada.Send_Frame (
               Context => Context,
               ID => Min_Ada.App_ID (Input + 4),
               Payload => Payloads(Frame_Index),
               Payload_Length => Min_Ada.Byte (Payload_Indexes(Frame_Index) - 1)
            );
         else
            Min_Ada.Send_Frame (
               Context => Context,
               ID => Min_Ada.App_ID (Input),
               Payload => Payloads(Frame_Index),
               Payload_Length => Min_Ada.Byte (Payload_Indexes(Frame_Index) - 1)
            );
         end if;
         Frame_Index := Frame_Index + 1;
      end loop;
   end Send_Data;

begin
   Adc.Init_ADC;
   Uart_For_Board.Initialize;

   --  Init min
   Min_Ada.Min_Init_Context (Context);
   Payload_Index := 1;
   Data_Count := 0; -- Max of 51 for now
   Frame_Index := 1;

   My_Min_Ada.Override_Tx_Byte;

   loop

      Collect_Data(1);
      Send_Data(1);
      Collect_Data(2);
      Send_Data(2);
      Collect_Data(3);
      Send_Data(3);
   end loop;

end Adc_Standalone;
