with HAL; use HAL;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Unchecked_Conversion;

package body mpu6000_spi is

   --
   --  Types
   --

   type Register_Address is new HAL.UInt8;
   subtype Read_Buffer is SPI_Data_8b (1 .. 6);

   --
   --  Constants
   --
   MPU_RA_ACCEL_XOUT_H : constant Register_Address := 16#3B#;
   MPU_RA_GYRO_XOUT_H : constant Register_Address := 16#43#; pragma Unreferenced (MPU_RA_GYRO_XOUT_H);
   MPU_RA_PWR_MGMT_1 : constant Register_Address := 16#6B#;
   MPU_RA_PWR_MGMT_2 : constant Register_Address := 16#6C#;
   MPU_RA_USER_CTRL : constant Register_Address := 16#6A#;

   MPU_RA_WHOAMI : constant Register_Address := 16#75#;
   MPU_PRODUCT_ID : constant Register_Address := 16#0C#;

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
      Value    : out Read_Buffer;
      ReadAddr : Register_Address);

   procedure IO_Read_Value
     (This     : in out Six_Axis_Accelerometer;
      Value    : out HAL.UInt8;
      ReadAddr : Register_Address);


   function fuse (high : HAL.UInt8; low : HAL.UInt8) return Short_Integer
      with Inline_Always => True;

   -----------------
   --  Package body
   -----------------

   procedure Configure (this : in out Six_Axis_Accelerometer) is
   begin
      IO_Write (this, BIT_H_RESET, MPU_RA_PWR_MGMT_1); -- reset
      delay until Clock + Milliseconds (15);

      IO_Write (this, MPU_CLK_SEL_PLLGYROZ, MPU_RA_PWR_MGMT_1); -- wake up, use  Z-axis
      delay until Clock + Milliseconds (15);

      IO_Write (this, BIT_I2C_IF_DIS, MPU_RA_USER_CTRL); -- disable i2c
      delay until Clock + Milliseconds (15);

      IO_Write (this, 0, MPU_RA_PWR_MGMT_2); -- enable all sensors
      delay until Clock + Milliseconds (15);

      --  TODO: setup sample rate and others
   end Configure;


   function Read (this : in out Six_Axis_Accelerometer) return Acc_Data is
      buffer : Read_Buffer;
      d : Acc_Data := Acc_Data'(others => <>);
   begin
      IO_Read_Buffer (this, buffer, MPU_RA_ACCEL_XOUT_H); --  burst read
      d.Xacc := fuse (buffer (1), buffer (2));
      d.Yacc := fuse (buffer (3), buffer (4));
      d.Zacc := fuse (buffer (5), buffer (6));
      return d;
   end Read;

   function Id (this : in out Six_Axis_Accelerometer;
                product : out Unsigned_8) return Unsigned_8 is
      buffer : HAL.UInt8;
      device : Unsigned_8;
   begin
      IO_Read_Value (this, buffer, MPU_RA_WHOAMI);
      device := Unsigned_8 (buffer);
      IO_Read_Value (this, buffer, MPU_PRODUCT_ID);
      product := Unsigned_8 (buffer);
      return device;
   end Id;


   ----------
   --  Private
   ----------

   procedure IO_Read_Buffer
     (This     : in out Six_Axis_Accelerometer;
      Value    : out Read_Buffer;
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
      This.Chip_Select.Set;
      Value (1 .. 6) := Data (1 .. 6);
   end IO_Read_Buffer;


   procedure IO_Read_Value
     (This     : in out Six_Axis_Accelerometer;
      Value    : out HAL.UInt8;
      ReadAddr : Register_Address)
   is
      Data : SPI_Data_8b (1 .. 1);
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
      This.Chip_Select.Set;

      if Status /= Ok then
         --  No error handling...
         raise Program_Error;
      end if;
      Value := Data (1);
   end IO_Read_Value;


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

   -------------------------------------
   --  Utils
   -------------------------------------
   function fuse (high : HAL.UInt8; low : HAL.UInt8) return Short_Integer
   is
      ---------------------
      -- Uint16_To_Int16 --
      ---------------------
      function Uint16_To_Int16 is new Ada.Unchecked_Conversion (HAL.UInt16, Short_Integer);
      reg : HAL.UInt16;
   begin
      reg := HAL.Shift_Left (HAL.UInt16 (high), 8);
      reg := reg or HAL.UInt16 (low);

      return Uint16_To_Int16 (reg);
   end fuse;

end mpu6000_spi;
