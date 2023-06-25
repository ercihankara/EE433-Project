function [detection_chirp, duration_est, freqs, ampl_est, bandwidth_est, rate_freq] = pther(sound, start_freq, end_freq) %#codegen
    % MF application for the detection of an incoming chirp signal and duration
    % estimation

    % generate a set of chirp signals with different frequency sweeps and durations
    Fs = 1e+04; % sampling rate in Hz
    duras = 1:1:20; % duration of the chirp signals in seconds
    fstart = start_freq; % start frequency of the chirp signals in Hz
    fend = end_freq; % end frequency of the chirp signals in Hz
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
    filteredSoundData = sound;
    % convolve the input signal with each of the matched filters in the set
    inputSignal = filteredSoundData;
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
    %chirpSet = {}; % initialize chirpSet to an empty cell array
    if max(maxCorrelation) > threshold
        %disp(['The input signal is a chirp signal with duration of ', num2str(duras(max_ind)), ' seconds']);
        detection_chirp = 1;
        % generate a new set of chirp signals with different frequency sweeps and durations
        dura_det = duras(max_ind); % duration of the chirp signals in seconds
        fstart = 0:200:2000; % start frequency of the chirp signals in Hz
        fend = 2000:200:4000; % end frequency of the chirp signals in Hz
        numChirps = length(fstart) * length(fend); % number of chirp signals to generate
        chirpSet = cell(numChirps, 1);
        freq_set = cell(numChirps, 1);
        k = 1;
        for j = 1:length(fstart)
            for i = 1:length(fend)
                t = linspace(0, dura_det, Fs*dura_det);
                %f = linspace(fstart(j), fend(i), length(t));
                chirpSet{k} = chirp(t, fstart(j), dura_det, fend(i));
                freq_set{k} = [fstart(j) fend(i)];
                k = k + 1;
            end
        end
        % create a set of matched filters that correspond to the generated chirp signals
        matchedFilters = cell(numChirps, 1);
        for i = 1:numChirps
            matchedFilters{i} = conj(fliplr(chirpSet{i}));
        end
        filteredSoundData = sound(1:end-1);
        % convolve the input signal with each of the matched filters in the set
        inputSignal = filteredSoundData;
        correlationOutputs = zeros(numChirps, length(inputSignal));
        for i = 1:numChirps
            correlationOutputs(i,:) = conv(inputSignal(:), matchedFilters{i}(:), 'same');
        end
        for i = 1:numChirps
            max_arr(i) = max(correlationOutputs(i,:));
        end
        [~, max_ind_freq] = max(max_arr);
        % analyze the correlation outputs to determine which one corresponds to the highest correlation
        [maxCorrelation_freq, ~] = max(abs(correlationOutputs), [], 1);
        max(maxCorrelation_freq);
        % frequency estimation
        freqs = freq_set{max_ind_freq};

        % frequency, amplitude, rate of frequency increase and bandwidth estimation
    
        % while creating the sound signal, the incoming data is amplified by a
        % constant. thus, checking the max value gives a near value to the original
        % amplitude. however, exact value cannot be reached due to the transmission
        % of the created signal from one device to another
        ampl_est = max(abs(filteredSoundData));
        %disp(['amplitude estimation: ', num2str(ampl_est)]);
        
        %disp(['start frequency estimation: ', num2str(freqs(1))]);
        %disp(['end frequency estimation: ', num2str(freqs(2))]);
        
        bandwidth_est = freqs(2)-freqs(1);
        %disp(['bandwidth estimation: ', num2str(bandwidth_est)]);
        
        rate_freq = (bandwidth_est)/dura_det;
        %disp(['rate of frequency increase estimation: ', num2str(rate_freq)]);
        
        % periodicity estimation using autocorrelation
        % EXPLANATION IN REPORT
        plot(xcorr(sound));
        title("autocorrelation")
    else
        %disp('The input signal is not a chirp signal, quitting the program!');
        detection_chirp = 0;
        duration_est = 0;
        freqs = [0 0];
        ampl_est = 0;
        bandwidth_est = 0;
        rate_freq = 0;
        return;
    end
    
    duration_est = duras(max_ind);
end
