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
   MPU_RA_PWR_MGMT_1 : constant Register_Address := 16#6B#;
   BIT_H_RESET : constant HAL.UInt8 := 16#80#;

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
      IO_Write (this, BIT_H_RESET, MPU_RA_PWR_MGMT_1);
      delay until Clock + Microseconds (15);
      --  TODO
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
      Data   : SPI_Data_8b (1 .. 1);
      Status : SPI_Status;
   begin
      This.Chip_Select.Clear;
      This.Port.Transmit (SPI_Data_8b'(1 => HAL.UInt8 (ReadAddr or SPI_Read_Flag)),
                          Status);
      if Status /= Ok then
         --  No error handling...
         raise Program_Error;
      end if;
      for i in Value'Range loop
         This.Port.Receive (Data, Status);
         if Status /= Ok then
            --  No error handling...
            raise Program_Error;
         end if;
         Value (i) := Data (1);
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
