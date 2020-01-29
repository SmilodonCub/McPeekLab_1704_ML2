function [ bear50SIM bear50DIS ] = bearSimilarity( input_args )
%BEARSIMILARITY %bearsimilarity matrix ranks the chi^2 distance 
%of various image features between the 500 distractors & each target teddy bear
%1st column is the distractor sstring names, second is average distractor
%distances for all bear targets, 3:11 are distractor rankings for each bear
%This function returns info on the 50 most ( bear50SIM ) and the the 50
%least ( bear50DIS ) target like

%bear similarity by target
load('bearsimilarity.mat') 
for i = 1:size( bearsimilarity,1 )
    entry = bearsimilarity{ i,1 };
    entry_split = regexp(entry, '\_', 'split');
    new_name = [ char(entry_split(1)) 'Bear_' char(entry_split(2)) ];
    bearsimilarity{ i,1 } = new_name;
end
load( 'bearsimilarity_targetID' ) %bear target for each column of bearsimilarity
[ ~, I] = sort ( cell2mat( bearsimilarity( :,3:end ) ) ); %'ascending'
bear50SIM = bearsimilarity( I( end-49:end, : ), 1 ); %50 most simlar for each bear
bear50SIM = reshape( bear50SIM, [ 50, 10 ] );
bear50DIS = bearsimilarity( I( 1:50, : ), 1 ); %50 least similar for each bear
bear50DIS = reshape( bear50DIS, [ 50, 10 ] );


end

