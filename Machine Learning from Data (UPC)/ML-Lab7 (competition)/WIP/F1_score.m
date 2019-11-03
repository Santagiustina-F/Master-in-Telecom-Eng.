function[f1] = F1_score(labels,predictions)
tp = sum(and(labels,predictions));
fn = sum(or(labels,predictions)-predictions);
fp = sum(or(labels,predictions)-labels);
rec = tp/(tp+fn);
prec = tp/(tp+fp);
f1 = 2*(prec*rec)/(prec+rec);







