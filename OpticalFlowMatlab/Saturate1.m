function Gout = Saturate1(G, MAX, MIN)
Gout = G;
GPosInd = find(G >= MAX);
Gout(GPosInd) = MAX;
GNegInd = find(G < MIN);
Gout(GNegInd) = MIN;