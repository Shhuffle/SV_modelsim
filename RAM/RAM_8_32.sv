
interface mem_if(input logic clk);
logic rd , wd , cs, rst;
tri [7:0] datalines;
logic [4:0] addlines;

clocking cb @(posedge clk);
	default input #1step output #1step ; //this will cause to take input 1 step before the clk posedge and output after 1 step of clk posedge 
	output rd , wd , addlines,cs;
	input datalines;

endclocking


modport ram_32(input rd , wd, cs, addlines,clk,rst,
		inout datalines);

modport Ram_tb(clocking cb,output rst);

endinterface


module RAM(mem_if.ram_32 inf);
	logic [7:0] ram_mem [31:0]; 
	logic [7:0] data_out;
	logic drive_enable; // when drive enable is 0 or low the datalines should be in high impedance mode
	assign  inf.datalines = (drive_enable) ? data_out : 8'bz; //continious assignment of the datalines with data_out 8bit latch
	


	
	always_ff @(posedge inf.clk or posedge inf.rst) begin 
		if(inf.rst) begin
				for(int i = 0; i<32; i++)
					ram_mem[i] <= 8'b0;
		end else if(!inf.cs) begin 
		end else if(inf.rd == 1'b1 && inf.wd == 1'b1) begin
			drive_enable <= 1'b0;
		end else if(inf.rd == 1'b1) begin
				drive_enable <=1'b1; 
				data_out <= ram_mem[inf.addlines];
		end else if(inf.wd == 1'b1) begin 
				drive_enable <=1'b0;
				ram_mem[inf.addlines] <= inf.datalines;
		end else begin 
			drive_enable <=1'b0;
		end
	end
endmodule



module Ram_tb();
logic clk;
mem_if m(clk);
RAM dut(m);
assign m.clk = clk;



initial begin 
	clk = 0;
	forever #5 clk = ~clk;
		
end

	
initial begin
	m.rst = 1'b1;
	#10 m.rst = 1'b0;
	

	//Write 69 in the RAM at address 20
	m.cb.cs<=1'b1;
	
	m.cb.addlines <= 5'd20;
	m.cb.wd <= 1'b1; 
	#10 m.cb.wd <= 1'b0;
	force m.datalines = 8'd69;
	#50
	release m.datalines;
	
	
	//Read from the address 20
	m.cb.rd <= 1'b1;
	#50 m.cb.rd <= 1'b0;

	#200 $finish;


end


	



endmodule
