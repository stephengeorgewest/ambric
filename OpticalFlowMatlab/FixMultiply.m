function product = FixMultiply(num1, num2, int_bits, frac_bits)

num1_d = double(num1.number)/(2^num1.frac_bits);
num2_d = double(num2.number)/(2^num2.frac_bits);
product_d = num1_d .* num2_d;

limit = 2^int_bits;
if (abs(product_d)>limit)
    warning('Data Overflow in Multiplication');
end;

product.number = int32(product_d * (2^frac_bits));
product.int_bits = int_bits;
product.frac_bits= frac_bits;
