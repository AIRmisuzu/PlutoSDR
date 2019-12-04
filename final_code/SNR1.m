function SNR=SNR1(waveform)
aver=sum(waveform)/length(waveform);
l=0;
for i=1:length(waveform)
   l=l+abs(waveform(i)-aver)^2;
end
SNR=l/length(waveform);
end
