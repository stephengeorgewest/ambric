function fix_number = Convert2FixNum(float_number, int_bits, frac_bits)
%this function convert the input floating number into fix point number at
%the designated bit_width. Output number is in 2's complement number.

%range checking
if (float_number>=2^(int_bits-1))
    warning('Data is out of range');
elseif (float_number<-2^(int_bits-1))
    warning('Data is out of range');
end;

fix_number.number = int32(float_number * (2^frac_bits));
fix_number.int_bits = int_bits;
fix_number.frac_bits= frac_bits;

