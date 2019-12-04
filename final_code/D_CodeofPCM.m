% A率13折线解码 
function A_Crent=D_CodeofPCM(CodeofPCM) 
CodeofPCM_int = CodeofPCM;
%% 极性判断  
Jixing = 1; 
if floor(CodeofPCM_int/2^7) == 0   
    Jixing = -1; 
end
%% 段号 
DuanHao = floor(mod(abs(CodeofPCM_int),2^7)/2^4); 
switch DuanHao  
    case 0    
        DuanluoQS=0;        
        LinghuaJG=1;   
    case 1     
        DuanluoQS=16;   
        LinghuaJG=1;   
    case 2       
        DuanluoQS=32;   
        LinghuaJG=2;    
    case 3        
        DuanluoQS=64;      
        LinghuaJG=4;   
    case 4   
        DuanluoQS=128;    
        LinghuaJG=8;   
    case 5     
        DuanluoQS=256;    
        LinghuaJG=16;  
    case 6       
        DuanluoQS=512;    
        LinghuaJG=32;   
    case 7        
        DuanluoQS=1024;   
        LinghuaJG=64; 
end
%%段内码提取
DuanNeima = mod(abs(CodeofPCM_int),2^4); 
absofA_Crent = DuanluoQS + LinghuaJG*DuanNeima + 0.5*LinghuaJG; 
A_Crent=absofA_Crent*Jixing/2048;