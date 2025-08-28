module drawing_canvas (
    input logic PCLK2,
    input logic CLK,                     
    input logic BTNU, BTND, BTNR, BTNL, BTNC,
    input logic [2:0] SW,         // 3 bits for 8 colours  
    input logic BRUSH_SWITCH,           
    output logic HSYNC, VSYNC,           
    output logic [3:0] RED, GREEN, BLUE   
);

    
    logic PCLK; // pixel clock
    clock_divider clk_div(4, CLK, PCLK);

    logic [2:0] pixel_frame [0:29][0:39]; // packed 2-d array

    int cursor_x = 0;  
    int cursor_y = 0;  
    
    int counter = 0;
    logic [3:0]direction = 0;
    
    clock_divider clkdiv(6, PCLK2, outCLK);
    
    always_ff@(negedge outCLK) begin
        if (counter >= 42) begin 
            counter <= 0;
                if (BTNU && cursor_y > 0) cursor_y <= cursor_y - 1; 
                if (BTND && cursor_y < 479) cursor_y <= cursor_y + 1; 
                if (BTNL && cursor_x > 0) cursor_x <= cursor_x - 1; 
                if (BTNR && cursor_x < 639) cursor_x <= cursor_x + 1;
        end
        else begin 
            counter <= counter + 1;
            direction <= 0;
        end
    end

    logic [3:0] color_r, color_g, color_b;
    always_comb begin
        color_r = SW[0] ? 4'b1111 : 4'b0000;
        color_g = SW[1] ? 4'b1111 : 4'b0000;
        color_b = SW[2] ? 4'b1111 : 4'b0000;
    end

    initial begin
        for (int x = 0; x < 40; x++) begin
            for (int y = 0; y < 30; y++) begin
                pixel_frame[y][x] = 3'b000; // all-white background initially
            end
        end
    end
    
//    logic SCLK;
//    clock_divider slow_clk(5_000_000, CLK, SCLK);

   always_ff @(posedge PCLK2) begin
       if (BTNC) begin
           if (BRUSH_SWITCH) begin
               // 3x3 brush
               for (int dx = -1; dx <= 1; dx++) begin
                   for (int dy = -1; dy <= 1; dy++) begin
                       if ((cursor_x + dx >= 0 && cursor_x + dx < 640) &&
                           (cursor_y + dy >= 0 && cursor_y + dy < 480)) begin
                           pixel_frame[cursor_y + dy][cursor_x + dx] <= SW[2:0];
                           pixel_frame[cursor_y + dy][cursor_x + dx] <= SW[2:0];
                       end
                   end
               end
           end else begin
               // ordinary 1 pixel brush
               pixel_frame[cursor_y][cursor_x] <= SW[2:0];
           end
       end
   end

    int clk_count = 0;
    int line = 0;

    always_ff @(posedge PCLK) begin

        HSYNC <= (clk_count < 656 || clk_count >= 752);
        VSYNC <= (line < 490 || line >= 492);

        if (clk_count < 640 && line < 480) begin // pixel render
            BLUE <= pixel_frame[line/16][clk_count/16][2] ? 4'b1111 : 4'b0000;
            GREEN <= pixel_frame[line/16][clk_count/16][1] ? 4'b1111 : 4'b0000;
            RED <= pixel_frame[line/16][clk_count/16][0] ? 4'b1111 : 4'b0000;

             for (int dy = -1; dy <= 1; dy++) begin
                if (clk_count/16 == cursor_x && line/16 + dy == cursor_y) begin
                    RED <= color_r;
                    GREEN  <= color_g;
                    BLUE <= color_b;
                end
            end
             for (int dx = -1; dx <= 1; dx++) begin
                if (clk_count/16 + dx == cursor_x && line/16 == cursor_y) begin
                    RED <= color_r;
                    GREEN  <= color_g;
                    BLUE <= color_b;
                end
            end
        end else begin
            RED <= 0;
            GREEN <= 0;
            BLUE <= 0;
        end

        if (clk_count < 800) begin
            clk_count <= clk_count + 1;
        end else begin
            clk_count <= 0;
            if (line < 525) begin
                line <= line + 1;
            end else begin
                line <= 0;
            end
        end
    end

endmodule
