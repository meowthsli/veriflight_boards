with Config; use Config;
with LIS3DSH.SPI; use LIS3DSH.SPI;
with Interfaces; use Interfaces;

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

   gyro : Three_Axis_Accelerometer_SPI
     (Port => SPI_Accel_Port'Access,
      Chip_Select => CS_ACCEL'Access);

end spi_accel;
