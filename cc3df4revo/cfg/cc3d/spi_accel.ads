with STM32.GPIO; use STM32.GPIO;
with mpu6000_spi; use mpu6000_spi;
with Config; use Config;
with Interfaces; use Interfaces;
--
--  Accel is MPU 6000
--
package spi_accel is

   procedure init;

   type accel_data is
      record
         X, Y, Z : Short_Integer;
         GX, GY, GZ : Short_Integer;
      end record;

   function read return accel_data;

   function id (product : out Unsigned_8) return Unsigned_8;

private

   gyro : Six_Axis_Accelerometer
     (Port => SPI_Accel_Port'Access,
      Chip_Select => CS_ACCEL'Access);

end spi_accel;
