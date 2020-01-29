image_folder = 'C:\Users\Public\Documents\Novel_catSearchPHYSIOL_renamed';
images = dir([image_folder,	'\*.bmp']);
Num = numel(images);
max_width = zeros(1, Num);
max_height = zeros(1, Num);

for i = 1:Num
	filename = images(i).name;
	image = imread(filename);
	[height, width, dim] = size(image);
	max_width(i) = width;
	max_height(i) = height;
end
	
final_width = max(max_width);
final_height = max(max_height);
final_dim = max( [ final_width final_height ] );

for j = 1:Num
	filename2 = images(j).name;
    image2 = imread(filename2);
	[height, width, dim] = size(image2);
	Height_add = final_dim - height;
	Width_add = final_dim - width;
	image_pad = padarray(image2, [Height_add, Width_add], 255, 'post');
	image_shift = circshift(image_pad, [floor(Height_add/2) floor(Width_add/2)]);
	%image_shift = circshift(image_shift, floor(Width_add/2), 2);
    imwrite(image_shift, ['C:\Users\Public\Documents\Novel_catSearchPHYSIOL_padded\' filename2]);
end
