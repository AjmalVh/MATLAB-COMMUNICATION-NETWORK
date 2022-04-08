% ---------------------------- INPUT VALUE ------------------------------------ %

clear all;

pep = imread("peppers.png"); % This reads the image
p = 0.01; % packet loss Probability/Rate
packet_size = 512; % defining given packet size

% ---------------------------- FUNCTIONS --------------------------------- %

% 1. Function to stimulate Bernoullis loss model
function [] = computeloss(image, p, packet_size)
    tic; % compute time
    image_packets = reshape(image, [], packet_size);
    imgbits = dec2bin(image_packets)-'0'; % used to Convert decimal to 16-bit binary
    [no_rows, bitsize] = size(imgbits);
    slice_size = (8 * packet_size)/bitsize; % 1 Byte = 8 Bits
    datapackets = []; % used to store packets of specified packet_size
    
    disp(["~~> Simulation of Bernoulli loss model running with a packet loss rate  of 'p' =  ", sprintf('%.4f', p)]); 
    disp(["~~> Image pointouts is a ", int2str(bitsize), "-Bit image."]);
    disp(["~~> Size of image is ", int2str(no_rows * bitsize), "-Bits."]);
    % Generating 256 bytes packet
    for i = 1:slice_size:no_rows
      img_slice = imgbits(i:i+slice_size-1, :); % we are taking a slice of fixed length from binarized image packet
      reshape_slice = reshape(transpose(img_slice), 1, []); % reshaping binarized image
      datapackets = [datapackets ; reshape_slice]; % appending binary data packets
    endfor
    tStop = toc; % end timer
    
    nz = bsc(datapackets, p); % Binary symmetric channel
    [numerrs, pcterrs] = biterr(datapackets, nz); % Calculating Number and percentage of errors
    [no_packets, _] = size(datapackets);
    
    disp(["~~> Image Transference rate ", int2str(no_packets), " packets with a packet size of ",int2str(packet_size), " Bytes"]); 
    disp(["~~> A wast majority of error bits = ", int2str(numerrs), ", error percentage = ", sprintf('%.4f', pcterrs)]);
    disp(["~~> Time taken to run = ", sprintf('%.4f', tStop), " Seconds"]);   
    
endfunction   

% 2. function to compress Image
function [comp_image] = compressImg(image, q)
  disp(["~~> Image Compression Quality Factor 'q' = ", int2str(q)]);  
  % q -> quality factor
  imwrite(image, 'compressed.jpg', 'jpg', 'quality', q);
  comp_image = imread('compressed.jpg');
  
endfunction


% ---------------------------- MAIN ------------------------------------ %
  
% current image 
computeloss(pep, p, packet_size);

% compress image to quality factor 40
comp_pep = compressImg(pep, q=40);
computeloss(comp_pep, p, packet_size);

% compress image to quality factor 80
comp_pep = compressImg(pep, q=80);
computeloss(comp_pep, p, packet_size);

% ---------------------------- END ------------------------------------ %
