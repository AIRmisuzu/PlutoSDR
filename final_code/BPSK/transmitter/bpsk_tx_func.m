function [txdata,wave]= bpsk_tx_func(msgStr)
%% train sequence
seq_sync=tx_gen_m_seq([1 0 0 0 0 0 1]);
sync_symbols=tx_modulate(seq_sync, 'BPSK');
%% string to bits
wave=str_to_bits(msgStr);
%% crc32
ret=crc32(wave);
inf_bits=[wave ret.'];
%% scramble
scramble_int=[1,1,0,1,1,0,0];
sym_bits=scramble(scramble_int, inf_bits);
%% modulate
mod_symbols=tx_modulate(sym_bits, 'BPSK');
%% insert pilot
data_symbols=insert_pilot(mod_symbols);
trans_symbols=[sync_symbols data_symbols];
%% srrc
fir=rcosdesign(1,128,4);
tx_frame=upfirdn(trans_symbols,fir,4);
tx_frame=[tx_frame, zeros(1,1e2)];
txdata = tx_frame.';

end

