with Beta_Types; use Beta_Types;

with Ada.Real_Time; use Ada.Real_Time;

with STM32;
with STM32.Device; use STM32.Device;

with STM32.GPIO; use STM32.GPIO;
with STM32.SPI;  use STM32.SPI;

with LCD_Std_Out;
with HAL.Framebuffer; use HAL.Framebuffer;
with BMP_Fonts; use BMP_Fonts;

with STM32.Board;

with STM32.PWM;

with Bitmapped_Drawing;
with Cortex_M.Cache;
with HAL.Bitmap;

with Ada.Characters.Latin_1; use Ada.Characters.Latin_1;

with Uart_For_Board;
with Simple_Adc;
with adc;


with Textures.Autosar;

procedure Adc_Standalone is

   Period : constant Time_Span := Milliseconds (250);  -- arbitrary
   Next_Release : Time := Clock;

   procedure Log_To_LCD (Voltage : String) is
      Buf : HAL.Bitmap.Bitmap_Buffer'Class := STM32.Board.Display.Hidden_Buffer (1).all;
   begin
      LCD_Std_Out.Set_Orientation (Landscape);
      Cortex_M.Cache.Invalidate_DCache (Buf'Address, Buf.Buffer_Size);
      Buf.Fill;
      Bitmapped_Drawing.Draw_Texture
        (Buffer     => Buf,
         Start      => (0, 0),
         Tex        => Textures.Autosar.Bmp,
         Foreground => HAL.Bitmap.Transparent,
         Background => HAL.Bitmap.White);
      Bitmapped_Drawing.Draw_String
              (Buffer     => Buf,
               Start      => (0, 60),
               Msg        => Voltage,
               Font       => BMP_Fonts.Font16x24,
               Foreground => HAL.Bitmap.White,
               Background => HAL.Bitmap.Transparent);
      STM32.Board.Display.Update_Layer (1);
   end Log_To_LCD;

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
        Log_To_LCD ("Voltage:" & Value'Image & " mV");
    end;

begin
   LCD_Std_Out.Set_Orientation (Landscape);

   adc.Init_ADC;
   Simple_Adc.Start_Group_Conversion (1);


   loop
      --Read_Adc;
      Uart_For_Board;
      Next_Release := Next_Release + Period;
      delay until Next_Release;
   end loop;

end Adc_Standalone;