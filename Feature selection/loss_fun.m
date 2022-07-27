function L = loss_fun(XT,yT,Xt,yt)


% SVM training
svmtemp = templateSVM('Standardize',1,'KernelFunction','linear');
Mdl_1 = fitcecoc(XT,yT,'Learners',svmtemp);

%L = loss(fitcecoc(XT,yT),Xt,yt);
L = loss(Mdl_1,Xt,yt);