% ***************************************************************************************************************************************
%       ***HAPCG�㷨***
%        ���ø�ʽ��[1]Ҧ����,������,��һ,������,������.�˼��������Լ�Ȩ�����������λ�������ԴӰ��ƥ��[J/OL].�人��ѧѧ��(��Ϣ��ѧ��):
%                        1-13[2021-04-02].https://doi.org/10.13203/j.whugis20200702.
%        This is a simplified Code demo of the HAPCG algorithm.
%        Download website address of code and Images dataset:    https://skyearth.org/research
%        Public: Created by Yongxiang Yao in 2021/03/29.
%  ***************************************************************************************************************************************

% clear all;
close all;
warning('off');
%% 1 Import and display reference and image to be registered
file_image= '.\Images';
[filename,pathname]=uigetfile({'*.*','All Files(*.*)'},'Select Image',file_image);image_1=imread(strcat(pathname,filename));
[filename,pathname]=uigetfile({'*.*','All Files(*.*)'},'Select Image',file_image);image_2=imread(strcat(pathname,filename));

%% 2  Setting of initial parameters 
% Key parameters:
K_weight=3;                        % ������������ͼ�ļ�Ȩֵ�����ڣ�1~10����Ĭ�����ã�3
Max=3;                               % Number of levels in scale space��Ĭ�����ã�3
threshold = 0.4;                  % ��������ȡ��ֵ����SARӰ��/ǿ��ͼ��ɫʱ������Ϊ��0.3��һ��Ĭ������Ϊ��0.4
scale_value=2;                  % �߶����ű���ֵ��Ĭ�����ã�1.6
Path_Block=42;                   % ���������򴰿ڴ�С�� Ĭ�����ã�42������Ҫ����������ʱ�����Ե��󴰿ڡ�

%% 3 �������Գ߶ȿռ�
t1=clock;
disp('Start HAPCG algorithm processing, please waiting...');
tic;
[nonelinear_space_1]=HAPCG_nonelinear_space(image_1,Max,scale_value);
[nonelinear_space_2]=HAPCG_nonelinear_space(image_2,Max,scale_value);
disp(['����������Գ߶ȿռ仨��ʱ�䣺',num2str(toc),'��']);

%% 4  ������Ȩ������������ͼ����λһ�����ݶȼ����� 
tic;
[harris_function_1,gradient_1,angle_1]=HAPCG_Gradient_Feature(nonelinear_space_1,Max,K_weight);
[harris_function_2,gradient_2,angle_2]=HAPCG_Gradient_Feature(nonelinear_space_2,Max,K_weight);
disp(['����������λһ�����ݶ�ͼ:',num2str(toc),'S']);

%% 5  feature point extraction
tic;
position_1=Harris_extreme(harris_function_1,gradient_1,angle_1,Max,threshold);
position_2=Harris_extreme(harris_function_2,gradient_2,angle_2,Max,threshold);
disp(['��������ȡ����ʱ��:  ',num2str(toc),' S']);

%% 6 Lop-Polar Descriptor Constrained by HAPCG
tic;
descriptors_1=HAPCG_Logpolar_descriptors(gradient_1,angle_1,position_1,Path_Block);                                     
descriptors_2=HAPCG_Logpolar_descriptors(gradient_2,angle_2,position_2,Path_Block); 
disp(['HAPCG���������ӻ���ʱ��:  ',num2str(toc),'S']); 

%% 7 Nearest matching    
disp('Nearest matching')
[indexPairs,~] = matchFeatures(descriptors_1.des,descriptors_2.des,'MaxRatio',1,'MatchThreshold', 10);
matchedPoints_1 = descriptors_1.locs(indexPairs(:, 1), :);
matchedPoints_2 = descriptors_2.locs(indexPairs(:, 2), :);
%% Outlier removal  
disp('Outlier removal')
[H,rmse]=FSC(matchedPoints_1,matchedPoints_2,'affine',3);
Y_=H*[matchedPoints_1(:,[1,2])';ones(1,size(matchedPoints_1,1))];
Y_(1,:)=Y_(1,:)./Y_(3,:);
Y_(2,:)=Y_(2,:)./Y_(3,:);
E=sqrt(sum((Y_(1:2,:)-matchedPoints_2(:,[1,2])').^2));
inliersIndex=E < 3;
clearedPoints1 = matchedPoints_1(inliersIndex, :);
clearedPoints2 = matchedPoints_2(inliersIndex, :);
uni1=[clearedPoints1(:,[1,2]),clearedPoints2(:,[1,2])];
[~,i,~]=unique(uni1,'rows','first');
inliersPoints1=clearedPoints1(sort(i)',:);
inliersPoints2=clearedPoints2(sort(i)',:);
[inliersPoints_1,inliersPoints_2] = BackProjection(inliersPoints1,inliersPoints2,scale_value);  % ---ͶӰ��ԭʼ�߶�
disp('keypoints numbers of outlier removal: '); disp(size(inliersPoints_1,1));
disp(['RMSE of Matching results: ',num2str(rmse),'  ����']);
figure; showMatchedFeatures(image_1, image_2, inliersPoints_1, inliersPoints_2, 'montage');
t2=clock;
disp(['HAPCG�㷨ƥ���ܹ�����ʱ��  :',num2str(etime(t2,t1)),' S']);     
