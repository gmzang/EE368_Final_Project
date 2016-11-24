addpath('DomainTransformFilters-Source-v1.0/');

% import images
house=im2double(imread('images/house - small.jpg'));
imsize=400;
house=house(1:imsize,1:imsize,:);
night=im2double(imread('images/starry-night - small.jpg'));
night=night(1:imsize,1:imsize,:);

% Input

% Initialize variables
R = zeros(size(house));
R(200:220,300:320,:) = 1;
R = R(:);
X = house(:);
S = night(:);
Q_size = 21;
sigma_s = 60;
sigma_r = 0.4;
h=imsize; w=imsize; c=3;

% Loop over scales L=Lmax, ... ,1
for L=1
    % Loop over patch sizes n=n1, ... ,nm
    for n=(21).^2 %n=Q_size^2
        % Iterate: for k=1, ... ,Ialg
        for k=1
            
            % 1. Patch Matching
            z = [];
            gap=18; %should correspond to current n
            for i=1:gap:h
                i
                for j=1:gap:w
                    R = zeros(size(house));
                    R(i:i+Q_size-1,j:j+Q_size-1,:) = 1;
                    R = R(:);
                    [~, ~, zij] = nearest_n(R, X, Q_size, S, h, w, c);
                    z = [z zij];
                end
            end
            
            % 2. Robust Aggregation
            disp('robust aggregation')
            [Xtilde]=irls(R,X,z);

            disp('content fusion')
            % 3. Content Fusion
            Nc=(imsize/L)^2;
            W=ones(3*Nc,1);
            Xhat=(diag(W)+eye(3*Nc))\(Xtilde+W.*C); % W is (3*Nc/L x 1)

            disp('color transfer')
            % 4. Color Transfer
            X=imhistmatch(reshape(Xhat,h,w,c),reshape(S,h,w,c));
            X=X(:);

            disp('denoise')
            % 5. Denoise
            X = RF(X, sigma_s, sigma_r);
            
        end % end Iterate: for k=1, ... ,Ialg
        
    end % end patch size loop
    % Scale up
    X=imresize(X,(L+1)/L);
end % end resolution/scale loop  

% Result
X=reshape(X,imsize,imsize,3);








