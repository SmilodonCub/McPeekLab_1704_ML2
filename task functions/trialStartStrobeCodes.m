function [ ] = trialStartStrobeCodes( trialcodenum )
%trialStartStrobeCodes This function generates a generic & a series of
%unique values to be used as stobed event markers to label the first trial
%of each MonkeyLogic task with timestamps in both behavioral .bhv files,
%Plexon, & NeuroExplorer files. the generic eventmarker '5555' is strobed.
%followed by, a series of 4 values derived from the 'datestr' fxn: yyyy,
%mmdd, hhmm, mmss == year, month/date, hour/minutes, & minutes/seconds

% Send Start Experiment Stobes
%get the eventmarkers that were sent in the previous trial
if isempty( trialcodenum ); %if there weren't any eventmarkers this must be the 1st trial
    disp( 'start experiment' )
    %eventmarker( 5555 );
    formatOut = 31; 
    DateStr = datestr(now,formatOut);
    disp( DateStr )
    bhv_variable('DateStr',DateStr);
    DateStrSplit = regexp(DateStr, '[- :]', 'split');
    yyyyStrobe = str2num( DateStrSplit{1} );
    mmddStrobe = str2num( [ DateStrSplit{2} DateStrSplit{3} ] );
    hhmmStrobe = str2num( [ DateStrSplit{4} DateStrSplit{5} ] );
    mmssStrobe = str2num( [ DateStrSplit{5} DateStrSplit{6} ] );
    eventmarker( [ yyyyStrobe mmddStrobe hhmmStrobe mmssStrobe ] );
elseif ~isempty( trialcodenum );
    happyStr = '??(???)???(???)???(???)??';
    disp( happyStr );
end

end

