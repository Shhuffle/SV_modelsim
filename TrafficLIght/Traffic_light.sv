interface intr();
  logic clk, reset;
  logic [1:0] out;
  modport TL(input clk, reset, output out);
endinterface


module traffic_light(intr.TL i_f);

  typedef enum logic [1:0] {
    green,
    yellow,
    red
  } t_light;

  t_light c_light, n_light;

  always_ff @(posedge i_f.clk or posedge i_f.reset) begin
    if (i_f.reset)
      c_light <= red;
    else
      c_light <= n_light;
  end

  always_comb begin
    case (c_light)
      green:  n_light = yellow;
      yellow: n_light = red;
      red:    n_light = green;
      default: n_light = red;
    endcase
    i_f.out = n_light;  // Use blocking assign in combinational block
  end

endmodule


module tb;

  intr intr0();                    // Instantiate interface
  traffic_light dut(intr0.TL);    // Instantiate DUT with interface modport

  // Clock generation: 10ns period (toggle every 5ns)
  initial intr0.clk = 0;
  always #5 intr0.clk = ~intr0.clk;

  // Reset sequence
  initial begin
    intr0.reset = 1;
    #15 intr0.reset = 0;
  end

  // Monitor output
  initial begin
    $display("Time\tReset\tOut");
    $monitor("%0t\t%b\t%0b", $time, intr0.reset, intr0.out);
  end

  // Stop simulation after 100 ns
  initial begin
    #100;
    $finish;
  end

endmodule

