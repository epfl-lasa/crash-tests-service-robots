% This function calculates the numerical integral of a data series with a
% given freceuncy
% get1int(input,frec,intC)

function int=get1int(input,frec,intC)
    
    T = 1/frec;
    int = (intC + (T * input) );
    
end