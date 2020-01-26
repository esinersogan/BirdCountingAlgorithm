%% Author
% Esin ERSOĞAN
% 708191001
% BLG 531E - Image Processing 
% HW2 - Bird Counting Algorithm
% 01.12.2019

%% Read Image
im = imread('bird 3.bmp');

im = rgb2gray(im);
im = double(im);

%% Padding for 5*5 Gaussian Filter
im(1,:) = 0; 
im(2,:) = 0; 
im(size(im,1),:) = 0;
im(size(im,1)-1,:) = 0;
im(:,1) = 0;
im(:,2) = 0;
im(:,size(im,2)) = 0;
im(:,size(im,2)-1) = 0;

%% Gaussian Filter
sigma = 1.4;
dim = 2;
[x,y]=meshgrid(-dim:dim,-dim:dim);
ex = -(x.^2+y.^2)/(2*sigma*sigma);
kernel= exp(ex)/(2*pi*sigma*sigma);

grad=zeros(size(im));

for i=3:size(im,1)-2
    for j=3:size(im,2)-2
        sum = 0;
        for k=1:5
            for l=1:5
                sum = sum + kernel(k,l)*im(i-3+k,j-3+l);
            end
        end
        grad(i,j)=sum;
    end
end

grad = uint8(grad);

%% Thresholding to produce a binary image
for i=1:size(grad, 1)
    for j=1:size(grad, 2)
        if grad(i,j) > 75 
            grad(i,j)=0; %To convert the background to zeros
        else
            grad(i,j)=255; %To convert the foreground to ones
        end
    end
end

%% Convert image to binary
M=im2bw(grad);

%% Connected Component Labelling

eqList = containers.Map('KeyType','double','ValueType','double');

C = zeros(size(M,1),size(M,2));
k=0;
for i=2:size(M,1)
    for j=2:size(M,2)-1
        if M(i,j)==0
            C(i,j)=0;
        else
            if C(i,j-1)~=0
                C(i,j)=C(i,j-1);
            end
            
            if C(i-1,j-1)~=0
                C(i,j)=C(i-1,j-1);
                if C(i,j-1)~=0
                    if C(i,j-1)~=C(i-1,j-1)
                        C(i,j)=min(C(i,j-1), C(i-1,j-1));
                        eqList(max(C(i,j-1), C(i-1,j-1)))=min(C(i,j-1), C(i-1,j-1)); 
                        % sign the max one as min 
                    end
                end
            end
            
            if C(i-1,j)~=0
                C(i,j)=C(i-1,j);
                if C(i,j-1)~=0
                    if C(i,j-1)~=C(i-1,j)
                        C(i,j)=min(C(i,j-1), C(i-1,j));
                        eqList(max(C(i,j-1), C(i-1,j)))=min(C(i,j-1), C(i-1,j)); 
                        % sign the max one as min 
                    end
                end
                if C(i-1,j-1)~=0
                    if C(i-1,j-1)~=C(i-1,j)
                        C(i,j)=min(C(i-1,j-1), C(i-1,j));
                        eqList(max(C(i-1,j-1), C(i-1,j)))=min(C(i-1,j-1), C(i-1,j)); 
                        % sign the max one as min 
                    end
                end
            end
            
            if C(i-1,j+1)~=0
                C(i,j)=C(i-1,j+1);
                 if C(i,j-1)~=0
                    if C(i,j-1)~=C(i-1,j+1)
                        C(i,j)=min(C(i,j-1), C(i-1,j+1));
                        eqList(max(C(i,j-1), C(i-1,j+1)))=min(C(i,j-1), C(i-1,j+1)); 
                        % sign the max one as min 
                    end
                end
                if C(i-1,j-1)~=0
                    if C(i-1,j-1)~=C(i-1,j+1)
                        C(i,j)=min(C(i-1,j-1), C(i-1,j+1));
                        eqList(max(C(i-1,j-1), C(i-1,j+1)))=min(C(i-1,j-1), C(i-1,j+1)); 
                        % sign the max one as min 
                    end
                end
                if C(i-1,j)~=0
                    if C(i-1,j)~=C(i-1,j+1)
                        C(i,j)=min(C(i-1,j), C(i-1,j+1));
                        eqList(max(C(i-1,j), C(i-1,j+1)))=min(C(i-1,j), C(i-1,j+1)); 
                        % sign the max one as min 
                    end
                end
            end
            if C(i,j)==0
                k=k+1;
                eqList(k)=k;
                C(i,j)=k;
            end
        end
    end
end

%% Resolve conflicts, traverse from the end of the list
for t=0:eqList.Count-1
    for i=1:size(M,1)
        for j=1:size(M,2)
            if C(i,j)==eqList.Count-t
                C(i,j)=eqList(C(i,j));
            end
        end
    end
end

%figure, imshow(C);
%% Convert the Labeled Image to RGB
rgb = label2rgb(C);

figure, imshow(rgb);