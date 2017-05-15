function [Gray_image] = rgb_to_gray(Image)
% Diese Funktion soll ein RGB-Bild in ein Graustufenbild umwandeln. Falls
% das Bild bereits in Graustufen vorliegt, soll es direkt zur?ckgegeben werden.

switch ndims(Image)
    case 1                                          % if ndims(Image) == 3 -> grey img
        Gray_image = Image;
    case 3                                          % if ndims(Image) == 3 -> rgb img
        red_comp = double( Image(:,:,1) );          % red component
        green_comp = double( Image(:,:,2) );        % green component
        blue_comp = double( Image(:,:,3) );         % blue component
        % convert to unsigned 8bit black and whit picture
        Gray_image = uint8(0.299*red_comp + 0.587*green_comp + 0.114*blue_comp); 
    otherwise
        error('neither gray nor colored image was passed to function rgb_to_gray()!');
end

end
