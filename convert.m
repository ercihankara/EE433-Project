% Load the mat file
load('sound.mat');

% Extract the data from the variable
data = sound;

% Open the text file for writing
fileID = fopen('sound.txt', 'w');

% Write the data to the text file
for i = 1:numel(data)
    fprintf(fileID, '%f\n', data(i));
end

% Close the text file
fclose(fileID);
