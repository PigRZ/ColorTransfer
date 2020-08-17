function est_im = reinhard(sourcename,targetname)
%CF_REINHARD computes Reinhard's image colour transfer

%   Copyright 2015 Han Gong <gong@fedoraproject.org>, University of East
%   Anglia.

% 参考论文:
% Erik Reinhard, Michael Ashikhmin, Bruce Gooch and Peter Shirley, 
% 'Color Transfer between Images', IEEE CG&A special issue on Appliedi
% Perception, Vol 21, No 5, pp 34-41, September - October 2001
source = im2double(sourcename);
target = im2double(targetname);

[x,y,z] = size(source);
img_s = reshape(im2double(source),[],3);
img_t = reshape(im2double(target),[],3);

a = [0.3811 0.5783 0.0402;0.1967 0.7244 0.0782;0.0241 0.1288 0.8444];
b = [1/sqrt(3) 0 0;0 1/sqrt(6) 0;0 0 1/sqrt(2)];
c = [1 1 1;1 1 -2;1 -1 0];
b2 = [sqrt(3)/3 0 0;0 sqrt(6)/6 0;0 0 sqrt(2)/2];
c2 = [1 1 1;1 1 -1;1 -2 0];

img_s = max(img_s,1/255);
img_t = max(img_t,1/255);

% RBG变换为LMS色彩空间
LMS_s = a*img_s';
LMS_t = a*img_t';

% LMS色彩空间取对数log
LMS_s = log10(LMS_s);
LMS_t = log10(LMS_t);

% LMS转换为Lab色彩空间
lab_s = b*c*LMS_s;
lab_t = b*c*LMS_t;

% 计算Lab色彩空间中的均值和标准差
mean_s = mean(lab_s,2);
std_s = std(lab_s,0,2);
mean_t = mean(lab_t,2);
std_t = std(lab_t,0,2);

res_lab = zeros(3,x*y);

sf = std_t./std_s;

%三个通道上分别进行变换
for ch = 1:3
    res_lab(ch,:) = (lab_s(ch,:) - mean_s(ch))*sf(ch) + mean_t(ch);
end

% 转换为LMS色彩空间
LMS_res=c2*b2*res_lab;
for ch = 1:3
    LMS_res(ch,:) = 10.^LMS_res(ch,:);
end

% 转换为RGB色彩空间
est_im = ([4.4679 -3.5873 0.1193;-1.2186 2.3809 -0.1624;0.0497 -0.2439 1.2045]*LMS_res)';
%图像矩阵由[3,m*n]转换为[m,n,3]三维矩阵RBG图像
est_im = reshape(est_im,size(source));