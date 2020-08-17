% 视频色彩迁移
refname="videos/t12.jpg";
sourcename='videos/test6.mp4';%要处理的视频
savename1='videos/test6_r1.mp4';%保存的文件路径及视频名称1
savename2='videos/test6_r2.mp4';%保存的文件路径及视频名称2
video_ct_improve(sourcename,refname,savename1);%改进的方法
video_ct(sourcename,refname,savename2);%未改进的方法

%图像色彩迁移
sourcename='pictures/source.jpg';
refname='pictures/ref.jpg';
I0 = imread(sourcename);
I1 = imread(refname);
%reinhard
reinhard_res=reinhard(I0,I1);
imwrite(reinhard_res,'pictures/reinhard_res.jpg');
%xiao
xiao_res=xiao(I0,I1,true);
imwrite(xiao_res,'pictures/xiao_res.jpg');
%MKL
mkl_res=colour_transfer_MKL(I0,I1);
imwrite(mkl_res,'pictures/mkl_res.jpg');
%IDT
idt=colour_transfer_IDT(I0,I1,10);
idt_res=regrain(I0,idt);
imwrite(idt_res,'pictures/idt_res.jpg');

res=[im2uint8(reinhard_res),im2uint8(xiao_res);im2uint8(mkl_res),im2uint8(idt_res)];
imshow(res)