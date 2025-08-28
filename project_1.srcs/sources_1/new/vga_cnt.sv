module vga_cnt( 
    input logic CLK,
    BTNU, BTND, BTNR, BTNL,
    output logic HSYNC, VSYNC, 
    output logic [3:0] RED, logic [3:0] GREEN, logic [3:0] BLUE
);

    logic PCLK;
    clock_divider clk_div(CLK, PCLK);
    logic SCLK;
    clock_divider #(10_000_000) slow_clk_div(CLK, SCLK); 

    int clk_count = 0, line = 0;
    logic [9:0] vertical_shift = 0; 
    logic [9:0] horizontal_shift = 0; 
    int adjusted_line, adjusted_clk_count;
    bit up, down, left, right;
    
    // scrolling settings
    always_ff @ (posedge SCLK) begin
        if (BTNU) begin
            up <= 1; down <= 0; left <= 0; right <= 0;
        end else if (BTND) begin
            up <= 0; down <= 1; left <= 0; right <= 0;
        end else if (BTNR) begin
            up <= 0; down <= 0; left <= 1; right <= 0;
        end else if (BTNL) begin
            up <= 0; down <= 0; left <= 0; right <= 1;
        end

        if (up) begin
            vertical_shift <= (vertical_shift + 5) % 480; 
        end else if (down) begin
            vertical_shift <= (vertical_shift - 5 + 480) % 480; 
        end else if (right) begin
            horizontal_shift <= (horizontal_shift + 5) % 640; 
        end else if (left) begin
            horizontal_shift <= (horizontal_shift - 5 + 640) % 640; 
        end
    end

    always_ff @ (posedge PCLK) begin
        if (line < 480) begin
            VSYNC <= 1;
        end else begin
            VSYNC <= 0;
        end

        if (clk_count < 640) begin
            adjusted_clk_count = (clk_count + horizontal_shift) % 640;
            adjusted_line = (line + vertical_shift) % 480;

            if (((adjusted_clk_count / 40) % 2) == ((adjusted_line / 40) % 2)) begin
                // yellow
                RED <= 4'b1111;
                GREEN <= 4'b1111;
                BLUE <= 4'b0000;
            end else begin
                // navy blue
                RED <= 4'b0100;
                GREEN <= 4'b0010;
                BLUE <= 4'b1110;
            end
        end else begin
            RED <= 0;
            GREEN <= 0;
            BLUE <= 0;
        end

        if (clk_count == 0) begin
            HSYNC <= 1; 
        end else if (clk_count == 656) begin
            HSYNC <= 0; 
        end else if (clk_count == 751) begin
            HSYNC <= 1; 
        end

        clk_count++;
        if (clk_count == 800) begin
            clk_count <= 0;
            line++;
            if (line >= 525) begin
                line <= 0;
            end
        end
    end
endmodule
