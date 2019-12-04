 clearvars -except times;close all;warning off;
set(0,'defaultfigurecolor','w');
global msg ;
global wave ;
global debug_level;global n;
global lpf_send;global lpf_freceive1;global lpf_freceive2;
global fsend;global freceive1;global freceive2;global fs;
global txdata_16_length;global tx_repeat_n;global rx_repeat_n;
ip = '192.168.2.1';
addpath BPSK\transmitter
addpath BPSK\receiver
addpath Library
%% 参数配置
%工作模式选择
debug_level=0;
%三个工作频点,单位HZ
fband=1000000;
f0=2000000;
f1=5000000;
f2=8000000;
fs=40000000;%采样频率40MHZ
n=10;%降采样频率比
Power=30;
lpf_send=fir1(128,0.1);%发送滤波器配置
%lpf_f0=fir1(128,fband*4/fs);
% lpf_f0=fir1(128,[(f0-fband)*2/fs (f0+fband)*2/fs],'bandpass');
% lpf_f1=fir1(128,[(f1-fband)*2/fs (f1+fband)*2/fs],'bandpass');
% lpf_f2=fir1(128,[(f2-fband)*2/fs (f2+fband)*2/fs],'bandpass');

%配置为2号机
% fsend=f2;%发送频点配置
% freceive1=f0;%接收频点配置
% freceive2=f1;%接收频点配置
% lpf_freceive1=lpf_f0;
% lpf_freceive2=lpf_f1;

txdata_16_length=10;
header_length=12+16;
package_length=txdata_16_length*16;%数据长度
tx_repeat_n=2;%发送缓存区数据复制倍数
rx_repeat_n=2;%接收缓存区数据复制倍数


%% 读取输入命令配置当前组网发送格式
work_mode1='free';
work_mode2='free';
%work_mode='receive';
send_state='free';
receive1_state='wait';
receive2_state='wait';
repeat_num=1;
repeat_i=1;
repeat_flag=0;
message_level=2;
send_flag=1;
receive1_flag=1;
receive2_flag=1;
for i=1:1000
    prompt='请配置本地工作站点名';
    local=input(prompt);
    if local==0 fsend=f0;
    elseif local==1 fsend=f1;
    elseif local==2 fsend=f2;
    else continue;  
    end
    prompt='请配置通道1名';
    chan1=input(prompt);
    if chan1==0 freceive1=f0;
    elseif chan1==1 freceive1=f1;
    elseif chan1==2 freceive1=f2;
    else continue;  
    end
    prompt='请配置通道2名';
    chan2=input(prompt);
    if chan2==0 freceive2=f0;
    elseif chan2==1 freceive2=f1;
    elseif chan2==2 freceive2=f2;
    else continue;  
    end
    %if(local~=chan1&&local~=chan2&&chan1~=chan2)
        break;
    %end
end

fprintf('当前工作机为%i号机，通道1配置为%i号机，通道2配置为%i号机\n',local,chan1,chan2);

for i=1:1000
    prompt='请输入命令';
    str=input(prompt,'s');
    command=zeros(1,100);
    for i=1:length(str)
        command(i)=str(i);
    end
    if command(1:5)=='start' fprintf('系统开始工作\n'); break; end
    if command(1:5)=='debug' fprintf('配置为调试模式\n'); debug_level=1; end
    if command(1:6)=='repeat' 
       prompt='请输入重复次数';
       repeat_num=input(prompt);
    end
    if command(1:7)=='message'
       prompt='请输入显示消息等级';%等级越高显示的信息越少
       message_level=input(prompt);
    end
    if command(1:7)=='release' fprintf('配置为非调试模式\n'); debug_level=0; end
    if command(1:3)=='ch1'
        if (command(5:8)=='send') 
            if(~strcmp(work_mode2,'send'))
                fprintf('通道1配置为发送模式\n');work_mode1='send';
            end
        elseif command(5:11)=='receive' fprintf('通道1配置为接收模式\n');work_mode1='rece';
        elseif command(5:8)=='free' fprintf('通道1不工作\n');work_mode1='free';
        end
    end
    if command(1:3)=='ch2'
        if (command(5:8)=='send') 
            if(~strcmp(work_mode1,'send'))
                fprintf('通道2配置为发送模式\n');work_mode2='send';
            end
        elseif command(5:11)=='receive' fprintf('通道2配置为接收模式\n');work_mode2='rece';
        elseif command(5:8)=='free' fprintf('通道2不工作\n');work_mode2='free';
        end
    end
end

%根据配置的频点生成对应的滤波器
lpf_freceive1=fir1(128,[(freceive1-fband)*2/fs (freceive1+fband)*2/fs],'bandpass');
lpf_freceive2=fir1(128,[(freceive2-fband)*2/fs (freceive2+fband)*2/fs],'bandpass');

%% 测试用数据
msghead='kamiomisuzu-5678567856785678';
msgdata='5678567856785678';

repeate_data=repmat([1], 1,txdata_16_length);
msgStr=kron(msgdata,repeate_data);
msgStr=[msghead,msgStr];
[txdata,wave] = bpsk_tx_func(msgStr);

% figure(1);
% a=fft(txdata,4096);
% fft_data=abs(a);
% f = (0:length(a)-1)*40/length(a);
% plot(f,fft_data);

t=0:1:length(txdata).*n-1;
lo_data=exp(1j*2*pi*t*fsend/fs)';

copy_data=repmat([1], 1,n);
mf_data=kron(txdata,copy_data');

mf_data=filter(lpf_send,1,mf_data);
txdata=mf_data.*lo_data;


txdata = round(txdata .* 2^14);
senddata=repmat(txdata, tx_repeat_n,1);

%% PlutoSDR配置
% Transmit and Receive using MATLAB libiio
% System Object Configuration
global s;global sdr_input;global sdr_output;

s = iio_sys_obj_matlab; % MATLAB libiio Constructor
s.ip_address = ip;
s.dev_name = 'ad9361';
s.in_ch_no = 2;
s.out_ch_no = 2;
s.in_ch_size = length(txdata).*tx_repeat_n;
s.out_ch_size = length(txdata).*rx_repeat_n;
s = s.setupImpl();

sdr_input = cell(1, s.in_ch_no + length(s.iio_dev_cfg.cfg_ch));
sdr_output = cell(1, s.out_ch_no + length(s.iio_dev_cfg.mon_ch));

% Set the attributes of AD9361
sdr_input{s.getInChannel('RX_LO_FREQ')} = 18e8;
sdr_input{s.getInChannel('RX_SAMPLING_FREQ')} = 40e6;
sdr_input{s.getInChannel('RX_RF_BANDWIDTH')} = 20e6;
sdr_input{s.getInChannel('RX1_GAIN_MODE')} = 'manual';%% slow_attack manual
sdr_input{s.getInChannel('RX1_GAIN')} = Power;
sdr_input{s.getInChannel('TX_LO_FREQ')} = 18e8;
sdr_input{s.getInChannel('TX_SAMPLING_FREQ')} = 40e6;
sdr_input{s.getInChannel('TX_RF_BANDWIDTH')} = 20e6;


%% 文件读取，生成发送用文件
%读取一个txt文件
fid=fopen('data.txt','r');
data=fscanf(fid,'%c');
%读取一个音频文件
[music_data,Fs] = audioread('music.wav');
quan_data=transdouble(music_data); 

data=quan_data;

%打包整形
all_length=length(data);
package_num=idivide(all_length,int32(package_length),'floor')+1;
extera_length=package_num*package_length-all_length;
extera_data=zeros(1,extera_length);
re_data=[data extera_data];
package_data=zeros(package_num,package_length);
for i=1:package_num
    package_data(i,:)=re_data(((i-1)*txdata_16_length*16+1):(i*txdata_16_length*16));
end

package_i=1;
send_data=zeros(1,package_length);
package_buffer=zeros(1,package_num);
header1=zeros(1,14);
header2=zeros(1,14);
send_header=zeros(1,14);
receive_header1=zeros(1,14);
receive_header2=zeros(1,14);
zero_header=zeros(1,14);
if(work_mode1=='send')
    send_state='wait';
    chansend=power(2,chan1);
end
if(work_mode2=='send')
    chansend=power(2,chan2);
    send_state='wait';
end
%% 主循环
while(1)
%% 数据生成部分
%header(1)配置接收对象 1->0号机 2->1号机 4->2号机 0空闲，不发给任何一个
%header(2)配置发送命令
%1->发送数据包请求命令 2->发送数据包应答命令 4->数据包发送命令 8->数据包接收回传命令，带4个接收包确认信号
%16->指示数据接收完毕信号 
%包序号从1开始，0用来指示没有接收到任何数据包
%发送数据请求包extera 1byte指示总共有多少数据包，1byte指示最后一个数据包补了多少个0
%发送数据包extera 1byte指示当前发送序号
%数据包回传命令 1byte接收序号*4
%发送开始数据包
    if message_level<2
        send_flag=1;
        receive1_flag=1;
        receive2_flag=1;
    end
    if(send_state=='wait') 
        if(repeat_i<=repeat_num)
            send_header(1)=chansend;
            send_header(2)=1;
            send_header(3)=floor(double(package_num)/256);
            send_header(4)=mod(package_num,256);
            send_header(5)=floor(double(extera_length)/256);
            send_header(6)=mod(extera_length,256);
            if send_flag>0
            fprintf('第%i次数据发送等待中...\n',repeat_i);
            send_flag=0;
            end
            for i=1:package_num
                package_buffer(i)=0;
            end
        else
            fprintf('数据已全部发送完毕\n');
            send_state='stop';
        end
    end
    if(send_state=='send')
        send_flag=1;
        send_header(1)=chansend;
        send_header(2)=4;
        send_header(3)=floor(double(package_i)/256);
        send_header(4)=mod(package_i,256);
        send_data=package_data(package_i,:);
    end
               
    if(work_mode1=='send')  header1=send_header;
    elseif(work_mode1=='rece')  header1=receive_header1;
    else
        header1=zero_header;
    end
    
    if(work_mode2=='send')  header2=send_header;
    elseif(work_mode2=='rece')  header2=receive_header2;
    else
        header2=zero_header;
    end
    
%% 数据传输与接收部分
    msgStr=[header1 header2 send_data];
    [msg1 msg2]=bpsk_PHY(msgStr);
    
%% 通道1数据处理
%     if(msg1(1)==power(2,local))
%         ch1header=msg1(1:14);
%     elseif(msg1(15)==power(2,local))
%         ch1header=msg1(15:28);
%     else
%         ch1header=zero_header;
%     end
 
    if(work_mode1=='send')
%% 通道1发送模式 
        if(msg1(1)==power(2,local)&&(msg1(2)==2||msg1(2)==16||msg1(2)==8))
            ch1header=msg1(1:14);
        elseif(msg1(15)==power(2,local)&&(msg1(16)==2||msg1(16)==16||msg1(16)==8))
            ch1header=msg1(15:28);
        else
            ch1header=zero_header;
        end
        if ch1header(2)==2&&strcmp(send_state,'wait')
            repeat_flag=1;
            send_state='send';
        end
        if ch1header(2)== 16&&strcmp(send_state,'send')
            send_state='wait';
            if(repeat_flag)
            fprintf('第%i次数据发送完毕\n',repeat_i);
            repeat_i=repeat_i+1;
            repeat_flag=0;
            end
        end
        if ch1header(2)==8
            if(ch1header(3)>0||ch1header(4)>0) package_buffer(ch1header(3)*256+ch1header(4))=1;end
            if(ch1header(5)>0||ch1header(6)>0) package_buffer(ch1header(5)*256+ch1header(6))=1;end
            if(ch1header(7)>0||ch1header(8)>0) package_buffer(ch1header(7)*256+ch1header(8))=1;end
            if(ch1header(9)>0||ch1header(10)>0) package_buffer(ch1header(9)*256+ch1header(10))=1;end
            if(ch1header(11)>0||ch1header(12)>0) package_buffer(ch1header(11)*256+ch1header(12))=1;end
            if(ch1header(13)>0||ch1header(14)>0) package_buffer(ch1header(13)*256+ch1header(14))=0;end
        end
        
        if(send_state=='send')
            count=0; 
            for i=1:package_num
                if(package_buffer(i)==1)
                    count=count+1;
                end
            end
            if message_level==0
                fprintf('ch1 send package %i  ...\n',count);
            end
            for i=1:package_num
                if(package_i==package_num)
                    package_i=1;
                else
                    package_i=package_i+1;
                end
                if(package_buffer(package_i)==0)
                    break;
                end
            end
        end
        
        
%% 通道1接收模式  
    elseif(work_mode1=='rece')
% 保证环回测试的正确性
        if(msg1(1)==power(2,local)&&(msg1(2)==1||msg1(2)==4))
            ch1header=msg1(1:14);
        elseif(msg1(15)==power(2,local)&&(msg1(16)==1||msg1(16)==4))
            ch1header=msg1(15:28);
        else
            ch1header=zero_header;
        end
        if receive1_state=='stop'
            if ch1header(2)==1
                receive1_state='wait';
            end
        end
        if receive1_state=='wait'
            if(receive1_flag>0)
            fprintf('通道1接收等待中...\n');
            receive1_flag=0;
            end
            if ch1header(2)==1
                receive_header1(1)=power(2,chan1);
                receive_header1(2)=2;
                for i=3:14
                    receive_header1(i)=0;
                end
                receive1_package_num=ch1header(3)*256+ch1header(4);
                receive1_extera=ch1header(5)*256+ch1header(6);
                receive1_data=zeros(receive1_package_num,package_length);
                receive1_buffer=zeros(1,receive1_package_num);
                receive1_state='work';
                ch1_music_length=receive1_package_num*package_length-receive1_extera;
            end
        end
        count=0;
        if receive1_state=='work'
            receive1_flag=1;
            if ch1header(2)==4
                receive_header1(2)=8;
                
                for i=5:12
                    receive_header1(i)=receive_header1(i-2);
                end
                receive_header1(4)=ch1header(4);
                receive_header1(3)=ch1header(3);
                receive1_data(ch1header(3)*256+ch1header(4),:)=msg1(header_length+1:header_length+package_length);
                receive1_buffer(ch1header(3)*256+ch1header(4))=1;
                need_data=0;
                for i=1:receive1_package_num
                    if(receive1_buffer(i)==1)
                        count=count+1;
                    else
                        need_data=i;
                    end
                end
                receive_header1(13)=floor(double(need_data)/256);
                receive_header1(14)=mod(need_data,256);
                if message_level==0
                    fprintf("ch1 receive package %i...\n",count);
                end
                if(count==receive1_package_num)
                    ch1_music_data=zeros(1,ch1_music_length);
                    for i=1:receive1_package_num-1
                        ch1_music_data(((i-1)*package_length+1):(i*package_length))=receive1_data(i,:);
                    end
                    ch1_music_data(((receive1_package_num-1)*package_length+1):ch1_music_length)=receive1_data(i,1:package_length-receive1_extera);
                    ch1_quan_data=detransdouble(ch1_music_data);
                    audiowrite('receive1.wav',ch1_quan_data,44100);
                    fprintf('通道1数据接收完毕\n');
                    receive_header1(2)=16;
                    [ch1_local_data,Fs] = audioread('compare1.wav');
                    quan_local_data=transdouble(ch1_local_data);
                    compare_length=min(length(quan_local_data),length(ch1_music_data));
                    [ch1number,ch1ratio] = biterr(quan_local_data(1:compare_length),ch1_music_data(1:compare_length));
                    fprintf('本次传输误比特率为%.3f%%\n',ch1ratio*100);
                    receive1_state='stop';      
                end
            end
        end
    else
    end
    
%% 通道2数据处理
%     if(msg2(1)==power(2,local))
%         ch2header=msg2(1:14);
%     elseif(msg2(15)==power(2,local))
%         ch2header=msg2(15:28);
%     else ch2header=zero_header;
%     end
 
    if(work_mode2=='send')
%% 通道2发送模式 
        if(msg2(1)==power(2,local)&&(msg2(2)==2||msg2(2)==16||msg2(2)==8))
            ch2header=msg2(1:14);
        elseif(msg2(15)==power(2,local)&&(msg2(16)==2||msg2(16)==16||msg2(16)==8))
            ch2header=msg2(15:28);
        else
            ch2header=zero_header;
        end
        if ch2header(2)==2&&strcmp(send_state,'wait')
            send_state='send';
            repeat_flag=1;
        end
        if ch2header(2)== 16&&strcmp(send_state,'send')
            send_state='wait';
            if(repeat_flag)
            fprintf('第%i次数据发送完毕\n',repeat_i);
            repeat_i=repeat_i+1;
            repeat_flag=0;
            end
        end
        if ch2header(2)==8
            if(ch2header(3)>0||ch2header(4)>0) package_buffer(ch2header(3)*256+ch2header(4))=1;end
            if(ch2header(5)>0||ch2header(6)>0) package_buffer(ch2header(5)*256+ch2header(6))=1;end
            if(ch2header(7)>0||ch2header(8)>0) package_buffer(ch2header(7)*256+ch2header(8))=1;end
            if(ch2header(9)>0||ch2header(10)>0) package_buffer(ch2header(9)*256+ch2header(10))=1;end
            if(ch2header(11)>0||ch2header(12)>0) package_buffer(ch2header(11)*256+ch2header(12))=1;end
            if(ch2header(13)>0||ch2header(14)>0) package_buffer(ch2header(13)*256+ch2header(14))=0;end
        end
        if(send_state=='send')
			count=0; 
			for i=1:package_num
				if(package_buffer(i)==1)
					count=count+1;
				end
            end
            if message_level==0
                fprintf('ch2 send package %i  ...\n',count);
            end
			while(1)
				if(package_i==package_num)
					package_i=1;
				else
					package_i=package_i+1;
				end
				if(package_buffer(package_i)==0)
					break;
				end
			end
		end
        
%% 通道2接收模式  
    elseif(work_mode2=='rece')
        if(msg2(1)==power(2,local)&&(msg2(2)==1||msg2(2)==4))
            ch2header=msg2(1:14);
        elseif(msg2(15)==power(2,local)&&(msg2(16)==1||msg2(16)==4))
            ch2header=msg2(15:28);
        else
            ch2header=zero_header;
        end
        if receive2_state=='stop'
            if ch2header(2)==1
                receive2_state='wait';
            end
        end
        if receive2_state=='wait'
            if receive2_flag>0
            fprintf('通道2接收等待中...\n');
            receive2_flag=0;
            end
            if ch2header(2)==1
                receive_header2(1)=power(2,chan2);
                receive_header2(2)=2;
                for i=3:14
                    receive_header2(i)=0;
                end
                receive2_package_num=ch2header(3)*256+ch2header(4);
                receive2_extera=ch2header(5)*256+ch2header(6);
                receive2_data=zeros(receive2_package_num,package_length);
                receive2_buffer=zeros(1,receive2_package_num);
                receive2_state='work';
                ch2_music_length=receive2_package_num*package_length-receive2_extera;
            end
        end
        count=0;
        if receive2_state=='work'
            receive2_flag=1;
            if ch2header(2)==4
                receive_header2(2)=8;
                
                for i=5:12
                    receive_header2(i)=receive_header2(i-2);
                end
                receive_header2(4)=ch2header(4);
                receive_header2(3)=ch2header(3);
                receive2_data(ch2header(3)*256+ch2header(4),:)=msg2(header_length+1:header_length+package_length);
                receive2_buffer(ch2header(3)*256+ch2header(4))=1;
                need_data=0;
                for i=1:receive2_package_num
                    if(receive2_buffer(i)==1)
                        count=count+1;
                    else
                        need_data=i;
                    end
                end
                receive_header2(13)=floor(double(need_data)/256);
                receive_header2(14)=mod(need_data,256);
                if message_level==0
                    fprintf("ch2 receive package %i...\n",count);
                end
                if(count==receive2_package_num)
                    ch2_music_data=zeros(1,ch2_music_length);
                    for i=1:receive2_package_num-1
                        ch2_music_data(((i-1)*package_length+1):(i*package_length))=receive2_data(i,:);
                    end
                    ch2_music_data(((receive2_package_num-1)*package_length+1):ch2_music_length)=receive2_data(i,1:package_length-receive2_extera);
                    ch2_quan_data=detransdouble(ch2_music_data);
                    audiowrite('receive2.wav',ch2_quan_data,44100);
                    fprintf('通道2数据接收完毕\n');
                    receive_header2(2)=16;
                    [ch2_local_data,Fs] = audioread('compare2.wav');
                    quan_local_data=transdouble(ch2_local_data);
                    compare_length=min(length(quan_local_data),length(ch2_music_data));
                    [ch2number,ch2ratio] = biterr(quan_local_data(1:compare_length),ch2_music_data(1:compare_length));
                    fprintf('本次传输误比特率为%.3f%%\n',ch2ratio*100);
                    receive2_state='stop';
                end
            end
        end
    else
    end


end

%% 结束部分
% Read the RSSI attributes of both channels
rssi1 = output{s.getOutChannel('RX1_RSSI')};
% rssi2 = output{s.getOutChannel('RX2_RSSI')};

s.releaseImpl();



