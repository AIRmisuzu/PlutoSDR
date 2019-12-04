function [msg1,msg2]= bpsk_PHY(msgStr)
global work_mode;global n;
global lpf_send;global lpf_freceive1;global lpf_freceive2;
global fsend;global freceive1;global freceive2;global fs;
global txdata_16_length;global tx_repeat_n;global rx_repeat_n;
global s;global sdr_input;global sdr_output;

    [txdata,wave] = bpsk_tx_func(msgStr);

    t=0:1:length(txdata).*n-1;
    lo_data=exp(1j*2*pi*t*fsend/fs)';

    copy_data=repmat([1], 1,n);
    mf_data=kron(txdata,copy_data');
    mf_data=filter(lpf_send,1,mf_data);
    txdata=mf_data.*lo_data;

    txdata = round(txdata .* 2^14);
    senddata=repmat(txdata, tx_repeat_n,1);
    sdr_input{1} = real(senddata);
    sdr_input{2} = imag(senddata);
    sdr_output = stepImpl(s, sdr_input);
    I = sdr_output{1};
    Q = sdr_output{2};
    Rx = I+1i*Q ;

    b_lpf=fir1(256,0.2);
    t=0:1:length(Rx)-1;
    
    Rx1=filter(lpf_freceive1,1,Rx);
    lo_data=exp(-1j*2*pi*t*freceive1/fs)';
    Rx1 = Rx1.*lo_data;
    Rx1=filter(b_lpf,1,Rx1);
    
    Rx2=filter(lpf_freceive2,1,Rx); 
    lo_data=exp(-1j*2*pi*t*freceive2/fs)';
    Rx2=Rx2.*lo_data; 
    Rx2=filter(b_lpf,1,Rx2);
    
    z_length = length(Rx)/n;
    
    Receive_data1=zeros(z_length,1);
    Receive_data2=zeros(z_length,1);
    z=1;
    for z=1:z_length
        Receive_data1(z)=Rx1(z*n);
        Receive_data2(z)=Rx2(z*n);
    end

    msg1=bpsk_rx_func(Receive_data1,txdata_16_length+2); 
    msg2=bpsk_rx_func(Receive_data2,txdata_16_length+2);
    
end