function  Merkmale = harris_detektor(Image,varargin) 
% In dieser Funktion soll der Harris-Detektor implementiert werden, der
% Merkmalspunkte aus dem Bild extrahiert

%%
% check if Image is grey scale
if ~ismatrix(Image)
    error('not a grey scale picture');
end

%% PARAMETERS
do_plot = false;
segment_length = 3;
k = 0.05;
tau = 10^8;
tile_size = 20;
min_dist = 5;
N = 5;

iter = 1;
while iter < length(varargin)
    switch varargin{iter}
        case 'do_plot'
            iter = iter + 1;
            do_plot = varargin{iter};
        case 'segment_length'
            iter = iter + 1;
            segment_length = varargin{iter};
        case 'k'
            iter = iter + 1;
            k = varargin{iter};
        case 'tau'
            iter = iter + 1;
            tau = varargin{iter};
        case 'tile_size'
            iter = iter + 1;
            tile_size = varargin{iter};
        case 'N'
            iter = iter + 1;
            N = varargin{iter};
        case 'min_dist'
            iter = iter + 1;
            min_dist = varargin{iter};
    end
    iter = iter + 1;
end

%%
% computing image gradient in x- and y-direction
[Fx, Fy] = sobel_xy(Image);
    %----ONLY DEBUG----ONLY DEBUG----ONLY DEBUG----ONLY DEBUG----ONLY DEBUG----ONLY DEBUG----
    imshow(uint8(sqrt(Fx.^2 + Fy.^2)))
    %----------------------------------------------------------------------------------------

% gaussian filter
gauss_filter = fspecial('gaussian', segment_length, 1);

% consider weights for harris matrix
Fx = conv2(Fx.^2, gauss_filter, 'same');
Fy = conv2(Fy.^2, gauss_filter, 'same');
Fxy = conv2(Fx.*Fy, gauss_filter, 'same');

% criterion for harris feature
H = Fx.^2.*Fy.^2 - Fxy.^2 - k*(Fx + Fy).^2;

% eliminate weak features by using a global threshold
H(H < tau) = 0;

% maximum number of features
Merkmale = zeros(length(find(H ~= 0)), 2);
num_features = 1;
iterator = 1;

% first entry of 'tile_size': width of tile
% second entry of 'tile_size': height of tile
if (length(tile_size) == 1)
    tile_size = [tile_size, tile_size];
end

for tile_start_height = 1 : tile_size(2) : size(Image, 1)
    for tile_start_width = 1: tile_size(1) : size(Image, 2)
        % check each tile
        % only check part of tile that does not exceed picture ( -> tile_start_XXX : min(...) )
        for height = tile_start_height : min(tile_start_height+tile_size(2), size(Image,1))
            for width = tile_start_width : min(tile_start_width+tile_size(1)-1, size(Image,2))
                % only consider pixels which might be a feature
                if H(height,width) ~= 0
                    % go through each row and column to check neighbors in
                    % minimal distance
                    % make sure not to violate image dimension, i.e. 1 <= row <= size(Image,1)
                    for row = max(1, tile_start_height - min_dist) : min(tile_start_height+min_dist, size(Image,1))
                        if H(height, width) == 0
                            break
                        end
                        for col = max(1, tile_start_width - min_dist) : min(tile_start_width+min_dist, size(Image,2))
                            if (row == height && col == width) || H(row,col) == 0
                                continue
                            elseif H(row,col) <= H(height, width)
                                % H(row, col) not as strong of a feature as
                                % H(width, height) => discard
                                H(row, col) = 0;
                                break;
                            else
                                % H(width, height) not as strong of a feature as
                                % H(row, col) => discard 
                                H(height, width) = 0;
                            end
                        end
                    end       
                end
            end
        end
        % find x and y coordinates of determined features
        [row, col, val] = find(H(tile_start_height : min(tile_start_height+tile_size(2), size(Image,1)),tile_start_width : min(tile_start_width+tile_size(1)-1, size(Image,2))));
        data = [row, col, val];
        % sort data in descending order
        data = sortrows(data, -3);
        data(:,1) = tile_start_height+data(:,1)-1;
        data(:,2) = tile_start_width+data(:,2)-1;
        
        if ( size(data,1) > 0)
            data = data( min(N, size(data,1)), :);
        
            Merkmale(num_features:num_features+min(N, size(data,1))-1,:) = data(:,1:2);
            num_features = num_features+min(N, size(data,1));
        end
        
    end
end

% erase dispensable entries
Merkmale(Merkmale == 0) = [];

if do_plot
    figure, imagesc(Image), colormap(gray), hold on
    plot(Merkmale(:,1),Merkmale(:,2),'rs');
end

end