function [Gray_image] = rgb_to_gray(Image)
% Diese Funktion soll ein RGB-Bild in ein Graustufenbild umwandeln. Falls
% das Bild bereits in Graustufen vorliegt, soll es direkt zurückgegeben werden.

  [rows, columns, numberOfColorChannels] = size(Image);
  if numberOfColorChannels  == 3
    % It's color, need to convert it to grayscale.
    redChannel = Image(:, :, 1);
    greenChannel = Image(:, :, 2);
    blueChannel = Image(:, :, 3);
    
    % Do the weighted sum.
    Gray_image = .299*redChannel + .587*greenChannel + .114*blueChannel;
    % uint8 display
    Gray_image = uint8(Gray_image);
  elseif numberOfColorChannels == 1
      % It's already gray scale.
    Gray_image = Image;  % Input image is not really RGB color.
  end
end
