    function y = sixtyHzFilt_EEG(x, fs)
%DOFILTER Filters input x and returns output y.

% MATLAB Code
% Generated by MATLAB(R) 9.3 and DSP System Toolbox 9.5.
% Generated on: 02-Oct-2017 12:52:18

persistent Hd;

if isempty(Hd)
    
    Fpass1 = 57;    % First Passband Frequency
    Fstop1 = 59.9;  % First Stopband Frequency
    Fstop2 = 60.1;  % Second Stopband Frequency
    Fpass2 = 63;    % Second Passband Frequency
    Apass1 = 3;     % First Passband Ripple (dB)
    Astop  = 25;    % Stopband Attenuation (dB)
    Apass2 = 3;     % Second Passband Ripple (dB)
    Fs     = fs;    % Sampling Frequency
    
    h = fdesign.bandstop('fp1,fst1,fst2,fp2,ap1,ast,ap2', Fpass1, Fstop1, ...
        Fstop2, Fpass2, Apass1, Astop, Apass2, Fs);
    
    Hd = design(h, 'cheby2', ...
        'MatchExactly', 'stopband', ...
        'SOSScaleNorm', 'Linf');
    
    
    
    set(Hd,'PersistentMemory',true);
    
end

y = filter(Hd,x);

