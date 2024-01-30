// Nathan Heck
// University of Florida

`timescale 1 ns / 10 ps

// Module: object_test
// Description: This module implements a testbench for the Pong object using assertions,
// with the simplifying assumption that enable is always asserted.

module object_tb;

   localparam NUM_TESTS = 10000;   
   logic clk=1'b0, rst, en;
   logic [11:0] hpos, vpos;
   reg [7:0] pixel [0:2];
   reg active;

   initial begin : generate_clock
      while(1)
        #5 clk = ~clk;      
   end


   object DUT (
	.pixel_clk(clk),
	.rst(rst),
	.fsync(en),
	.hpos(hpos),
	.vpos(vpos),
	.pixel(pixel),
	.active(active)
);
	

   initial begin : drive_inputs
      $timeformat(-9, 0, " ns");         

      rst <= 1'b1;      
      en <= 1'b0;
      hpos <= 12'b0;
      vpos <= 12'b0;

      for (int i=0; i < 5; i++)
        @(posedge clk);

      @(negedge clk);
      rst <= 1'b0;

      en <= 1'b1;
      hpos <= 500;
      vpos <= 500;
      for (int i=0; i < NUM_TESTS; i++) begin    

         @(posedge clk);
      end

      disable generate_clock;
      $display("Tests completed.");
   end 

   // Incorrect attempt 1:
   // ##1 specifes that out should be asserted 1 cycle after in, which is what
   // we want to check. However, the exact meaning of this property is that
   // in should always be asserted and out should be asserted one cycle later.
   //assert property(@(posedge clk) in ##1 out);

   // Incorrect attempt 2:
   // Here we us the implication operator to change the semantics to: if in is
   // asserted, then out should be asserted one cycle later.
   // While closer to what we want, this doesn't include the reset.
   //assert property(@(posedge clk) in |-> ##1 out);
   
   // The following assertion is equivalent to the previous one. |=> is just
   // shorthand for |-> ##1.
   //assert property(@(posedge clk) in |=> out);
   
   // The following is correct because it disables the assertion any time
   // reset is enabled.
   //assert property(@(posedge clk) disable iff (rst) in |=> out);
   
   // We should also check to make sure the reset is working correctly.
   // Technically, this is checking for an synchronous reset because it checks
   // to see if out is not asserted on every rising edge after rst is 1.
   //assert property(@(posedge clk) rst |=> !out);
   
   // To check for the asynchronous reset, we can use an immediate assertion.
   always @(rst) begin
      // Give the output time to change.
      #1;      
      //assert(active == 1'b0);      
   end      
endmodule

