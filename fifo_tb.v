`timescale 1ns / 1ps
module fifo_tb;

    parameter DATA_WIDTH = 8;
    parameter DEPTH = 4;

    reg clk = 0;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;
    wire full, empty;

    fifo #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) uut (
        .clk(clk), .rst(rst),
        .wr_en(wr_en), .rd_en(rd_en),
        .din(din), .dout(dout),
        .full(full), .empty(empty)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("fifo.vcd");
        $dumpvars(0, fifo_tb);

        rst = 1; wr_en = 0; rd_en = 0; din = 0;
        #10 rst = 0;

        // Write data
        repeat (DEPTH) begin
            @(posedge clk);
            wr_en = 1; rd_en = 0; din = $random;
        end

        // Try writing when full
        @(posedge clk);
        wr_en = 1; din = 8'hAA;

        // Read all data
        repeat (DEPTH+1) begin
            @(posedge clk);
            wr_en = 0; rd_en = 1;
        end

        @(posedge clk);
        $finish;
    end

endmodule
