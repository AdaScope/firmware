with Ada.Text_IO;                   use Ada.Text_IO;
with GNAT.Serial_Communications;
with Ada.Streams;                   use Ada.Streams;


--envoyer les donnees du ADC au serial port 
-- figure out how to open 
procedure Uart_Wirte_Data is

    -- For UART
    Port : GNAT.Serial_Communications.Serial_Port;
    --Data : GNAT.Serial_Communications.Stream_Element_Array(1..100);
    --Data : GNAT.Serial_Communications.Buffer_Type(1..100);
    Data : Ada.Streams.Stream_Element_Array (1 .. 10);

    Test : Stream_Element_Offset;
begin
    -- Open the serial port
    GNAT.Serial_Communications.Open(Port, "/dev/ttyACM0");
    
    -- write data from the porttype
    loop
        GNAT.Serial_Communications.Write(Port, Data);
    end loop;

    -- Close the port
    GNAT.Serial_Communications.Close(Port);
end Uart_Wirte_Data;
