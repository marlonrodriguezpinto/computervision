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
k = 0.04;
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

% gaussian filter used for weights in harris matrix 
gauss_filter = 2*fspecial('gaussian', segment_length, 1);

% consider weights for harris matrix
Fxy = conv2(Fx.*Fy, gauss_filter, 'same');
Fx = conv2(Fx.^2, gauss_filter, 'same');
Fy = conv2(Fy.^2, gauss_filter, 'same');

% criterion for harris feature ( det() - k*tr()^2 )
H = Fx.*Fy - Fxy.^2 - k*(Fx + Fy).^2;

% eliminate weak features by using a global threshold
H(H < tau) = 0;

% pre-define matrix for maximum number of features
Merkmale = zeros(length(find(H ~= 0)), 2);
num_features = 1;

% first entry of 'tile_size': width of tile
% second entry of 'tile_size': height of tile
if (length(tile_size) == 1)
    tile_size = [tile_size, tile_size];
end

% move tile from upper left corner to lower right corner over the image
% tile is moved first column then row wise
for tile_start_col = 1: tile_size(1) : size(Image, 2)
    for tile_start_row = 1 : tile_size(2) : size(Image, 1)
        % check each tile
        % only check part of tile that does not exceed picture ( -> tile_start_XXX : min(...) )
        for tile_col = tile_start_col : min(tile_start_col+tile_size(1)-1, size(Image,2))
            for tile_row = tile_start_row : min(tile_start_row+tile_size(2)-1, size(Image,1))
                % only consider pixels which might be a feature
                if ( H(tile_row,tile_col) ~= 0 )
                    % go through each row and column to check neighbors in
                    % minimal distance
                    % make sure not to violate image dimension, tile_start_row.e. 1 <= row <= size(Image,1)
                    for col = max(1, tile_col - min_dist) : min(tile_col+min_dist, size(Image,2))
                        if H(tile_row, tile_col) == 0
                            break
                        end
                        for row = max(1, tile_row - min_dist) : min(tile_row+min_dist, size(Image,1))
                            if (row == tile_row && col == tile_col) || H(row,col) == 0
                                continue
                            elseif H(row,col) <= H(tile_row, tile_col)
                                % H(row, col) not as strong of a feature as
                                % H(tile_row, tile_col) => discard
                                H(row, col) = 0;
                            else
                                % H(tile_row, tile_col) not as strong of a feature as
                                % H(row, col) => discard 
                                H(tile_row, tile_col) = 0;
                                break;
                            end
                        end
                    end
                end
            end
        end

         % find x and y coordinates of determined/found features in tile
         [y, x, val] = find(H(tile_start_row : min(tile_start_row+tile_size(2)-1, size(Image,1)),tile_start_col : min(tile_start_col+tile_size(1)-1, size(Image,2))));
         data = [x, y, val];
         % sort data in descending order
         data = sortrows(data, -3);
         % find position of pixels, i.e. x and y coordinates, in the entire Image
         data(:,1) = tile_start_col+data(:,1)-1;
         data(:,2) = tile_start_row+data(:,2)-1;
         
        if ( ~isempty(data) )
            % select max. top N pixel, i.e. most distincitive features
            data = data( 1:min(N, size(data,1)), :);
            % save features
            Merkmale(num_features:num_features+min(N, size(data,1))-1,:) = data(:,1:2);
            num_features = num_features+min(N, size(data,1));
        end
        
    end
end

% erase dispensable entries
Merkmale(Merkmale == 0) = [];
% shape Merkmale back in matrix form
Merkmale = reshape(Merkmale, [], 2);

% plot Image with features if flag do_plot is set
if do_plot
    figure
    imagesc(Image)
    colormap(gray)
    hold on
    plot(Merkmale(:,1),Merkmale(:,2),'rs');
end

end