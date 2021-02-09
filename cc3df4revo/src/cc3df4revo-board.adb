package body cc3df4revo.Board is
   procedure Initialize is
   begin
      Enable_Clock (NRF_RX & NRF_TX);

      Configure_IO (NRF_RX,
                    Config => (Mode             => Mode_AF,
                               AF               => NRF_USART_AF,
                               AF_Output_Type   => Open_Drain,
                               AF_Speed         => Speed_25MHz,
                               Resistors        => Pull_Up));

      Configure_IO (NRF_TX,
                    Config => (Mode             => Mode_AF,
                               AF               => NRF_USART_AF,
                               AF_Output_Type   => Push_Pull,
                               AF_Speed         => Speed_25MHz,
                               Resistors        => Pull_Up));

      Enable_Clock (SBUS1);

      --  configure SBUS USART
      Disable (SBUS1);


      Set_Baud_Rate    (SBUS1, 100_000);
      Set_Mode         (SBUS1, Tx_Rx_Mode);
      Set_Stop_Bits    (SBUS1, Stopbits_2);
      Set_Word_Length  (SBUS1, Word_Length_8);
      Set_Parity       (SBUS1, Even_Parity);
      Set_Flow_Control (SBUS1, No_Flow_Control);

      Enable (SBUS1);
   end Initialize;
end cc3df4revo.Board;
