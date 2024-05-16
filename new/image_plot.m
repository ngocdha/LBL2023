A = [50*ones(3,1);100*ones(7,1); 50*ones(3,1)];
c = gray(100);

figure;
for i = 1:13
    plot(i, 0, 'o', 'Color', c(A(i),:), MarkerFaceColor=c(A(i),:));
    set(gca,'Color','k');
    %xlim([1 13]);
    hold on
end
title("Test image: 13 pixels")