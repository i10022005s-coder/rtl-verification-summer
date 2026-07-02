module sequence_detector_1011 (
    input logic clock,
    input logic reset,
    input logic serial_in,
    output reg detected
);

    typedef enum logic [1:0] {S0, S1, S2, S3} statetype;
    statetype state, nextstate;

    logic next_detected;

    always_ff @(posedge clock, posedge reset) begin 
        if (reset)
        begin
            state <= S0;
            detected <= 1'b0;
        end 
        else begin
            state <= nextstate;
            detected <= next_detected;
        end
    end

    always @(*) begin
        nextstate = state;
        next_detected = 1'b0;
        case (state)
            S0: if (serial_in) nextstate = S1;
                else nextstate = S0;
            S1: if (serial_in) nextstate = S1;
                else nextstate = S2;
            S2: if (serial_in) nextstate = S3;
                else nextstate = S0;
            S3: if (serial_in) begin 
                    nextstate = S1;
                    next_detected = 1'b1;
                end
                else nextstate = S2;
            default: nextstate = S0;
        endcase
    end


endmodule