with Beta_Types; use Beta_Types;

with Ada.Real_Time; use Ada.Real_Time;

with STM32;
with STM32.Device; use STM32.Device;

with STM32.GPIO; use STM32.GPIO;
with STM32.SPI;  use STM32.SPI;
with STM32.USARTs;  use STM32.USARTs;

with LCD_Std_Out;
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
   TX_Pin : constant GPIO_Point := PA9;
   RX_Pin : constant GPIO_Point := PA10;


   procedure Initialize_UART_GPIO;

   procedure Initialize;

   procedure Await_Send_Ready (This : USART) with Inline;

   procedure Put_Blocking (This : in out USART;  Data : UInt16);

   --------------------------
   -- Initialize_UART_GPIO --
   --------------------------

   procedure Initialize_UART_GPIO is
   begin
      Enable_Clock (USART_1);
      Enable_Clock (RX_Pin & TX_Pin);

      Configure_IO
        (RX_Pin & TX_Pin,
         (Mode           => Mode_AF,
          AF             => GPIO_AF_USART1_7,
          Resistors      => Pull_Up,
          AF_Speed       => Speed_50MHz,
          AF_Output_Type => Push_Pull));
   end Initialize_UART_GPIO;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      Initialize_UART_GPIO;

      Disable (USART_1);

      Set_Baud_Rate    (USART_1, 115_200);
      Set_Mode         (USART_1, Tx_Rx_Mode);
      Set_Stop_Bits    (USART_1, Stopbits_1);
      Set_Word_Length  (USART_1, Word_Length_8);
      Set_Parity       (USART_1, No_Parity);
      Set_Flow_Control (USART_1, No_Flow_Control);

      Enable (USART_1);
   end Initialize;

   ----------------------
   -- Await_Send_Ready --
   ----------------------

   procedure Await_Send_Ready (This : USART) is
   begin
      loop
         exit when Tx_Ready (This);
      end loop;
   end Await_Send_Ready;

   ------------------
   -- Put_Blocking --
   ------------------

   procedure Put_Blocking (This : in out USART;  Data : UInt16) is
   begin
      Await_Send_Ready (This);
      Transmit (This, UInt9 (Data));
   end Put_Blocking;

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
        
        --Log_To_LCD ("Voltage:" & Value'Image & " mV");
        temp := To_Unbounded_String (Value'Image);
        for i in 2 .. Length(temp) loop
          Put_Blocking(USART_1, Character'Pos(Element(temp, i)));
         end loop;
        Put_Blocking(USART_1, Character'Pos(ASCII.LF));
    end;

begin
   LCD_Std_Out.Set_Orientation (Landscape);

   adc.Init_ADC;
   Simple_Adc.Start_Group_Conversion (1);
   Initialize;


   loop
      Read_Adc;
      --Uart_For_Board;
      --Next_Release := Next_Release + Period;
      --delay until Next_Release;
   end loop;

end Adc_Standalone;