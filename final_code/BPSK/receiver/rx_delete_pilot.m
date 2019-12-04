function out_signal = rx_delete_pilot(signal,data_16_length)
Nr=64+8;
Ns=length(signal)/Nr;
signal=reshape(signal,Nr,Ns);
signal=signal.';
% N=size(signal,2);
% out_signal=[];
% for i=9:N
%     out_signal1=signal(:,i);
%     out_signal=[out_signal out_signal1];
% end
% out_signal=out_signal(:)';

out_signal=signal(:,(9:end));
out_signal=reshape(out_signal,1,128*data_16_length);
c=max([abs(real(out_signal)),abs(imag(out_signal))]);
out_signal=out_signal ./c;

end

