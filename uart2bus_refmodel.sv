module uart2bus_refmodel (	input clock,
							input reset,
							// UART IF
							input ser_in,
							output ser_out,
							// BUS IF
							output reg [15:0] int_address,
							output reg [7:0] int_wr_data,
							output int_write,
							output int_read,
							input [7:0] int_rd_data,
							output int_req,
							input int_gnt);

reg [7:0] mode=0'hff,
	white = 0'hff,
	data = 0'hff,
	temp_data,
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

task automatic space_field();
	repeat(9) begin
		#1 white <= {ser_in,white[7:1]};
	end	
endtask

task automatic address_field();
	repeat(16) begin
		#1 address <= {ser_in,address[15:1]};
	end
endtask

task automatic data_field();
	repeat(8) begin
		#1 data <= {ser_in,data[7:1]};
	end	
endtask

task automatic EOL_field();
	repeat(9) begin
		#1 EOL <= {ser_in,EOL[7:1]};
	end
endtask

task automatic Write();
	fork
		begin
			space_field();
		end
		begin
			#8 data_field();
		end
		begin
			#16 space_field();
		end
		begin
			#24 address_field();
		end
		begin
			#40 EOL_field();
		end
	join_any	
endtask

task automatic Read();
	fork
		begin
			space_field();
		end
		begin
			#8 address_field();
		end
		begin
			#24 EOL_field();
		end
	join_any
endtask

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
				Write();
				if (white == space || white == tab) begin
					#8  assign temp_data=data;
					#8  if (white == space || white == tab)begin
								#16 assign temp_int_address=address;
								#8  if (EOL == CR || EOL== LF) begin
											assign int_address=temp_int_address;
											assign int_wr_data=temp_data;
										end	
							end
			end
			else if (mode == R || mode == r) begin 		//read text mode
				Read();											
				if (white == space || white == tab) begin
					#16 assign temp_int_address=address;
					#8  if (EOL == CR || EOL== LF) begin
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