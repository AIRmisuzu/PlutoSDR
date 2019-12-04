function CodeofPCM = C_CodeofPCM(A_Crent,Amax)
%% 极性
Jixing = 1; 
if A_Crent<0     
    Jixing=0; 
end
%% 段号  
DuanHao = 0; 
A_Crentmaxto1 = floor(abs(A_Crent)/Amax*2048); 
LinghuaJG = 0; %分段操作 
if A_Crentmaxto1 < 16    
    DuanHao = 0;   
    DuanluoQS = 0;    
    LinghuaJG = 1; 
elseif A_Crentmaxto1 < 32   
    DuanHao = 1;    
    DuanluoQS = 16;   
    LinghuaJG = 1;
elseif A_Crentmaxto1 < 64  
    DuanHao = 2;   
    DuanluoQS = 32;
    LinghuaJG = 2; 
elseif A_Crentmaxto1 < 128    
    DuanHao = 3;    
    DuanluoQS = 64;  
    LinghuaJG = 4;
elseif A_Crentmaxto1 < 256  
    DuanHao = 4;   
    DuanluoQS = 128;
    LinghuaJG = 8; 
elseif A_Crentmaxto1 < 512    
    DuanHao = 5;     
    DuanluoQS = 256; 
    LinghuaJG = 16;
elseif A_Crentmaxto1 < 1024 
    DuanHao = 6;    
    DuanluoQS = 512;   
    LinghuaJG = 32;
else
    DuanHao = 7;     
    DuanluoQS = 1024;  
    LinghuaJG = 64; 
end
%% 段内码 
if A_Crentmaxto1 == 2048    
    A_Crentmaxto1 = A_Crentmaxto1-1; 
end
DuanNeima1 = floor((A_Crentmaxto1-DuanluoQS)/LinghuaJG);
%% PCM码组 CodeofPCM 
CodeofPCM = Jixing*128+DuanHao*16+DuanNeima1;

