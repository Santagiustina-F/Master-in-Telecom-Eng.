function[f1] = F1_check(labels,predictions)
C = confusionmat(labels,predictions);
p = C(2,2)/(C(2,2)+C(1,2));
r = C(2,2)/(C(2,2)+C(2,1));
f1 = 2*r*p/(r+p);