function [ filen ] = TaskFileName( timing_file, task_folder )
%TaskFileName generates unique task file name for ML tasks
%   TaskFileName creates a simple name string, checks if it already
%   exists & if so increments the version number so that unique .txt files
%   are created & previous versions do not get overwriten
%   TaskFileName takes the ML timing_file name and uses this as the stem
%   for the .txt file name appended with the date & version number
%   TaskFileName also takes the ML task_folder. this is necessary because
%   ML expects condition & timing files to be in that same experiments
%   folder. 

%make a string of the timing file name and the date the
%textfile was generated
datev = datevec(date); %get current date
fileheader = [ timing_file '_' num2str(datev(1)) '_' num2str(datev(2)) '_' num2str(datev(3))]; %string for .txt file name
filetag = [ fileheader '(1).txt']; %initialize string version

%within task_folder, find all the files with the same (basic) name & date.
%wildcard (*) for the version number
listing = dir([ task_folder '\' fileheader '(*).txt']);

%does this file already exist?
if exist( filetag, 'file')
    %if it exists find the highest number of the different versions
    max = 1;
    for i = 1:size(listing, 1)
        if str2num(listing(i).name(end-5)) > max
            max = str2num(listing(i).name(end-5));
        end
    end
    [~, status] = str2num(filetag( end-5 ));
    if status %if there already exists a version with #max, return filen with the next increment
        num = max + 1; %increment max
        filetag = [ fileheader '(' num2str(num) ').txt' ];
        filen = [ task_folder '\' filetag ];
    elseif ~status %catch if something goes wrong here
        disp('file exists')
        disp('ERROR in file naming')
    end
elseif ~exist( filetag, 'file') %if there is no current file, return filen as the initialized version string
    filen = [ task_folder '\' filetag ];
end

end

