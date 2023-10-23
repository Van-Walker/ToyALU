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
