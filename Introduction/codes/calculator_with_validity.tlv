\m4_TLV_version 1d: tl-x.org
\SV

   // =================================================
   // Welcome!  New to Makerchip? Try the "Learn" menu.
   // =================================================

   // Default Makerchip TL-Verilog Code Template
   
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
\TLV

   |calc
      @1
         $reset = *reset;
         $num = $reset ? 0 : >>1$num + 1;
         
      @1 
         $valid = $num;
         $valid_and_reset = $valid || $reset; 
         $sum =  $num1[31:0] + $num2[31:0] ;
         $sub = $num1[31:0] - $num2[31:0] ;
         $mul = $num1[31:0] * $num2[31:0] ;
         $quot = $num1[31:0] / $num2[31:0];
         $num2[31:0] = >>2$out;
      ?$valid

         @2

            $out[31:0] = ($valid_and_reset ) ? 0 : 
                      ($op[1:0] == 0) 
                      ? $sum:
                      ($op[1:0] == 1) 
                      ?  $sub:
                      ($op[1:0] == 2) 
                      ? $mul : $quot ;
            

   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
