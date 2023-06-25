% MF application for the detection of an incoming chirp signal and frequency estimation
% work in the interval of 0-5000Hz OLMADI
function [freqs] = mf_app_freq(sound, dura_det) %#codegen

    % generate a set of chirp signals with different frequency sweeps and durations
    Fs = 1e+04; % sampling rate in Hz
    %dura_det = 4; % duration of the chirp signals in seconds

    fstart = 0:200:2000; % start frequency of the chirp signals in Hz
    fend = 2000:200:5000; % end frequency of the chirp signals in Hz
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

    % convert input signal and matched filters to column vectors
    inputSignal = filteredSoundData(:);
    %     for i = 1:numChirps
    %         matchedFilters{i} = matchedFilters{i}(:);
    %     end

    % convolve the input signal with each of the matched filters in the set
    %inputSignal = filteredSoundData(:);
    correlationOutputs = zeros(numChirps, length(inputSignal));
    for i = 1:numChirps
        correlationOutputs(i,:) = conv(inputSignal, matchedFilters{i}, 'same');
    end

    max_arr = zeros(numChirps, 1);
    for i = 1:numChirps
        max_arr(i) = max(correlationOutputs(i,:));
    end
    [~, max_ind_freq] = max(max_arr);
    % analyze the correlation outputs to determine which one corresponds to the highest correlation
    [maxCorrelation_freq, ~] = max(abs(correlationOutputs), [], 1);
    max(maxCorrelation_freq);

    % frequency estimation
    freqs = freq_set{max_ind_freq};
end
