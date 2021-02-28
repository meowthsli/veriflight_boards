with HAL;
with Ada.Real_Time; use Ada.Real_Time;

package body mpu6000_spi is

   --
   --  Types
   --

   type Register_Address is new HAL.UInt8;
   subtype Read_Buffer is SPI_Data_8b (0 .. 5);

   --
   --  Constants
   --
   MPU_RA_ACCEL_XOUT_H : constant Register_Address := 16#3B#;
   MPU_RA_GYRO_XOUT_H : constant Register_Address := 16#43#; pragma Unreferenced (MPU_RA_GYRO_XOUT_H);
   MPU_RA_PWR_MGMT_1 : constant Register_Address := 16#6B#;
   MPU_RA_PWR_MGMT_2 : constant Register_Address := 16#6C#;
   MPU_RA_USER_CTRL : constant Register_Address := 16#6A#;

   BIT_H_RESET : constant HAL.UInt8 := 16#80#;
   MPU_CLK_SEL_PLLGYROZ : constant := 16#03#;
   BIT_I2C_IF_DIS : constant := 16#10#;

   SPI_Read_Flag  : constant Register_Address := 16#80#;
   SPI_Write_Flag : constant Register_Address := 16#00#;

   -----------------------
   --  Forward declarations
   -------------------------

--     procedure IO_Read
--       (This     : in out Six_Axis_Accelerometer;
--        Value    : out HAL.UInt8;
--        ReadAddr : Register_Address);

   procedure IO_Write
     (This      : in out Six_Axis_Accelerometer;
      Value     : HAL.UInt8;
      WriteAddr : Register_Address);

   procedure IO_Read_Buffer
     (This     : in out Six_Axis_Accelerometer;
      Value    : in out Read_Buffer;
      ReadAddr : Register_Address);

   -----------------
   --  Package body
   -----------------

   procedure Configure (this : in out Six_Axis_Accelerometer) is
   begin
      IO_Write (this, BIT_H_RESET, MPU_RA_PWR_MGMT_1); -- reset
      delay until Clock + Microseconds (15);

      IO_Write (this, BIT_I2C_IF_DIS, MPU_RA_USER_CTRL); -- disable i2c
      delay until Clock + Microseconds (15);

      IO_Write (this, 0, MPU_RA_PWR_MGMT_2);
      delay until Clock + Microseconds (15);

      IO_Write (this, MPU_CLK_SEL_PLLGYROZ, MPU_CLK_SEL_PLLGYROZ); -- use  Z-axis
      delay until Clock + Microseconds (15);

      --  TODO: setup sample rate and others
   end Configure;


   function Read (this : in out Six_Axis_Accelerometer) return Acc_Data is
      buffer : Read_Buffer;
      d : constant Acc_Data := Acc_Data'(others => <>);
   begin
      IO_Read_Buffer (this, buffer, MPU_RA_ACCEL_XOUT_H); --  burst read
      return d; --  todo
   end Read;

   ----------
   --  Private
   ----------

--     procedure IO_Read
--       (This     : in out Six_Axis_Accelerometer;
--        Value    : out HAL.UInt8;
--        ReadAddr : Register_Address)
--     is
--        Data : SPI_Data_8b (1 .. 1);
--        Status : SPI_Status;
--     begin
--        This.Chip_Select.Clear;
--        This.Port.Transmit (SPI_Data_8b'(1 => HAL.UInt8 (ReadAddr or SPI_Read_Flag)),
--                  Status);
--        if Status /= Ok then
--           --  No error handling...
--           raise Program_Error;
--        end if;
--        This.Port.Receive (Data, Status);
--        This.Chip_Select.Set;
--
--        if Status /= Ok then
--           --  No error handling...
--           raise Program_Error;
--        end if;
--        Value := Data (1);
--     end IO_Read;

   procedure IO_Read_Buffer
     (This     : in out Six_Axis_Accelerometer;
      Value    : in out Read_Buffer;
      ReadAddr : Register_Address)
   is
      Data   : SPI_Data_8b (1 .. Read_Buffer'Length);
      Status : SPI_Status;
   begin
      This.Chip_Select.Clear;
      This.Port.Transmit (SPI_Data_8b'(1 => HAL.UInt8 (ReadAddr or SPI_Read_Flag)),
                          Status);
      if Status /= Ok then
         --  No error handling...
         raise Program_Error;
      end if;
      This.Port.Receive (Data, Status);
      if Status /= Ok then
         --  No error handling...
         raise Program_Error;
      end if;
      for i in Read_Buffer'Range loop
         Value (i) := Data (i);
      end loop;
      This.Chip_Select.Set;
   end IO_Read_Buffer;


   procedure IO_Write
     (This      : in out Six_Axis_Accelerometer;
      Value     : HAL.UInt8;
      WriteAddr : Register_Address)
   is
      Status : SPI_Status;
   begin
      This.Chip_Select.Clear;
      This.Port.Transmit
        (SPI_Data_8b'(HAL.UInt8 (WriteAddr or SPI_Write_Flag), Value),
         Status);
      This.Chip_Select.Set;

      if Status /= Ok then
         --  No error handling...
         raise Program_Error;
      end if;
   end IO_Write;

end mpu6000_spi;
