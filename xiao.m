function est_im = xiao(source,target,ruggedised)
%CF_XIAO computes Reinhard's image colour transfer
%
%   CF_XIAO(SOURCE,TARGET,ruggedised) returns the colour transfered source
%   image SOURCE according to the target image TARGET.
%

%   If 'ruggedised' is set 'false' then, the original 'Xiao' method is 
%   implemented as coded by Han Gong.

%   If 'ruggedised' is set 'true' then further processing is performed in 
%   addition to the basic processing. The additional processing has been
%   devised and coded by Terry Johnson.

%   References:
%   Xiao, Xuezhong, and Lizhuang Ma. "Color transfer in correlated color
%   space." % In Proceedings of the 2006 ACM international conference on
%   Virtual reality continuum and its applications, pp. 305-309. ACM, 2006.

%   TODO: Swatch-based transfer is not implemented (but I think it is not
%   important) Anyone interested is welcome to contribute. :-)
%                                                           -- Han Gong

%   Copyright 2015 Han Gong <gong@fedoraproject.org>, University of East
%   Anglia.
source = im2double(source);
target = im2double(target);

rgb_s = reshape(im2double(source),[],3)';
rgb_t = reshape(im2double(target),[],3)';

% 计算源图像和目标图像的均值
mean_s = mean(rgb_s,2);
mean_t = mean(rgb_t,2);

% 计算源图像和目标图像的协方差
cov_s = cov(rgb_s');
cov_t = cov(rgb_t');

% 使用svd算法对协方差矩阵进行分解
[U_s,A_s,~] = svd(cov_s);
[U_t,A_t,~] = svd(cov_t);

%**********************************************************
% Processing modification Terry Johnson.
if (ruggedised)
    [U_t,A_t]=MatchColumns(U_s,U_t,A_t);
end 
%**********************************************************

rgbh_s = [rgb_s;ones(1,size(rgb_s,2))];

% compute transforms
% translations
T_t = eye(4); T_t(1:3,4) = mean_t;
T_s = eye(4); T_s(1:3,4) = -mean_s;
% rotations
R_t = blkdiag(U_t,1); R_s = blkdiag(inv(U_s),1);
% scalings
% NOTE!
% I believe the author has a typo in his original paper
% The following is the original way to compute S_t, but
% the result does not seem correct
% S_t = diag([diag(A_t);1]); 
% I added a 0.5 power to correct it.
S_t = diag([diag(A_t).^(0.5);1]);
S_s = diag([diag(A_s).^(-0.5);1]);

rgbh_e = T_t*R_t*S_t*S_s*R_s*T_s*rgbh_s; % estimated RGBs
rgbh_e = bsxfun(@rdivide, rgbh_e, rgbh_e(4,:));
rgb_e = rgbh_e(1:3,:);

est_im = reshape(rgb_e',size(source));

end