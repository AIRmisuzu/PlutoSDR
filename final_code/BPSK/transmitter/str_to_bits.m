% function msg_bits = str_to_bits(msgStr)
% msgBin = de2bi(int8(msgStr),8,'left-msb');
% len = size(msgBin,1).*size(msgBin,2);
% msg_bits = reshape(double(msgBin).',len,1).'
%  end
function  wave = str_to_bits(tx_msg)
SPB=1 ;
tx_bs=[];
for c=1:length(tx_msg)
    character=tx_msg(c);
end
tx_ascii = abs(tx_msg);
textbit = dec2bin(tx_ascii,8);
str = num2str(textbit);
sizestr = size(str);
for i = 1:sizestr(1)
    if i == 1
        tx_bs = str(i,:);
        continue;
    end
    tx_bs= strcat(tx_bs, str(i,:));
end
wave = [];
for i = 1:length(tx_bs)
    for j = 1:SPB
        wave = [wave str2double(tx_bs(i))];
    end
end
end
