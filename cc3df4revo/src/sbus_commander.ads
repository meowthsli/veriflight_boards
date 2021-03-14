with Interfaces; use Interfaces;

package sbus_commander is

--     Byte[0]: SBUS header, 0x0F
--     Byte[1 -22]: 16 servo channels, 11 bits each
--     Byte[23]
--       Bit 7: channel 17 (0x80)
--       Bit 6: channel 18 (0x40)
--       Bit 5: frame lost (0x20)
--       Bit 4: failsafe activated (0x10)
--     Byte[24]: SBUS footer

   subtype sbus_header is Unsigned_8;
   subtype sbus_footer is Unsigned_8;

   CH_SIZE : constant := 11;
   type sbus_channel is new Short_Integer range 0 .. 2 ** CH_SIZE - 1;
   for sbus_channel'Size use CH_SIZE;


   type sbus_data is array (Integer range 0 .. 15) of sbus_channel;
   --  Channels (0 .. 15) data
   pragma Pack (sbus_data);

   type sbus_spec is record
      d1 : Boolean;
      d2 : Boolean;
      frame_lost : Boolean;
      fail_safe : Boolean;
   end record;
   for sbus_spec'Size use 8;

   for sbus_spec use record
      d1   at 0 range 7 .. 7;
      d2   at 0 range 6 .. 6;
      frame_lost at 0 range 5 .. 5;
      fail_safe  at 0 range 4 .. 4;
   end record;

   --------------------------------------------
   --  S.BUS frame
   --------------------------------------------
   type sbus_frame is record
      h : sbus_header;
      data : sbus_data;
      spec : sbus_spec;
      f : sbus_footer;
   end record;
   pragma Pack (sbus_frame);

   --------------------------------------------
   --  Functions
   --------------------------------------------

   --  Initialization procedure
   procedure init;

   function get_channels_data return sbus_data;

private
   buffer : array (Integer range 0 .. 24) of Unsigned_8;
   frame : sbus_frame;
   for frame'Address use buffer'Address;

end sbus_commander;
