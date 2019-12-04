function BER = Ber(rx_bs,tx_bs)
er=0 ;
for i=1:length(rx_bs)
    if rx_bs(i)~=tx_bs(i) ;
        er=er+1 ;
    end
end
BER=er/length(rx_bs) ;

end
