module fifo #(
    parameter DATA_WIDTH = 32,
    parameter FIFO_DEPTH = 8
)(
    input wire clk,
    input wire rst,
    input wire wr_en,
    input wire rd_en,
    input wire cs,
    input wire [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout,
    output wire full,
    output wire empty
);

    localparam FIFO_DEPTH_LOG = $clog2(FIFO_DEPTH);

    // FIFO memory
    reg [DATA_WIDTH-1:0] fifo [0:FIFO_DEPTH-1];

    // Read and write pointers with extra bit for full/empty detection
    reg [FIFO_DEPTH_LOG:0] wr_ptr;
    reg [FIFO_DEPTH_LOG:0] rd_ptr;

    // WRITE logic
    always @(posedge clk or negedge rst) begin
        if (!rst)
            wr_ptr <= 0;
        else if (cs && wr_en && !full) begin
            fifo[wr_ptr[FIFO_DEPTH_LOG-1:0]] <= din;
            wr_ptr <= wr_ptr + 1'b1;
        end
    end

    // READ logic
    always @(posedge clk or negedge rst) begin
        if (!rst)
            rd_ptr <= 0;
        else if (cs && rd_en && !empty) begin
            dout <= fifo[rd_ptr[FIFO_DEPTH_LOG-1:0]];
            rd_ptr <= rd_ptr + 1'b1;
        end
    end

    // FIFO status signals
    assign empty = (rd_ptr == wr_ptr);
    assign full  = (rd_ptr == {~wr_ptr[FIFO_DEPTH_LOG], wr_ptr[FIFO_DEPTH_LOG-1:0]});

endmodule
