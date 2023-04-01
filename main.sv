module main(
	input CLK,
	input [3:0] KEY,
	input RES,
	output [3:0] DIG,
	output [7:0] SEG,
	output [3:0] SEcs
);
	reg [25:0] cnt = 26'd0;
	reg [25:0] cnt2 = 26'd0;
	
	reg [3:0] SEC = 4'd0;
	reg [3:0] SEC2 = 4'd0;
	reg [3:0] MIN = 4'd0;
	reg [3:0] MIN2 = 4'd0;
	reg [3:0] HRS = 4'd0;
	reg [3:0] HRS2 = 4'd0;
	
	wire [6:0] segments;
	wire [3:0] code;
	enum reg [1:0] {SHN, FHN, SMN, FMN} state = FMN;
	enum reg [2:0] {IDLE, INCCLK, DECCLK, INCMIN, DECMIN, RESSEC} bstate = IDLE;
	
	assign SEcs = ~SEC;
	
	always @(posedge CLK) begin
		cnt <= cnt + 26'b1;
		if (cnt == 26'd50000000) begin
			cnt <= 26'd0;
			SEC <= SEC + 4'd1;
			if(SEC == 4'd9) begin
				SEC <= 4'd0;
				SEC2 <= SEC2 + 4'd1;
				if(SEC2 == 4'd5 & SEC == 4'd9) begin
					SEC2 <= 4'd0;
					SEC <= 4'd0;
					MIN <= MIN + 4'd1;
					if (MIN == 4'd9) begin
						MIN <= 4'd0;
						MIN2 <= MIN2 + 4'd1;
						if (MIN2 == 4'd5 & MIN == 4'd9) begin
							MIN2 <= 4'd0;
							MIN <= 4'd0;
							HRS <= HRS + 4'd1;
							if (HRS == 4'd9) begin
								HRS <= 4'd0;
								HRS2 <= HRS2 + 4'd1;
								if (HRS2 == 4'd2 & HRS == 4'd3) begin
									HRS2 <= 4'd0;
									HRS <= 4'd0;
								end
							end
						end
					end
				end
			end
			if (~KEY[0]) begin
				HRS <= HRS + 4'd1;
				if (HRS == 4'd9) begin
					HRS <= 4'd0;
					HRS2 <= HRS2 + 4'd1;
					if (HRS2 == 4'd2 & HRS == 4'd3) begin
						HRS2 <= 4'd0;
						HRS <= 4'd0;
					end
				end
			end
			if (~KEY[1]) begin
				HRS <= HRS - 4'd1;
				if (HRS == 4'd0) begin
					HRS <= 4'd9;
					HRS2 <= HRS2 - 4'd1;
					if (HRS2 == 4'd0 & HRS == 4'd0) begin
						HRS2 <= 4'd2;
						HRS <= 4'd3;
					end
				end
			end 
			if (~KEY[2]) begin
				MIN <= MIN + 4'd1;
				if (MIN == 4'd9) begin
					MIN <= 4'd0;
					MIN2 <= MIN2 + 4'd1;
					if (MIN2 == 4'd5 & MIN == 4'd9) begin
						MIN2 <= 4'd0;
						MIN <= 4'd0;
					end
				end
			end
			if (~KEY[3]) begin
				MIN <= MIN - 4'd1;
				if (MIN == 4'd0) begin
					MIN <= 4'd9;
					MIN2 <= MIN2 - 4'd1;
					if (MIN2 == 4'd0 & MIN == 4'd0) begin
						MIN2 <= 4'd5;
						MIN <= 4'd9;
					end
				end
			end
			if (~RES) begin
				SEC2 <= 4'd0;
				SEC <= 4'd0;
			end
		end
	end
	
	
	
	
	
	always @(posedge CLK) begin
		cnt2 <= cnt2 + 26'b1;
		if (cnt2 == 26'd5000) begin
			cnt2 <= 26'd0;
			case(state)
				FMN: begin
					DIG <= 4'b1110;
					code <= MIN;
					state <= SMN;
					SEG[7] <= 1;
				end
				SMN: begin
					DIG <= 4'b1101;
					code <= MIN2;
					state <= FHN;
					SEG[7] <= 1;
				end
				FHN: begin
					DIG <= 4'b1011;
					code <= HRS;
					state <= SHN;
					SEG[7] <= 0;
				end
				SHN: begin
					DIG <= 4'b0111;
					code <= HRS2;
					state <= FMN;
					SEG[7] <= 1;
				end
			endcase
		end
	end
	
		indicator16 dec(
			.code(code),
			.segments(segments)
		);
		
		assign SEG[0] = ~segments[0];
		assign SEG[1] = ~segments[1];
		assign SEG[2] = ~segments[2];
		assign SEG[3] = ~segments[3];
		assign SEG[4] = ~segments[4];
		assign SEG[5] = ~segments[5];
		assign SEG[6] = ~segments[6];
		

endmodule 

module indicator16(
 input wire [3:0]code,
 output reg [6:0]segments
);

always @*
begin
  case(code)
   4'd0:  segments = 7'b0111111;
   4'd1:  segments = 7'b0000110;
   4'd2:  segments = 7'b1011011;
   4'd3:  segments = 7'b1001111;
   4'd4:  segments = 7'b1100110;
   4'd5:  segments = 7'b1101101;
   4'd6:  segments = 7'b1111101;
   4'd7:  segments = 7'b0000111;
   4'd8:  segments = 7'b1111111;
   4'd9:  segments = 7'b1101111;
   4'd10: segments = 7'b1110111;
   4'd11: segments = 7'b1111100;
   4'd12: segments = 7'b0111001;
   4'd13: segments = 7'b1011110;
   4'd14: segments = 7'b1111011;
   4'd15: segments = 7'b1110001;
  endcase
end

endmodule
