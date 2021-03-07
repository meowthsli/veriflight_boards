with STM32.GPIO; use STM32.GPIO;
with STM32.Device; use STM32.Device;
with STM32.SPI; use STM32.SPI;
with HAL.SPI; use HAL.SPI;
with cc3df4revo.Board;

package body spi_accel is
   package GPIO renames STM32.GPIO;
   --
   --  SPI connection initialization
   --
   procedure init is
      procedure init_gpio;
      procedure reinit_spi;
      procedure configure_accel;

      --  all i/o lines initializations
      procedure init_gpio is
      begin
         --  activate spi lines
         STM32.Device.Enable_Clock (SCLK & MOSI & MISO);
         GPIO.Configure_IO
           (Points => (MOSI, MISO, SCLK),
            Config => (Mode => Mode_AF,
                       AF => STM32.Device.GPIO_AF_SPI1_5,
                       AF_Output_Type => Push_Pull,
                       AF_Speed => Speed_Very_High,
                       Resistors => Floating
                       ));
         --  activate chip_select line
         STM32.Device.Enable_Clock (CS_ACCEL);
         GPIO.Configure_IO
           (This => CS_ACCEL,
            Config => (Mode => Mode_Out,
                       Output_Type => Push_Pull,
                       Speed => Speed_Very_High,
                       Resistors => Floating
                      ));
         GPIO.Set (CS_ACCEL); -- CS_ACCEL line is inverted
      end init_gpio;

      --  spi device initialization
      procedure reinit_spi is
         cfg : constant SPI_Configuration := SPI_Configuration'
           (Direction => D2Lines_FullDuplex,

            Data_Size => Data_Size_8b,
            Mode => Master,
            Clock_Polarity => Low,
            Clock_Phase => P1Edge,
            Slave_Management => Software_Managed,
            Baud_Rate_Prescaler => BRP_256,
            First_Bit => MSB,
            CRC_Poly => 7
           );
      begin
         SPI_Accel_Port.Disable;
         STM32.Device.Enable_Clock (SPI_Accel_Port);
         SPI_Accel_Port.Configure (Conf => cfg);
         SPI_Accel_Port.Enable;
      end reinit_spi;

      --
      --  accel init
      --
      procedure configure_accel is
         package LIS renames LIS3DSH;
      begin
         gyro.Configure (Output_DataRate => LIS.Data_Rate_3_125Hz,
                        Axes_Enable => LIS.XYZ_Enabled,
                        SPI_Wire => LIS.Serial_Interface_4Wire,
                        Self_Test => LIS.Self_Test_Normal,
                        Full_Scale => LIS.Fullscale_2g,
                        Filter_BW => LIS.Filter_200Hz);
      end configure_accel;

   --  BODY
   begin
      reinit_spi;
      init_gpio;
      cc3df4revo.Board.usb_transmit ("spi ok; gpio ok;" & ASCII.CR & ASCII.LF);
      configure_accel;
      cc3df4revo.Board.usb_transmit ("gyro ok;" & ASCII.CR & ASCII.LF);
   end init;

   --
   --  Reading data from accellerometer on board
   --
   function read return accel_data is
      package LIS renames LIS3DSH;
      axes : LIS.Axes_Accelerations;
   begin
      gyro.Get_Accelerations (Axes => axes);
      return accel_data'(X => Short_Integer (axes.X),
                         Y => Short_Integer (axes.Y),
                         Z => Short_Integer (axes.Z),
                         GX => 0,
                         GY => 0,
                         GZ => 0);
   end read;

   function id (product : out Unsigned_8) return Unsigned_8 is
   begin
      product := 16#55#;
      return 16#AA#;
   end id;

end spi_accel;
