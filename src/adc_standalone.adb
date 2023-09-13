with Beta_Types; use Beta_Types;

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
with adc;

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Textures.Autosar;

procedure Adc_Standalone is

   Period : constant Time_Span := Milliseconds (250);  -- arbitrary
   Next_Release : Time := Clock;
   temp : Unbounded_String;

    procedure Read_Adc is
        function Read_ADC_Value (G : Simple_Adc.Group_T; 
                                V : access Simple_Adc.Data_T) return Simple_Adc.Status_T
        with
            Import        => True,
            Convention    => C,
            External_Name => "Adc_ReadGroup";

        Value : aliased Simple_Adc.Data_T := 0;
        Result : Simple_Adc.Status_T := Read_ADC_Value (1, Value'Unchecked_Access);
    begin
        
        temp := To_Unbounded_String (Value'Image);
        for i in 2 .. Length(temp) loop
          Uart_For_Board.Put_Blocking(USART_1, Character'Pos(Element(temp, i)));
         end loop;
        Uart_For_Board.Put_Blocking(USART_1, Character'Pos(ASCII.LF));
    end;

begin

   adc.Init_ADC;
   Simple_Adc.Start_Group_Conversion (1);
   Uart_For_Board.Initialize;


   loop
      Read_Adc;
      --Uart_For_Board;
      --Next_Release := Next_Release + Period;
      --delay until Next_Release;
   end loop;

end Adc_Standalone;