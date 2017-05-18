function [Fx,Fy, Image] = sobel_xy(Image)
% In dieser Funktion soll das Sobel-Filter implementiert werden, welches
% ein Graustufenbild einliest und den Bildgradienten in x- sowie in
% y-Richtung zurückgibt.

% dims image 2000x3000
if size(Image,3) ~= 1
    error('no gray image')
end

% do we take this appraoch ?
Image = double( [   Image(1,1),     Image(1,:),     Image(1,end);
                    Image(:,1),     Image,          Image(:,end);
                    Image(end,1),   Image(end,:),   Image(end,end)
                ]);

% vert sobel
k = [1 2 1; 0 0 0; -1 -2 -1];

% take valid flag cause output is only Fx,Fy and not a matrix
% valid doesnt let edges fade away like full flag
Fx = conv2(Image,k', 'valid');
Fy = conv2(Image,k, 'valid');

end

