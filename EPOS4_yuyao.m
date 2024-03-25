% Initialize and setup the EPOS4 motor controller

% Create motor
Motor1 = Epos4(0, 0);

try
    % Enable motor
    Motor1.EnableNode;

    % Set the initial operation mode to Profile Position Mode
    Motor1.SetOperationMode(OperationModes.ProfilePositionMode);

    % Set motor parameters (replace with appropriate values for DCX 22L)
    targetPullPosition = -10000;
    targetPushPosition = 10000;

    % Set the desired current to hold the motor in position
    desiredCurrent = 1000;  % Adjust this value based on your motor characteristics

    % Display initial position
    disp(['Initial motor position: ', num2str(Motor1.ActualPosition)]);

    % Monitor motor position continuously
    while true
        % Check for and clear any errors
        if Motor1.IsInErrorState
            Motor1.ClearErrorState;
        end

        % Read current position
        currentPosition = Motor1.ActualPosition;
        % Check if motor is close to 10000 (push)
        if currentPosition >= targetPushPosition
            disp('Push');
        end

        % Pause for a short duration before checking position again
        pause(0.1);

        % Check if motor is close to or less than -10000 (pull)
        if currentPosition <= targetPullPosition
            disp('Pull');

            % Change to Current Mode
            Motor1.SetOperationMode(OperationModes.CurrentMode);

            % Apply the desired current to hold the motor in place
            Motor1.MotionWithCurrent(desiredCurrent);
            
            % Pause to hold the position for the specified duration (1 second)
            pause(1);

            % Check error
            if (Motor1.IsInErrorState)
                Motor1.ClearErrorState;
            end
            % Enable motor
            Motor1.EnableNode;

            % Change to Profile Position Mode
            Motor1.SetOperationMode(OperationModes.ProfilePositionMode);

            % Move the motor back to position 0
            Motor1.MotionInPosition(0, 10000, 200, 1);
            Motor1.WaitUntilDone(1000);  % Wait for the motion to complete

            disp('Motor returned to position 0.');
        end

        % Pause for a short duration before checking position again
        pause(0.1);
    end

catch ME
    disp('An error occurred during motor control.');
    disp(ME.message);
end

% Destroy motor and clear variables
delete(Motor1);
clear Motor1;
