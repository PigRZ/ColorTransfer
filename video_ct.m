function test2(sourcename,refname,savename)
% sourcename='videos/test7.mp4';%要处理的视频
% savename='videos/test7_r1.mp4';%保存的文件路径及视频名称
% refname="videos/t5.jfif";
fprintf('\n未改进方法\n');
ref=imread(refname);%参考图
sourcevideo=VideoReader(sourcename);%源视频
frameCount=sourcevideo.NumFrames;%读取源视频帧数
%文件若存在则删除
if ~exist(savename,'file')==0
    delete(savename);
end
w=VideoWriter(savename,'MPEG-4' );%写入的视频
prompt=' ';
w.FrameRate=sourcevideo.FrameRate;%处理后视频帧率与源视频一致
i1=im2double(read(sourcevideo,1));
processtime=0;

I1=im2double(ref);
X1 = reshape(I1, [], size(I1,3));
mX1 = repmat(mean(X1), [size(i1,1)*size(i1,2) 1]);
B = cov(X1);
open(w);
for i=1:frameCount
    %输出处理进度
    fprintf(repmat('\b',[1, length(prompt)]))
    prompt = sprintf('frame processing %02d / %02d', i, frameCount);
    fprintf(prompt);
    
    input=read(sourcevideo,i);%读入要处理的帧
    
%     output=colour_transfer_MKL(input,ref);

    starttime=clock;%开始时间
    I0=im2double(input);
    X0 = reshape(I0, [], size(I0,3));
    A = cov(X0);
    
    T = MKL(A, B);
    
    mX0 = repmat(mean(X0), [size(X0,1) 1]);
    
    XR = (X0-mX0)*T + mX1;


    output = reshape(XR, size(I0));
    
    endtime=clock;%结束时间
    processtime=processtime+etime(endtime,starttime);
    writeVideo(w, im2uint8(output));%写入视频
end
close(w);
%输出处理时间
fprintf(['\n帧数:',num2str(frameCount),'\n分辨率:',num2str(size(i1,1)),'*',num2str(size(i1,2)),'\n总共用时:',num2str(processtime)]);
fprintf('\n end \n');
end

function [T] = MKL(A, B)
[Ua,Da2] = eig(A); 
Da2 = diag(Da2); 
Da2(Da2<0) = 0;
Da = diag(sqrt(Da2 + eps));
C = Da*Ua'*B*Ua*Da;
[Uc,Dc2] = eig(C); 
Dc2 = diag(Dc2);
Dc2(Dc2<0) = 0;
Dc = diag(sqrt(Dc2 + eps));
Da_inv = diag(1./(diag(Da)));
T = Ua*Da_inv*Uc*Dc*Uc'*Da_inv*Ua';
end