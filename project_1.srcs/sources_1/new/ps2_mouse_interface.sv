module ps2_mouse_interface (
    input logic CLK,                      
    input logic PS2_CLK,                 
    input logic PS2_DATA,                
    input logic [2:0] SW,                
    input logic BRUSH_SWITCH,            
    output logic HSYNC, VSYNC,           
    output logic [3:0] RED, [3:0] GREEN, [3:0] BLUE, 
    output logic mouse_up, logic mouse_down, logic mouse_left, logic mouse_right, logic left_click, logic right_click
);
  
    ps2_mouse_handler mouse (
        .CLK(CLK),
        .PS2_CLK(PS2_CLK),
        .PS2_DATA(PS2_DATA),
        .left_click(left_click),
        .right_click(right_click),
        .mouse_up(mouse_up),
        .mouse_down(mouse_down),
        .mouse_left(mouse_left),
        .mouse_right(mouse_right)
    );

    drawing_canvas canvas ( PS2_CLK, CLK, mouse_up, mouse_down, mouse_right, mouse_left, left_click, 
        SW, BRUSH_SWITCH, HSYNC, VSYNC, RED, GREEN, BLUE);

endmodule