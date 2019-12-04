%% 通道2数据处理
    if(msg2(1)==power(2,local))
        ch2header=msg2(1:14);
    elseif(msg2(15)==power(2,local))
        ch2header=msg2(15:28);
    else ch2header=zero_header;
    end
 
    if(work_mode2=='send')
%% 通道1发送模式   
        if ch2header(2)==2
            send_state='send';
        end
        if ch2header(2)==8
            if(ch2header(3)>0||ch2header(4)>0) package_buffer(ch2header(3)*256+ch2header(4))=1;end
            if(ch2header(5)>0||ch2header(6)>0) package_buffer(ch2header(5)*256+ch2header(6))=1;end
            if(ch2header(7)>0||ch2header(8)>0) package_buffer(ch2header(7)*256+ch2header(8))=1;end
            if(ch2header(9)>0||ch2header(10)>0) package_buffer(ch2header(9)*256+ch2header(10))=1;end
            if(ch2header(11)>0||ch2header(12)>0) package_buffer(ch2header(11)*256+ch2header(12))=1;end
            if(ch2header(13)>0||ch2header(14)>0) package_buffer(ch2header(13)*256+ch2header(14))=1;end
        end
        count=0; 
        for i=1:package_num
            if(package_buffer(i)==1)
                count=count+1;
            end
        end
        fprintf('Send package %i  ...\n',count);
        if(count==package_num)
            for i=1:package_num
                package_buffer(i)=0;
            end
        else
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
        
%% 通道1接收模式  
    elseif(work_mode2=='rece')
        if receive1_state=='wait'
            if ch2header(2)==1
                receive_header2(1)=4;
                receive_header2(2)=2;
                for i=3:14
                    receive_header2(i)=0;
                end
                receive_package_num=ch2header(3)*256+ch2header(4);
                receive_extera=ch2header(5)*256+ch2header(6);
                receive_data=zeros(receive_package_num,package_length);
                receive_buffer=zeros(1,receive_package_num);
                receive_state='work';
                music_length=receive_package_num*package_length-receive_extera;
            end
        end
        count=0;
        if receive1_state=='work'
            if ch2header(2)==4
                receive_header2(2)=8;
                
                for i=5:14
                    receive_header2(i)=receive_header2(i-2);
                end
                msgStr(4)=ch2header(4);
                msgStr(3)=ch2header(3);
                receive_data(ch2header(3)*256+ch2header(4),:)=ch2header(header_length+1:header_length+package_length);
                receive_buffer(ch2header(3)*256+ch2header(4))=1;
                for i=1:receive_package_num
                    if(receive_buffer(i)==1)
                        count=count+1;
                    end
                end
                fprintf("Receive package %i...\n",count);
                if(count==receive_package_num)
                    music_data=zeros(1,music_length);
                    for i=1:receive_package_num-1
                        music_data(((i-1)*package_length+1):(i*package_length))=receive_data(i,:);
                    end
                    music_data(((receive_package_num-1)*package_length+1):music_length)=receive_data(i,1:package_length-receive_extera);
                    quan_data=detransdouble(music_data);
                    audiowrite('receive.wav',quan_data,44100);
                end
            end
        end
    else
    end