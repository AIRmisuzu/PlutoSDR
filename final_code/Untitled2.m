[y,Fs] = audioread('1.wav');
ylength=length(y);
figure(1);
plot(y);
music_length=800;
music_data=zeros(1,music_length);
for i=1:music_length
    music_data(i)=y(i+18000,1);
end
figure(2);
plot(music_data);
audio = audioplayer(music_data,Fs);
play(audio);
audiowrite('music5.wav',music_data,Fs);