function [Fx,Fy] = sobel_xy(Image)
% In dieser Funktion soll das Sobel-Filter implementiert werden, welches
% ein Graustufenbild einliest und den Bildgradienten in x- sowie in
% y-Richtung zur?ckgibt.

% check if grey scale image
if( ~ismatrix(Image) )
    error('No Grayscale Image!');
end

% preping image by adding additional border
Image = [Image(1,1)   , Image(1,:)   , Image(1,end)  ;
         Image(:, 1)  , Image        , Image(:,end)  ;
         Image(end, 1), Image(end, :), Image(end,end)];

% sobel operator
sobel_op = [1, 0, -1;
            2, 0, -2;
            1, 0, -1 ];

% 2D concolution
Fx = conv2(double(Image), sobel_op, 'valid');
Fy = conv2(double(Image), sobel_op.', 'valid');


end

