% print all the estimations: frequency, amplitude, rate of frequency increase and bandwidth estimation
function [ampl_est, bandwidth_est, rate_freq] = compact_est(sound, freqs, duration_est) %#codegen

    % while creating the sound signal, the incoming data is amplified by a
    % constant. thus, checking the max value gives a near value to the original
    % amplitude. however, exact value cannot be reached due to the transmission
    % of the created signal from one device to another
    ampl_est = max(abs(sound));
    %disp(['amplitude estimation: ', num2str(ampl_est)]);
    
    %disp(['start frequency estimation: ', num2str(freqs(1))]);
    %disp(['end frequency estimation: ', num2str(freqs(2))]);
    
    bandwidth_est = freqs(2)-freqs(1);
    %disp(['bandwidth estimation: ', num2str(bandwidth_est)]);
    
    rate_freq = (bandwidth_est)/duration_est;
    %disp(['rate of frequency increase estimation: ', num2str(rate_freq)]);
end
