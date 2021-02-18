with Ada.Interrupts;
with Ada.Interrupts.Names;

package usb_handler is
   protected Device_Interface is
      pragma Interrupt_Priority;
      procedure Handler with Attach_Handler => Ada.Interrupts.Names.OTG_FS_Interrupt;
   end Device_Interface;
end usb_handler;
