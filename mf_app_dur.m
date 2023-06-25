% MF application for the detection of an incoming chirp signal and duration estimation
% owkr in the duration of 0-20sec
function [duration_est, detection_chirp] = mf_app_dur(sound, start_freq, end_freq) %#codegen

    % generate a set of chirp signals with different frequency sweeps and durations
    Fs = 1e+04; % sampling rate in Hz
    duras = 1:1:20; % duration of the chirp signals in seconds
    fstart = start_freq; % start frequency of the chirp signals in Hz, from user
    fend = end_freq; % end frequency of the chirp signals in Hz, from user
    numChirps = length(duras); % number of chirp signals to generate
    chirpSet = cell(numChirps, 1);
    for i = 1:numChirps
        t = linspace(0, duras(i), Fs*duras(i));
        f = linspace(fstart, fend, length(t));
        chirpSet{i} = chirp(t, f(1), duras(i), f(end));
    end

    % create a set of matched filters that correspond to the generated chirp signals
    matchedFilters = cell(numChirps, 1);
    for i = 1:numChirps
        matchedFilters{i} = conj(fliplr(chirpSet{i}));
    end

    % convolve the input signal with each of the matched filters in the set
    inputSignal = sound;
    correlationOutputs = zeros(numChirps, length(inputSignal));
    for i = 1:numChirps
        correlationOutputs(i,:) = conv(inputSignal, matchedFilters{i}, 'same');
    end

    max_arr = zeros(numChirps, 1);
    for i = 1:numChirps
        max_arr(i) = max(correlationOutputs(i,:));
    end

    [~, max_ind] = max(max_arr);
    % analyze the correlation outputs to determine which one corresponds to the highest correlation
    [maxCorrelation, ~] = max(abs(correlationOutputs), [], 1);

    % determine a threshold for the correlation output to classify the input as a chirp signal or not
    threshold = 2000;
    %maxer = max(maxCorrelation);
    
    % classify the input as a chirp signal or not; if chirp continue, else
    % finish the program
    if max(maxCorrelation) > threshold
        %disp(['The input signal is a chirp signal with duration of ', num2str(duras(max_ind)), ' seconds']);
        detection_chirp = 1;
    else
        %disp('The input signal is not a chirp signal, quitting the program!');
        detection_chirp = 0;
    end
    
    duration_est = duras(max_ind);
end
