%本项目参考了Pitie的pdf转换和LMK算法，以及github上的源代码https://github.com/frcs/colour-transfer
%参考了Reinhard在lab色彩空间上实行的算法，以及github上的源代码：https://github.com/hangong/reinhard_color_transfer
%以及XiaoXue中的算法https://github.com/hangong/Xiao06_color_transfer

%参考文献包括
%{
N-Dimensional Probability Density Function Transfer and its
Application to Colour Transfer. F. Pitie , A. Kokaram and R. Dahyot
(2005) In International Conference on Computer Vision (ICCV'05).

Automated colour grading using colour distribution transfer.
F. Pitie , A. Kokaram and R. Dahyot (2007) Computer Vision and Image
Understanding.

The linear Monge-Kantorovitch linear colour mapping forexample-based colour transfer.
F. Pitié and A. Kokaram (2007) In 4th
IEE European Conference on Visual Media Production (CVMP'07).

Erik Reinhard, Michael Ashikhmin, Bruce Gooch and Peter Shirley,
'Color Transfer between Images',
IEEE CG&A special issue on Applied Perception,
Vol 21, No 5, pp 34-41, September - October 2001

Xiao, Xuezhong, and Lizhuang Ma. "Color transfer in correlated color space."
In Proceedings of the 2006 ACM international conference on Virtual reality continuum and its applications, pp. 305-309. ACM, 2006.
%}

%要处理的图片
imgcount=3;
sourcename = strings(1,imgcount);
targetname = strings(1,imgcount);
sum_LMK=0;
sum_IDT=0;
sum_Reinhard=0;
sum_Xiao=0;
sum_Xiao_ruggedised=0;
sum_regrain=0;
start_LMK=clock;
start_IDT=clock;
start_regrain=clock;
start_Reinhard=clock;
start_Xiao=clock;
start_Xiao_ruggedised=clock;
end_LMK=clock;
end_IDT=clock;
end_regrain=clock;
end_Reinhard=clock;
end_Xiao=clock;
end_Xiao_ruggedised=clock;
for i=1:imgcount
    sourcename(i)=("view/"+num2str(i)+".jpg");
    targetname(i)=("view/"+num2str(i)+".jpg");
end
%{
sourcename = ["images/night.jpg","images/night1.jpg","images/bluesky.jpg"];
targetname = ["images/night.jpg","images/night1.jpg","images/bluesky.jpg"];
%}
%批量处理，要求所有的图像大小都要相同，否则会在结果图像的拼接时发生维度不同的错误
for i=1:length(sourcename)
    I0 = imread(sourcename(i));
    for j=1:length(targetname)
        fprintf('------------------正在进行第%d张源图像和第%d张参考图像的处理----------------------\n',i,j);
        I1 = imread(targetname(j));
        start_LMK=clock;
        fprintf('  ... MKL Colour Transfer \n');
        IR_mkl = colour_transfer_MKL(I0,I1);
        end_LMK=clock;
        sum_LMK=sum_LMK+etime(end_LMK,start_LMK);
        
        fprintf('  ... seed the random number generator\n');
        rng(0);
        
        start_IDT=clock;
        fprintf('  ... IDT Colour Transfer (slow implementation) \n');
        IR_idt = colour_transfer_IDT(I0,I1,10);
        
        end_IDT=clock;
        sum_IDT=sum_IDT+etime(end_IDT,start_IDT);
        
        start_regrain=clock;
        fprintf('  ... regrain post-processing on IDT results \n');
        IR_idt_regrain = regrain(I0,IR_idt);
        end_regrain=clock;
        sum_regrain=sum_regrain+etime(end_regrain,start_regrain);
        
        start_Reinhard=clock;
        fprintf('  ... Reinhard Colour Transfer\n');
        IR_reinhard = reinhard(I0,I1);
        end_Reinhard=clock;
        sum_Reinhard=sum_Reinhard+etime(end_Reinhard,start_Reinhard);
        
        
        start_Xiao=clock;
        fprintf('  ...  Xiao Colour Transfer\n');
        IR_xiao = xiao(I0,I1,false);
        end_Xiao=clock;
        sum_Xiao=sum_Xiao+etime(end_Xiao,start_Xiao);
        
        start_Xiao_ruggedised=clock;
        fprintf('  ...  Xiao_ruggedised Colour Transfer\n');
        IR_xiao_ruggedised = xiao(I0,I1,true);
        end_Xiao_ruggedised=clock;
        sum_Xiao_ruggedised=sum_Xiao_ruggedised+etime(end_Xiao_ruggedised,start_Xiao_ruggedised);
        
        fprintf('  [ok] \n');
        %output
        temp=ones(size(I0(:,:,:)));
        res=[im2double(I0),im2double(I1),temp;IR_mkl,IR_idt,IR_idt_regrain;IR_reinhard,IR_xiao,IR_xiao_ruggedised];
        imwrite(res,['results/',num2str(i),'_',num2str(j),'_result.png']);
    end
end

fprintf('LMK方法总共耗时%f \n',sum_LMK);
fprintf('IDT方法总共耗时%f \n',sum_IDT);
fprintf('IDT改进总共耗时%f \n',sum_regrain);
fprintf('Reinhard方法总共耗时%f \n',sum_Reinhard);
fprintf('Xiao方法总共耗时%f \n',sum_Xiao);
fprintf('Xiao_ruggedised方法总共耗时%f \n',sum_Xiao_ruggedised);
