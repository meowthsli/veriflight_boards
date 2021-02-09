with STM32.SPI; use STM32.SPI;
with HAL.SPI;

package body cc3df4revo.Board is
   procedure Initialize is
   begin
      ----
      --  UART pins
      ----
      Enable_Clock (SBUS_RX & SBUS_TX);
      Configure_IO (SBUS_RX,
                    Config => (Mode             => Mode_AF,
                               AF               => SBUS_AF,
                               AF_Output_Type   => Open_Drain,
                               AF_Speed         => Speed_25MHz,
                               Resistors        => Pull_Up));
      Configure_IO (SBUS_TX,
                    Config => (Mode             => Mode_AF,
                               AF               => SBUS_AF,
                               AF_Output_Type   => Push_Pull,
                               AF_Speed         => Speed_25MHz,
                               Resistors        => Pull_Up));
      Enable_Clock (SBUS1);

      ----
      --  Configure USART for SBUS
      ----
      Disable (SBUS1);
      Set_Baud_Rate (SBUS1, 100_000);
      Set_Mode (SBUS1, Tx_Rx_Mode);
      Set_Stop_Bits (SBUS1, Stopbits_2);
      Set_Word_Length (SBUS1, Word_Length_8);
      Set_Parity (SBUS1, Even_Parity);
      Set_Flow_Control (SBUS1, No_Flow_Control);
      Enable (SBUS1);

      --  Configuration of SBUS finished.
      --  Now let's set up SPI
      declare
         IMU_SPI : SPI_Port renames SPI_1;
         SPI_GPIO_Conf : GPIO_Port_Configuration;
         SPI_Conf : SPI_Configuration;
         SPI5_SCK : GPIO_Point renames PA5;
         SPI5_MISO : GPIO_Point renames PA6;
         SPI5_MOSI : GPIO_Point renames PA7;
         SPI_Pins : constant GPIO_Points := (SPI5_SCK, SPI5_MISO, SPI5_MOSI);
      begin
         Enable_Clock (SPI_Pins);
         Enable_Clock (IMU_SPI);

         SPI_GPIO_Conf := (Mode           => Mode_AF,
                           AF             => GPIO_AF_SPI1_5,
                           AF_Speed       => Speed_2MHz,
                           AF_Output_Type => Push_Pull,
                           Resistors      => Floating);
         Configure_IO (SPI_Pins, SPI_GPIO_Conf);
         Reset (IMU_SPI);

         if not Enabled (IMU_SPI) then
            SPI_Conf :=
              (Direction           => D2Lines_FullDuplex,
               Mode                => Master,
               Data_Size           => HAL.SPI.Data_Size_8b,
               Clock_Polarity      => Low,
               Clock_Phase         => P1Edge,
               Slave_Management    => Software_Managed,
               Baud_Rate_Prescaler => BRP_2,
               First_Bit           => MSB,
               CRC_Poly            => 7);
            Configure (IMU_SPI, SPI_Conf);
            --  TODO: delay 10ms
            STM32.SPI.Enable (IMU_SPI);
         end if;
      end;


   end Initialize;
end cc3df4revo.Board;
