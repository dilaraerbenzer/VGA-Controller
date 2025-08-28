module ps2_mouse_handler (
    input logic CLK,                   
    input logic PS2_CLK,               
    input logic PS2_DATA,              
    output logic left_click,           
    output logic right_click,          
    output logic mouse_up,             
    output logic mouse_down,           
    output logic mouse_left,           
    output logic mouse_right           
);

    logic [5:0] index;
    logic [43:0] data;

    always_ff @(posedge PS2_CLK) begin
        if (index <= 42) index <= index + 1;
        else index <= 0;
    end

    always_ff @(negedge PS2_CLK) begin
        data[index] <= PS2_DATA;
    end

    // validation logic
    bit validation0;
    assign validation0 = ~data[0] && ~data[11] && ~data[22] && ~data[33] && data[10] && data[21] && data[32] && data[43];
    assign validation1 = ~^data[8:1];
    assign validation2 = ~^data[19:12];
    assign validation3 = ~^data[30:23];
    assign validation4 = ~^data[41:34];

    bit validation;
    assign validation = validation0 && 
                        (validation1 == data[9]) && 
                        (validation2 == data[20]) && 
                        (validation3 == data[31]) && 
                        (validation4 == data[42]);
                        
    logic [43:0] copy_data;
    
    always @ (*) begin
        if (index == 42 && validation) begin
            copy_data <= data;
        end
    end
    
    assign left_click = copy_data[1];
    assign right_click = copy_data[2];
    assign mouse_right = (~copy_data[19:12] > 8) ? ~copy_data[5] : 0;
    assign mouse_left = (copy_data[19:12] > 9) ? copy_data[5] : 0;
    assign mouse_up = (~copy_data[30:23] > 9) ? ~copy_data[6] : 0;
    assign mouse_down =(copy_data[30:23]> 9) ? copy_data[6] : 0;

endmodule