function test2(sourcename,refname,savename)
% sourcename='videos/test7.mp4';%Ҫ�������Ƶ
% savename='videos/test7_r1.mp4';%������ļ�·������Ƶ����
% refname="videos/t5.jfif";
fprintf('\nδ�Ľ�����\n');
ref=imread(refname);%�ο�ͼ
sourcevideo=VideoReader(sourcename);%Դ��Ƶ
frameCount=sourcevideo.NumFrames;%��ȡԴ��Ƶ֡��
%�ļ���������ɾ��
if ~exist(savename,'file')==0
    delete(savename);
end
w=VideoWriter(savename,'MPEG-4' );%д�����Ƶ
prompt=' ';
w.FrameRate=sourcevideo.FrameRate;%�������Ƶ֡����Դ��Ƶһ��
i1=im2double(read(sourcevideo,1));
processtime=0;

I1=im2double(ref);
X1 = reshape(I1, [], size(I1,3));
mX1 = repmat(mean(X1), [size(i1,1)*size(i1,2) 1]);
B = cov(X1);
open(w);
for i=1:frameCount
    %����������
    fprintf(repmat('\b',[1, length(prompt)]))
    prompt = sprintf('frame processing %02d / %02d', i, frameCount);
    fprintf(prompt);
    
    input=read(sourcevideo,i);%����Ҫ�����֡
    
%     output=colour_transfer_MKL(input,ref);

    starttime=clock;%��ʼʱ��
    I0=im2double(input);
    X0 = reshape(I0, [], size(I0,3));
    A = cov(X0);
    
    T = MKL(A, B);
    
    mX0 = repmat(mean(X0), [size(X0,1) 1]);
    
    XR = (X0-mX0)*T + mX1;


    output = reshape(XR, size(I0));
    
    endtime=clock;%����ʱ��
    processtime=processtime+etime(endtime,starttime);
    writeVideo(w, im2uint8(output));%д����Ƶ
end
close(w);
%�������ʱ��
fprintf(['\n֡��:',num2str(frameCount),'\n�ֱ���:',num2str(size(i1,1)),'*',num2str(size(i1,2)),'\n�ܹ���ʱ:',num2str(processtime)]);
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