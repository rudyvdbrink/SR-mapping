function accs = FR_run_classification(betas,stiminfo,dim,nfolds)
% accs = FR_run_classification(betas,stiminfo,dim,nfolds)
%
% Implements SVM classification with k-fold cross validation.
%
% Input:
%  betas: single-trial regression coefficients
%  stiminfo: Trials x variables matrix of stimulus / response information
%            Variables: 1) onset time of stimulus
%                       2) stimulus type
%                       3) response type
%                       4) active rule
%  dim: dimension to classify, corresponding to stimulus (2) or 
%       response (3)
%  nfolds: number of cross-validation folds
%
% Output:
%   accs: classification accuracy in percent, where chance level is 50%

%% run classification

accs    = nan(nfolds,1);
cuetype = stiminfo(:,dim);
tidx    = round(linspace(0,length(cuetype),nfolds+1));

for fi = 1:nfolds
    
    %get train and test data indces
    testidx = zeros(size(cuetype));
    testidx(tidx(fi)+1:tidx(fi+1)) = 1;    
    testidx  = logical(testidx); %indices of trials for training
    trainidx = ~testidx; %indices of trials for testing
    
    %define training and testing data
    traindata = betas(trainidx,:);
    testdata  = betas(testidx ,:);
    traintype = cuetype(trainidx);
    testtype  = cuetype(testidx );
    
    %match conditions in training data    
    [n, maxcondi] = max([sum(traintype == 1) sum(traintype == -1)]); 
    cis = [1 -1];
    maxcondi = cis(maxcondi);
    condis2match  = setdiff([-1 1],maxcondi);   
    idx = find(traintype == condis2match);
    idx = randsample(idx,n - sum(traintype == condis2match),1 );
    traindata = cat(1,traindata,traindata(idx,:));
    traintype = cat(1,traintype,traintype(idx));
    
    % standardize 
    traindata = zscore(traindata);
    testdata  = zscore(testdata);   
    
    %train support vector machine
    svmmodel      = fitcsvm(traindata,traintype);
    
    %test support vector machine
    [classs,~] = predict(svmmodel,testdata);    
    perf  = nanmean(  [ mean(classs(testtype == -1)==-1)   mean(classs(testtype == 1)==1)] ); %accuracy, balanced for type in testing data
    accs(fi) = perf * 100; %convert to percent correct
    
end %end cross-validation loop


accs = nanmean(accs);
