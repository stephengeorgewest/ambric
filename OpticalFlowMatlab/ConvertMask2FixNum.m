function fix_number = ConvertMask2FixNum(float_number, int_bits, frac_bits)
%this function convert the input floating number into fix point number at
%the designated bit_width. Output number is in 2's complement number.

%range checking
if (float_number>=2^(int_bits-1))
    warning('Data is out of range');
elseif (float_number<-2^(int_bits-1))
    warning('Data is out of range');
end;

for i=1:length(float_number)
    fix_number(i).number = int32(float_number(i) * (2^frac_bits));
    fix_number(i).int_bits = int_bits;
    fix_number(i).frac_bits= frac_bits;
end;