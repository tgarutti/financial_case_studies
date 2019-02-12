function [target] = simsCheck(sims,tolerance)
% Function that checks the Sims output

if sims<=tolerance
    target = (0.1+rand)/5;
else
    target = sims;
end

end