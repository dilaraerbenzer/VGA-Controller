module ps2_receiver (
    input logic clk,            // System clock
    input logic ps2_clk,        // PS/2 clock input
    input logic ps2_data,       // PS/2 data input
    output logic [9:0] mouse_x, // Mouse X position (10-bit)
    output logic [9:0] mouse_y, // Mouse Y position (10-bit)
    output logic left_click     // Left click state
);

    // Internal signals for PS/2 data processing
    logic [7:0] data;           // PS/2 byte data
    logic [7:0] byte_count;      // Count of received bytes
    logic data_ready;            // Flag to indicate data is ready

    logic [9:0] x_pos, y_pos;   // Mouse coordinates
    logic click;                 // Mouse click status

    // PS/2 state machine for decoding
    always_ff @(posedge clk) begin
        if (ps2_clk) begin
            // Assuming we have a PS/2 byte decoder for the mouse (you can use an existing one)
            // This part assumes receiving bytes, which will include the mouse movement and button data
            // For simplicity, we assume that the byte data is available in `data`.

            if (byte_count == 0) begin
                // Start of a new byte
                data <= ps2_data;
                byte_count <= 1;
            end else begin
                // Continue receiving bytes
                data <= {data[6:0], ps2_data}; // Shift in new data bit
                if (byte_count == 8) begin
                    // Process the byte (for simplicity)
                    if (data[7] == 1) begin
                        // Check for the sign bits (MSB of X and Y)
                        x_pos <= data[5:0];
                        y_pos <= data[5:0];
                    end
                    click <= data[0];  // Left-click button status (0: not pressed, 1: pressed)
                    byte_count <= 0;    // Reset byte count after receiving a byte
                end else begin
                    byte_count <= byte_count + 1;
                end
            end
        end
    end

    // Output the mouse position and click state
    assign mouse_x = x_pos;
    assign mouse_y = y_pos;
    assign left_click = click;

endmodule
