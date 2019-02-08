function [target] = simsCheck(sims,tolerance)
% Function that checks the Sims output

if sims<=tolerance
    target = rand;
else
    target = sims;
end

end