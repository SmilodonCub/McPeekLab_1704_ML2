dashboard(1,'');

if 0==mod(TrialRecord.CurrentCondition,2)
    left = 4; right = 3;
else
    left = 3; right = 4;
end

toggleobject([left right]);
chosen_target = eyejoytrack('touchtarget',[left right],3,5000);
if ~chosen_target
    toggleobject([left right]);
    trialerror(6);
    return
end

if 1==chosen_target
    dashboard(1,'LEFT');
else
    dashboard(1,'RIGHT');
end

idle(1000);
