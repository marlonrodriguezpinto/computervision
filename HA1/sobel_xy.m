function [Fx,Fy] = sobel_xy(Image)
% In dieser Funktion soll das Sobel-Filter implementiert werden, welches
% ein Graustufenbild einliest und den Bildgradienten in x- sowie in
% y-Richtung zurückgibt.

% dims image 2000x3000
if size(Image,3) ~= 1
    error('no gray image')
end

% vert sobel
k = [1 2 1; 0 0 0; -1 -2 -1];

% take valid flag cause output is only Fx,Fy and not a matrix
% valid doesnt let edges fade away like full flag
Fx = conv2(double(Image),k', 'valid');
Fy = conv2(double(Image),k, 'valid');

end

