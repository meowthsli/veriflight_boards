with Interfaces.C;

package body usb_handler is
   --  External IRQ handler
   function usb_handler return Interfaces.C.int
     with
       Import => True,
       Convention => C,
       External_Name => "OTG_FS_IRQHandler";

   --  Main usb device
   protected body Device_Interface is
      procedure Handler is
         unused : Interfaces.C.int;
      begin
         unused := usb_handler;
      end Handler;

   end Device_Interface;
end usb_handler;
