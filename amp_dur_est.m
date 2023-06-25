% amplitude and duration estimation
function [ampl_est, duration_est] = amp_dur_est(sound, samp_rate) %#codegen

    ampl_est = max(abs(sound));
    duration_est = length(sound)/samp_rate;

end
