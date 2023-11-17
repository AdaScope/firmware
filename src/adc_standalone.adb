with Ada.Real_Time; use Ada.Real_Time;

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

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Textures.Autosar;

with Min_Ada;

procedure Adc_Standalone is

   Period        : constant Time_Span := Milliseconds (250);  -- arbitrary
   Next_Release  : Time := Clock;
   Temp          : Unbounded_String;
   Context       : Min_Ada.Min_Context;
   Payload       : Min_Ada.Min_Payload;
   Payload_Index : Integer;
   Data_Count    : Integer;

   function Read_ADC_Value (
      G : Simple_Adc.Group_T;
      V : access Simple_Adc.Data_T
   ) return Simple_Adc.Status_T
   with
      Import        => True,
      Convention    => C,
      External_Name => "Adc_ReadGroup";

   Value  : aliased Simple_Adc.Data_T := 0;
   Result : Simple_Adc.Status_T;

   procedure Read_Adc is
   begin

      Temp := To_Unbounded_String (Value'Image);
      for I in 2 .. Length (Temp) loop
         Uart_For_Board.Put_Blocking (
            USART_1,
            Character'Pos (Element (Temp, I))
      );
      end loop;
      Uart_For_Board.Put_Blocking (
         USART_1,
         Character'Pos (ASCII.LF)
      );
   end Read_Adc;
begin
   Adc.Init_ADC;
   Simple_Adc.Start_Group_Conversion (1);
   Uart_For_Board.Initialize;

   --  Init min
   Min_Ada.Min_Init_Context (Context);
   Payload_Index := 1;
   Data_Count := 0; -- Max of 51 for now

   loop
      while Data_Count < 51 loop
         Result := Read_ADC_Value (1, Value'Unchecked_Access);
         Temp := To_Unbounded_String (Value'Image);
         for I in 2 .. Length (Temp) loop
            Payload (Min_Ada.Byte (Payload_Index)) :=
               Min_Ada.Byte (Character'Pos (Element (Temp, I)));
                  Payload_Index := Payload_Index + 1;
         end loop;
         Payload (Min_Ada.Byte (Payload_Index)) :=
            Min_Ada.Byte (Character'Pos (ASCII.LF));
               Payload_Index := Payload_Index + 1;
         Data_Count := Data_Count + 1;
      end loop;
      Min_Ada.Send_Frame (
         Context => Context,
         ID => 1,
         Payload => Payload,
         Payload_Length => Min_Ada.Byte (Payload_Index - 1)
      );

      Data_Count := 0;
      Payload_Index := 1;
   end loop;

end Adc_Standalone;
