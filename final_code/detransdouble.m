function double_data=detransdouble(quan_data) 
double_length=length(quan_data)/2;
double_data=zeros(1,double_length);
for i=1:double_length
    Jixing=floor(quan_data(i*2-1)/128);
    high_data=mod(quan_data(i*2-1),128);
    low_data=quan_data(i*2);
    double_data(i)=(Jixing-0.5)*-2*(high_data*256+low_data);
end
double_data=double_data./32768;