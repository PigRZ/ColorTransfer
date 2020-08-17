function video_ct_improve(sourcename,refname,savename)
fprintf('\n�Ľ�����\n');
ref=imread(refname);%�ο�ͼ
ref=im2double(ref);
sourcevideo=VideoReader(sourcename);%Դ��Ƶ
frameCount=sourcevideo.NumFrames;%��ȡԴ��Ƶ֡��
%�ļ���������ɾ��
if ~exist(savename,'file')==0
    delete(savename);
end
w=VideoWriter(savename,'MPEG-4' );%д�����Ƶ
prompt=' ';
w.FrameRate=sourcevideo.FrameRate;%�������Ƶ֡����Դ��Ƶһ��
X1 = reshape(ref, [], size(ref,3));
B = cov(X1);
i1=im2double(read(sourcevideo,1));
mX1 = repmat(mean(X1), [size(i1,1)*size(i1,2) 1]);
lastcov=zeros(3,3);
lastmean=zeros(1,3);
processtime=0;
count=0;
open(w);
for i=1:frameCount
    %����������
    fprintf(repmat('\b',[1, length(prompt)]))
    prompt = sprintf('frame processing %02d / %02d', i, frameCount);
    fprintf(prompt);
    
    input=read(sourcevideo,i);%����Ҫ�����֡
    
    starttime=clock;%��ʼʱ��
    input=im2double(input);
    X0 = reshape(input, [], size(input,3));
    A = cov(X0);
    m=mean(X0);
    
    csub=mean(mean(A-lastcov));
    msub=mean(m-lastmean);
    lastcov=A;
    lastmean=m;
    if((i==1||abs(csub)>0.01||abs(msub)>0.01)&&count<100)
        count=count+1;
        if(count>=100)
            count=0;
        end
        T=MKL(A,B);
        mX0 = repmat(m, [size(X0,1) 1]);
    end
    
    XR = (X0-mX0)*T + mX1;
    output = reshape(XR, size(input));
    
    endtime=clock;%����ʱ��
    processtime=etime(endtime,starttime)+processtime;
    
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