function SSE  = fit_gauss(guess, X, Y, displayflag)

[mu sig amp] = deal(  guess(1), guess(2), guess(3) );

   
Est = amp.*exp(-(X-mu).^2./sig.^2);
    

SSE = sum( (Est-Y).^2 );


if displayflag
    bar(X, Y, 'k'); hold on
    plot(X, Est, 'r-'); hold off
    drawnow
end

