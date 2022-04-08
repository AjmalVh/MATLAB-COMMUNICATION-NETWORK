% ---------------------------- INPUT VALUES ------------------------------------ %

source_ip = "192.198.13.11"; % source IP
dest_ip = "192.168.19.31"; % destination IP
data = "Hi"; % input Data

source_port = 20; % source port
dest_port = 10; % destination port

UDP_len = 8; % UDP length in bytes (UDP header takes 8 bytes and the remaining for storing data)
EB_protocol = 17; % 8 bit protocol for UDP is 17
% length of UDP -> length of UDP header + length of data/payload
UDP_len += length(data); % for dynamically adjusting the UDP length according to data length


% ---------------------------- CUSTOM FUNCTIONS --------------------------------- %

% This function will return the checksum computed for the given packet parameters.
function [comp] = compute_checksum(source_ip, dest_ip, source_port, dest_port, protocol, UDP_len, data)
    % 1. initgerize source_ip
    % converting source IP in string format to integer
    source_ip_int = [];
    source_ip = strsplit(source_ip,".");
    b1 = dec2bin(str2double(source_ip(1)), 8); % binarize 1st segment of IP address
    b2 = dec2bin(str2double(source_ip(2)), 8); % binarize 2nd segment of IP address
    b3 = dec2bin(str2double(source_ip(3)), 8); % binarize 3rd segment of IP address
    b4 = dec2bin(str2double(source_ip(4)), 8); % binarize 4th segment of IP address
    
    seg1 = strcat(b1 , b2); % string concatination first 2 segments of IP address
    seg2 = strcat(b3 , b4); % string concatination last 2 segments of IP address
    
    source_ip_int(1) = bin2dec(seg1); % binary to decimal conversion
    source_ip_int(2) = bin2dec(seg2); % ""
    
    % 2. initgerize destination_ip
    % converting Destination IP in string format to integer
    dest_ip_int = [];
    dest_ip = strsplit(dest_ip,".");
    b1 = dec2bin(str2double(dest_ip(1)), 8); % binarize 1st segment of IP address
    b2 = dec2bin(str2double(dest_ip(2)), 8); % binarize 2nd segment of IP address
    b3 = dec2bin(str2double(dest_ip(3)), 8); % binarize 3rd segment of IP address
    b4 = dec2bin(str2double(dest_ip(4)), 8); % binarize 4th segment of IP address
    
    seg1 = strcat(b1 , b2); % string concatination first 2 segments of IP address
    seg2 = strcat(b3 , b4); % string concatination last 2 segments of IP address
    
    dest_ip_int(1) = bin2dec(seg1); % binary to decimal conversion
    dest_ip_int(2) = bin2dec(seg2); % ""
    
    % 3. integerize data
    % converting String data to its unicode format (ASCII format), i.e string to integer 
    data_int = [];
    data = double(data);
    
    if mod(length(data), 2) ~= 0
       % if length of data is odd, do padding with 'space' its ASCII code is 32
       data = [data, 32]; % appending 32 as last element
    endif
    
    ii = 0;
    for i = 1:2:length(data)
        ii += 1;
        data_bin = strcat(dec2bin(data(i), 8), dec2bin(data(i+1), 8));
        data_int(ii) = bin2dec(data_bin);
    endfor
    
    % 4. creating UDP packet
    packet = [source_ip_int, dest_ip_int, UDP_len, protocol, source_port, dest_port, UDP_len, data_int]; 
    packet_bin = dec2bin(sum(packet), 16); % Adding all UDP packet headers and converting it into binary
    
    if length(packet_bin) > 16 % check if the total binary sum of UDP packet is 16 bit or not
        % if the size is greater than 16 bit then we take out the 1st bit and add it with the remaining -
        % - simillar to carry addition
        n = length(packet_bin) - 16;
        b1 = packet_bin(1:n); % carry
        b2 = packet_bin(n+1:length(packet_bin)); % remaining packet bits
        b_sum = bin2dec(b1) + bin2dec(b2); % binary addition , so in first step convert to decimal and do addition
        packet_bin = dec2bin(b_sum, 16); % then convert back to binary 
    endif
    
    % 5. finding the checksum
    % checksum is the one's compliment of sum of packet segments
    comp = '';
    i = 0;
    dict = struct('0','1', '1', '0');
    for b = packet_bin
      i += 1;
      comp = strcat(comp, dict.(b)); % swapping between 1's and 0's -> one's compliment
    endfor
    
endfunction


% ---------------------------- MAIN ------------------------------------ %

# finding the checksum
checksum = compute_checksum(source_ip, dest_ip, source_port, dest_port, EB_protocol, UDP_len, data); 
disp(["Checksum : ", checksum, " , length of checksum: ", int2str(length(checksum))]);   

% ---------------------------- END ------------------------------------ %
