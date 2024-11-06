// Quiz Scoreboard with Timer - Combined Verilog Code

// Timer Module (4-bit counter with Timeout)
module Timer (
    input Clock,
    input reset,
    output [3:0] binary_count,
    output reg timeout
);
    reg [3:0] count;

    always @(posedge Clock or posedge reset) begin
        if (reset) begin
            count <= 4'b0000;
            timeout <= 1'b0;
        end else if (count == 4'b1111) begin
            count <= 4'b0000;
            timeout <= 1'b1;
        end else begin
            count <= count + 1;
            timeout <= 1'b0;
        end
    end

    assign binary_count = count;
endmodule

// FSM (Finite State Machine)
module FSM (
    input Clock,
    input SS,    // Start Signal
    input RR,    // Reset Signal
    input TT,    // Timer Trigger
    input AA,    // Answer Input Trigger
    output reg Q0,
    output reg Q1,
    output reg Q2
);
    always @(posedge Clock) begin
        if (RR) begin
            {Q2, Q1, Q0} <= 3'b000;
        end else begin
            case ({Q2, Q1, Q0})
                3'b000: if (SS) {Q2, Q1, Q0} <= 3'b001;
                3'b001: if (TT) {Q2, Q1, Q0} <= 3'b010;
                3'b010: if (AA) {Q2, Q1, Q0} <= 3'b011;
                3'b011: {Q2, Q1, Q0} <= 3'b000;
                default: {Q2, Q1, Q0} <= 3'b000;
            endcase
        end
    end
endmodule

// Randomizer (Generates random 5-bit question)
module Randomizer (
    input Clock,
    output reg [4:0] Q
);
    always @(posedge Clock) begin
        Q <= {Q[3:0], Q[4] ^ Q[1]}; // Simple LFSR-based random generation
    end
endmodule

// Four-Bit Adder (Adds two 4-bit numbers)
module FourBitAdder (
    input [3:0] A,
    input [3:0] B,
    output [3:0] Sum,
    output CarryOut
);
    assign {CarryOut, Sum} = A + B;
endmodule

// Four-Bit Up Counter (Increments count for the scoreboard)
module FourBitUpCounter (
    input Clock,
    input reset,
    output reg [3:0] count
);
    always @(posedge Clock or posedge reset) begin
        if (reset) begin
            count <= 4'b0000;
        end else begin
            count <= count + 1;
        end
    end
endmodule

// Five-Bit Comparator (Checks if two 5-bit numbers are equal)
module FiveBitComparator (
    input [4:0] A,
    input [4:0] B,
    output reg isEqual
);
    always @(*) begin
        if (A == B) begin
            isEqual = 1'b1;
        end else begin
            isEqual = 1'b0;
        end
    end
endmodule

// Main Module: Quiz Scoreboard with Timer
module QuizScoreboard (
    input Clock,
    input Start,
    input Reset,
    input Submit,
    input [4:0] Answer,         // Answer input
    output reg [3:0] Scoreboard, // Scoreboard output
    output Timeout               // Timeout signal from Timer
);

    // Internal wires
    wire [3:0] timer_count;
    wire [4:0] random_question;
    wire [3:0] added_score;
    wire isEqual;

    // FSM State and control signals
    wire Q0, Q1, Q2;
    wire SS = Start;
    wire RR = Reset;
    wire TT = Timeout;
    wire AA = Submit;

    // Instantiate Timer (4-bit counter with timeout)
    Timer timer (
        .Clock(Clock),
        .reset(Reset),
        .binary_count(timer_count),
        .timeout(Timeout)
    );

    // Instantiate FSM for control logic
    FSM fsm (
        .Clock(Clock),
        .SS(SS),
        .RR(RR),
        .TT(TT),
        .AA(AA),
        .Q0(Q0),
        .Q1(Q1),
        .Q2(Q2)
    );

    // Instantiate Randomizer for generating random question
    Randomizer randomizer (
        .Clock(Clock),
        .Q(random_question)
    );

    // Instantiate Four-Bit Adder to add scores
    FourBitAdder adder (
        .A(Scoreboard),
        .B(4'b0001),        // Add 1 to the current score if answer is correct
        .Sum(added_score),
        .CarryOut()         // Carry out is not used here
    );

    // Instantiate Four-Bit Up Counter for the Scoreboard
    FourBitUpCounter score_counter (
        .Clock(Clock),
        .reset(Reset),
        .count(Scoreboard)
    );

    // Instantiate Five-Bit Comparator for checking answers
    FiveBitComparator comparator (
        .A(random_question), 
        .B(Answer), 
        .isEqual(isEqual)
    );

    // Score increment logic
    // If answer is correct (isEqual is high), update the Scoreboard using the adder output
    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            Scoreboard <= 4'b0000;  // Reset the scoreboard
        end else if (isEqual && Submit) begin
            Scoreboard <= added_score; // Update score if answer is correct
        end
    end

endmodule
