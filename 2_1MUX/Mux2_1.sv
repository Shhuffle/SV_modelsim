interface MUX;
  logic sel;
  logic A;
  logic B;
  logic Y;

  modport MUX1_1(input A, B, sel, output Y);
endinterface

module MUX2_1(MUX m);
  always_comb begin
    if (m.sel == 1'b0)
      m.Y = m.A;
    else
      m.Y = m.B;
  end
endmodule

module tb;
  MUX m();              // Instantiate the interface
  MUX2_1 dut(m);        // Connect the interface to the DUT

  initial begin
    m.A = 1;
    m.B = 0;

    m.sel = 0;
    #5;
    $display("sel=0 -> Y=%b", m.Y); // Expect Y = 1

    m.sel = 1;
    #5;
    $display("sel=1 -> Y=%b", m.Y); // Expect Y = 0

    
  end
endmodule

