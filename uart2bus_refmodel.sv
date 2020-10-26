module uart2bus_refmodel (	input clock,
							input reset,
							// UART IF
							input ser_in,
							output ser_out,
							// BUS IF
							output reg [15:0] int_address,
							output [7:0] int_wr_data,
							output int_write,
							output int_read,
							input [7:0] int_rd_data,
							output int_req,
							input int_gnt);

reg [7:0] mode=0'hff,
	white = 0'hff, 
	EOL = 0'hff,
 	w = 0'h77,
 	W = 0'h57,
 	r = 0'h72,
 	R = 0'h52,
 	b = 0'h00,
	CR =0'h0a,
	LF =0'h0d,
	space = 0'h20,
	tab = 0'h09;
reg [15:0] temp_int_address, address = 0'hffffffff;

task automatic Read();
	fork
		begin //space field
			repeat(9) begin
				#1 white <= {ser_in,white[7:1]};
			end	
		end
		begin
			#8
			repeat(16) begin //address field
				#1 address <= {ser_in,address[15:1]};
			end
		end
		begin
			#16
			repeat(9) begin //EOL field
				#1 EOL <= {ser_in,EOL[7:1]};
			end
		end
	join_any
endtask //automatic

initial begin
if (reset == 0 && ser_in == 0) begin
	fork
		begin
			//check the mode
			repeat(9) begin
				#1 mode <= {ser_in,mode[7:1]};
			end
		end
		begin
	  	#9
			if (mode == W || mode == w) begin 				//write text mode
				//space field
				//data field
				//space field
				//address field
				//EOL field
			end
			else if (mode == R || mode == r) begin 		//read text mode
				Read();													
				if (white == space || white == tab) begin
					#16   assign temp_int_address=address;
					#8 if (EOL == CR || EOL== LF) begin
						assign int_address=temp_int_address;
					end		
				end
			end
			else if (mode == b) begin 								//binary mode
				//command byte
				//Address High Byte
				//Address Low Byte
				//Length
			end
		end
	join
end
end
ser_out <= 1'b1 ;

endmodule