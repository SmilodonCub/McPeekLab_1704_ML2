image_folder = 'C:\Users\Public\Documents\Butt_Dist_600_npb_not_padded';
images = dir([image_folder,	'\*.bmp']);
Num = numel(images);
tag = 'DBFly_';

for j = 1:Num
	filename = images(j).name;
    image2 = imread(filename);
    image3 = im2uint8(image2);
    filename2 = [tag filename(1:(end-4)) '.bmp'];
    imwrite(image3, ['C:\Users\Public\Documents\Novel_catSearchPHYSIOL_renamed\' filename2]);
end
