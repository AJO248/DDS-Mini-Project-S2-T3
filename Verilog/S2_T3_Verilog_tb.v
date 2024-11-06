`timescale 1ns / 1ps

module QuizScoreboard_tb;

    // Inputs to the QuizScoreboard
    reg Clock;
    reg Start;
    reg Reset;
    reg Submit;
    reg [4:0] Answer;

    // Outputs from the QuizScoreboard
    wire [3:0] Scoreboard;
    wire Timeout;

    // Internal signals
    reg [4:0] correct_answer;
    wire [4:0] random_question;
    wire isEqual;

    // Instantiate the QuizScoreboard module
    QuizScoreboard uut (
        .Clock(Clock),
        .Start(Start),
        .Reset(Reset),
        .Submit(Submit),
        .Answer(Answer),
        .Scoreboard(Scoreboard),
        .Timeout(Timeout)
    );

    // Generate clock signal
    always begin
        #5 Clock = ~Clock;  // Toggle clock every 5ns
    end

    // Test procedure
    initial begin
        // Initialize the inputs
        Clock = 0;
        Start = 0;
        Reset = 0;
        Submit = 0;
        Answer = 5'b00000;
        
        // Wait for a few clock cycles for simulation setup
        #10;

        // Reset the scoreboard
        Reset = 1;
        #10;
        Reset = 0;
        
        // Simulate starting the quiz
        Start = 1;
        #10;
        Start = 0;
        
        // Simulate random question generation and answering
        // Let's assume the random question generated is 5'b00101 for this test
        correct_answer = 5'b00101;
        
        // Apply the correct answer
        Answer = correct_answer;
        
        // Submit the answer and check scoreboard update
        Submit = 1;
        #10;
        Submit = 0;

        // Check the scoreboard value (should increment by 1)
        #10;
        if (Scoreboard != 4'b0001) begin
            $display("Test failed: Scoreboard should be 1, got %b", Scoreboard);
        end else begin
            $display("Test passed: Scoreboard correctly updated to %b", Scoreboard);
        end

        // Simulate Timeout condition and observe the timeout signal
        // Wait for the timer to timeout
        #100;
        if (Timeout == 1) begin
            $display("Test passed: Timeout occurred.");
        end else begin
            $display("Test failed: Timeout did not occur.");
        end

        // Finish the test
        $finish;
    end

endmodule
