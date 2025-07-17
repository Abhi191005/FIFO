module fifo #(
    parameter data_width = 32,
    parameter fifo_depth = 8
)(
    input wire clk,
    input wire rst,
    input wire wr_en,
    input wire rd_en,
    input cs,
    input wire [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout,
    output wire full,
    output wire empty
);

    localparam fifo_depth_log=$clog2(fifo_depth);
    reg [data_width-1:0] fifo [0:fifo_depth-1];
    reg [fifo_depth_log:0] wr_ptr = 0;
    reg [fifo_depth_log:0] rd_ptr = 0;
    reg [$clog2(DEPTH+1):0] count = 0;

    assign full = (count == DEPTH);
    assign empty = (count == 0);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count <= 0;
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr] <= din;
                wr_ptr <= wr_ptr + 1;
                count <= count + 1;
            end
            if (rd_en && !empty) begin
                dout <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1;
                count <= count - 1;
            end
        end
    end

endmodule
