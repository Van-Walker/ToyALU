module adder_1(
	input X,
	input Y,
	input Cin,
	output F,
	output Cout
);

	assign F = X ^ Y ^ Cin;
	assign Cout = (X ^ Y) & Cin | X & Y;

endmodule

module cla_4(
	input c0, g1, g2, g3, g4, p1, p2, p3, p4,
    output c1, c2, c3, c4
);

	assign c1 = g1 ^ (p1 & c0),
		   c2 = g2 ^ (p2 & g1) ^ (p2 & p1 & c0),
           c3 = g3 ^ (p3 & g2) ^ (p3 & p2 & g1) ^ (p3 & p2 & p1 & c0),
           c4 = g4 ^ (p4 & g3) ^ (p4 & p3 & g2) ^ (p4 & p3 & p2 & g1) ^ (p4 & p3 & p2 & p1 & c0);

endmodule

module adder_4(
	input [4:1] x,
	input [4:1] y,
	input c0,
	output c4,
	output [4:1] F,
	output Gm,
	output Pm
);

	wire p1, p2, p3, p4, g1, g2, g3, g4;
	wire c1, c2, c3;
	
	adder_1 adder1(.X(x[1]), .Y(y[1]), .Cin(c0), .F(F[1]), .Cout());
	adder_1 adder2(.X(x[2]), .Y(y[2]), .Cin(c1), .F(F[2]), .Cout());
	adder_1 adder3(.X(x[3]), .Y(y[3]), .Cin(c2), .F(F[3]), .Cout());
	adder_1 adder4(.X(x[4]), .Y(y[4]), .Cin(c3), .F(F[4]), .Cout());

	cla_4 cla4(.c0(c0), .c1(c1), .c2(c2), .c3(c3), .c4(c4), .p1(p1), .p2(p2),
        .p3(p3), .p4(p4), .g1(g1), .g2(g2), .g3(g3), .g4(g4));

	assign p1 = x[1] ^ y[1],      
           p2 = x[2] ^ y[2],
           p3 = x[3] ^ y[3],
           p4 = x[4] ^ y[4];

    assign g1 = x[1] & y[1],
           g2 = x[2] & y[2],
           g3 = x[3] & y[3],
           g4 = x[4] & y[4];

    assign Pm = p1 & p2 & p3 & p4,
           Gm = g4 ^ (p4 & g3) ^ (p4 & p3 & g2) ^ (p4 & p3 & p2 & g1);

endmodule

module cla_16(
	input [16:1] A,
	input [16:1] B,
	input c0,
	output gx, px,
	output [16:1] S
);

	wire c4, c8, c12;
	wire Pm1, Gm1, Pm2, Gm2, Pm3, Gm3, Pm4, Gm4;

	adder_4 adder1(.x(A[4:1]), .y(B[4:1]), .c0(c0), .c4(), .F(S[4:1]), .Gm(Gm1), .Pm(Pm1));
	adder_4 adder2(.x(A[8:5]), .y(B[8:5]), .c0(c4), .c4(), .F(S[8:5]), .Gm(Gm2), .Pm(Pm2));
	adder_4 adder3(.x(A[12:9]), .y(B[12:9]), .c0(c8), .c4(), .F(S[12:9]), .Gm(Gm3), .Pm(Pm3));
	adder_4 adder4(.x(A[16:13]), .y(B[16:13]), .c0(c12), .c4(), .F(S[16:13]), .Gm(Gm4), .Pm(Pm4));

	assign c4 = Gm1 ^ (Pm1 & c0),
           c8 = Gm2 ^ (Pm2 & Gm1) ^ (Pm2 & Pm1 & c0),
           c12 = Gm3 ^ (Pm3 & Gm2) ^ (Pm3 & Pm2 & Gm1) ^ (Pm3 & Pm2 & Pm1 & c0);

    assign px = Pm1 & Pm2 & Pm3 & Pm4,
           gx = Gm4 ^ (Pm4 & Gm3) ^ (Pm4 & Pm3 & Gm2) ^ (Pm4 & Pm3 & Pm2 & Gm1);

endmodule

module adder_32(
	input [32:1] A,
	input [32:1] B,
	output [32:1] S,
	output c32
);
	
	wire px1, gx1, px2, gx2;
	wire c0 = 0;
	wire c16;

	cla_16 cla1(.A(A[16:1]), .B(B[16:1]), .c0(c0), .gx(gx1), .px(px1), .S(S[16:1]));
	cla_16 cla2(.A(A[32:17]), .B(B[32:17]), .c0(c16), .gx(gx2), .px(px2), .S(S[32:17]));

	assign c16 = gx1 ^ (px1 && 0),
		   c32 = gx2 ^ (px2 && c16);

endmodule

module Add(
	input wire[32:1] a,
	input wire[32:1] b,
	output reg[32:1] sum
);

	wire [32:1] res;
	adder_32 add(.A(a), .B(b), .S(res), .c32());
	always @* begin
		sum <= res;
	end

endmodule

module multiplier(
    input [31:0] A,
    input [31:0] B,
    output reg[64:0] ans
); 

    reg [6:0] cnt;

    initial begin
        cnt <= 7'b0;
        ans <= 65'b0;
    end

    always @* begin
        ans [31:0] = B;
        cnt = 0;
        while (cnt < 32) begin
            if (ans[0] == 1) begin
                ans[64:32] = ans[64:32] + A;
            end
            ans = ans >> 1;
            cnt = cnt + 1;
        end
        $display("ans = ", ans);
    end

endmodule
