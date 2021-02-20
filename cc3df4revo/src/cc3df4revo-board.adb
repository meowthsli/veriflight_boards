--  with STM32.SPI; use STM32.SPI;
--  with HAL.SPI;
with Ada.Interrupts.Names;
with Cortex_M.NVIC; use Cortex_M.NVIC;
with STM32_SVD.RCC; use STM32_SVD.RCC;
with Config;

package body cc3df4revo.Board is
   package IC renames Interfaces.C;
   package ASU renames Ada.Strings.Unbounded;

   --
   --  Doing receive (if any)
   procedure usb_receive (message : out ASU.Unbounded_String) is
      --  buffer : constant String := (1 .. 32 => <>);
      --  ptr : constant IC.Strings.chars_ptr := IC.Strings.New_String (buffer);
      size : IC.unsigned_short;
      buffer : IC.char_array (0 .. 32);
   begin
      size := ada_usbapi_rx (buffer);
      pragma Unreferenced (size);
      declare
         str : constant String := IC.To_Ada (buffer, True);
      begin
         if str'Length = 0 then
            message := ASU.Null_Unbounded_String;
         else
            message := ASU.To_Unbounded_String (str);
         end if;
      end;
   end usb_receive;

   --
   --  Doing sending
   procedure usb_transmit (message : in String) is
   begin
      ada_usbapi_tx (message'Address, message'Length);
   end usb_transmit;

   --
   --  Initialization
   --
   procedure Initialize is
      unused : Interfaces.C.int;
   begin
      ----
      --  UART pins
      ----
      --  Enable_Clock (SBUS_RX & SBUS_TX);
      --  Configure_IO (SBUS_RX,
      --                Config => (Mode             => Mode_AF,
      --                           AF               => SBUS_AF,
      --                           AF_Output_Type   => Open_Drain,
      --                           AF_Speed         => Speed_25MHz,
      --                           Resistors        => Pull_Up));
      --  Configure_IO (SBUS_TX,
      --                Config => (Mode             => Mode_AF,
      --                           AF               => SBUS_AF,
      --                           AF_Output_Type   => Push_Pull,
      --                           AF_Speed         => Speed_25MHz,
      --                           Resistors        => Pull_Up));
      --  Enable_Clock (SBUS1);
      --
      ----
      --  Configure USART for SBUS
      ----
      --  Disable (SBUS1);
      --  Set_Baud_Rate (SBUS1, 100_000);
      --  Set_Mode (SBUS1, Tx_Rx_Mode);
      --  Set_Stop_Bits (SBUS1, Stopbits_2);
      --  Set_Word_Length (SBUS1, Word_Length_8);
      --  Set_Parity (SBUS1, Even_Parity);
      --  Set_Flow_Control (SBUS1, No_Flow_Control);
      --  Enable (SBUS1);
      --
      --  --  Configuration of SBUS finished.
      --  --  Now let's set up SPI
      --  declare
      --     IMU_SPI : SPI_Port renames SPI_1;
      --     SPI_GPIO_Conf : GPIO_Port_Configuration;
      --     SPI_Conf : SPI_Configuration;
      --     SPI5_SCK : GPIO_Point renames PA5;
      --     SPI5_MISO : GPIO_Point renames PA6;
      --     SPI5_MOSI : GPIO_Point renames PA7;
      --     SPI_Pins : constant GPIO_Points := (SPI5_SCK, SPI5_MISO, SPI5_MOSI);
      --  begin
      --     Enable_Clock (SPI_Pins);
      --     Enable_Clock (IMU_SPI);
      --
      --     SPI_GPIO_Conf := (Mode           => Mode_AF,
      --                       AF             => GPIO_AF_SPI1_5,
      --                       AF_Speed       => Speed_2MHz,
      --                       AF_Output_Type => Push_Pull,
      --                       Resistors      => Floating);
      --     Configure_IO (SPI_Pins, SPI_GPIO_Conf);
      --     Reset (IMU_SPI);
      --
      --     if not Enabled (IMU_SPI) then
      --        SPI_Conf :=
      --          (Direction           => D2Lines_FullDuplex,
      --           Mode                => Master,
      --           Data_Size           => HAL.SPI.Data_Size_8b,
      --           Clock_Polarity      => Low,
      --           Clock_Phase         => P1Edge,
      --           Slave_Management    => Software_Managed,
      --           Baud_Rate_Prescaler => BRP_2,
      --           First_Bit           => MSB,
      --           CRC_Poly            => 7);
      --        Configure (IMU_SPI, SPI_Conf);
      --        --  TODO: delay 10ms
      --        STM32.SPI.Enable (IMU_SPI);
      --     end if;
      --  end;
      --
      --  Configure_PWM_Timer (MOTOR_123_Timer'Access, 2_000_000); --  2kHz
      --  M1.Attach_PWM_Channel
      --    (MOTOR_123_Timer'Access,
      --     MOTOR_1_Channel,
      --     MOTOR_1,
      --     MOTOR_1_AF);
      --  M1.Enable_Output;
      --  M1.Set_Duty_Cycle (0);

      --
      --  USB
      --
      RCC_Periph.AHB2ENR.OTGFSEN := True;

      Enable_Clock (PA11);
      Enable_Clock (PA12);
      Enable_Clock (PA9);

      Configure_IO (PA9,
                    (Mode      => Mode_In,
                     Resistors => Floating));

      Configure_IO (PA11 & PA12,
                    (Mode     => Mode_AF,
                     Resistors => Floating,
                     AF_Output_Type => Push_Pull,
                     AF_Speed => Speed_Very_High,
                     AF => GPIO_AF_OTG_FS_10));
      unused := ada_usbapi_setup;

      Enable_Clock (Config.SIGNAL_LED);
      Configure_IO (Config.SIGNAL_LED,
                    Config => (Mode => Mode_Out,
                               Resistors => Floating,
                               Output_Type => Push_Pull,
                               Speed => Speed_100MHz));
      Cortex_M.NVIC.Enable_Interrupt (Interrupt_ID (Ada.Interrupts.Names.OTG_FS_Interrupt));
   end Initialize;
end cc3df4revo.Board;
