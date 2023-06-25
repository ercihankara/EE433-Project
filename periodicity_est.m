% periodicity estimation using autocorrelation
function [] = periodicity_est(sound) %#codegen
    % EXPLANATION IN REPORT
    plot(xcorr(sound));
    title("autocorrelation")
end
