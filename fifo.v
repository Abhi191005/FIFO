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

    localparam fifo_depth_log = $clog2(fifo_depth);

    // FIFO memory
    reg [data_width-1:0] fifo [0:fifo_depth-1];

    // Read and write pointers with 1 extra bit for full/empty detection
    reg [fifo_depth_log:0] wr_ptr;
    reg [fifo_depth_log:0] rd_ptr;

    // WRITE logic
    always @(posedge clk or negedge rst) begin
        if (!rst)
            wr_ptr <= 0;
        else if (cs && wr_en && !full) begin
            fifo[wr_ptr[fifo_depth_log-1:0]] <= din;
            wr_ptr <= wr_ptr + 1'b1;
        end
    end

    // READ logic
    always @(posedge clk or negedge rst) begin
        if (!rst)
            rd_ptr <= 0;
        else if (cs && rd_en && !empty) begin
            dout <= fifo[rd_ptr[fifo_depth_log-1:0]];
            rd_ptr <= rd_ptr + 1'b1;
        end
    end

    // FIFO status
    assign empty = (rd_ptr == wr_ptr);
    assign full  = (rd_ptr == {~wr_ptr[fifo_depth_log], wr_ptr[fifo_depth_log-1:0]});

endmodule
    
endmodule
