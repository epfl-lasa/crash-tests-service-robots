%% This function calculates the discrete differentiation of a vector consideirng its time
%  frequency
% fact -->  Sampling (every 2,3,...n datapoints)
% freq --> Frequency of the data
% dXm = getdiff(Xm,2,1000)

function diff = get1diff(Inp,frec)

    
    diff = ((Inp(2) - Inp(1)) / 2) *frec;

end