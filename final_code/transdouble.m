function quan_data=transdouble(double_data) 
% c1=max((double_data));
double_length=length(double_data);
% double_data=double_data./c1;
double_data=round(double_data.*32768);
quan_data=zeros(1,double_length*2);
for i=1:double_length
    Jixing = 1; 
    transdata=double_data(i);
    if transdata<0     
        Jixing=0; 
    end
    transdata=abs(transdata);
    if(transdata>32767)
        transdata=32767;
    end
    high_data=floor(transdata/256);
    low_data=mod(transdata,256);
    quan_data(i*2-1)=128*Jixing+high_data;
    quan_data(i*2)=low_data;
end