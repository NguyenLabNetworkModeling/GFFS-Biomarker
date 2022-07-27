
clc; close all;clear


%% LOADING DATASET
filename='Shuffling_result.xlsx';
% note: duplicated gene removed from Allprot dat.

filename2='Explant_ResponseGroup_Allprot_DEGs.xlsx';
% note: duplicated gene removed from Allprot dat.
tbl_exp_dat=readtable(filename2,...
    'Sheet','DEG expression');


for ii = 1:16
    
    % load file
    tmp_tblx = readtable(filename,'Sheet',num2str(ii));
    % sort the score in a descend order
    tmp_tblx = sortrows(tmp_tblx,tmp_tblx.Properties.VariableNames(end),'descend');
    
    tmp1 = array2table(tbl_exp_dat.GeneName(table2array(tmp_tblx(:,1:end-1))));
    tmp2 = tmp_tblx(:,end);
    tmp2.Properties.VariableNames = {'PScore'};
    
    if size(tmp2,1) == 1
        tmp1 = [];
        tmp1 = tbl_exp_dat.GeneName(table2array(tmp_tblx(:,1:end-1)));
        tmp1a = array2table(tmp1');        
        tmp3 = [tmp1' tmp2];        
    else
        tmp3 = [tmp1 tmp2];
    end
    
    writetable(tmp3,strcat(pwd,'\data.output\shuffling gene symbols.xlsx'),...
        'Sheet',num2str(ii));
    
    
    tbl_scores{ii}=table2array(tmp_tblx);
    scores(ii,1) = mean(tbl_scores{ii}(:,end));
    scores(ii,2) = std(tbl_scores{ii}(:,end));
    scores(ii,3) = length(tbl_scores{ii}(:,end));
    scores_max(1,ii) = max(tbl_scores{ii}(:,end));
end


%%
% 
% tbl_exp_dat.GeneName(tbl_scores{3}(:,1:end-1))
% 
% for jj = 1:size(tmp_tblx,2)-1
%     tbl_exp_dat.GeneName(table2array(tmp_tblx(:,1)))
%     
% end
% 
% %%
% x0_a = tbl_scores{4}(:,end);
% x = zscore(x0_a);
% 
% x>2.53
% 
% norm=histfit(x,20,'normal')
% [muHat, sigmaHat] = normfit(x);
% % Plot bounds at +- 3 * sigma.
% lowBound = muHat - 3 * sigmaHat;
% highBound = muHat + 3 * sigmaHat;
% yl = ylim;
% line([lowBound, lowBound], yl, 'Color', [0, .6, 0], 'LineWidth', 1);
% line([highBound, highBound], yl, 'Color', [0, .6, 0], 'LineWidth', 1);
% line([muHat, muHat], yl, 'Color', [0, .6, 0], 'LineWidth', 1);
% grid on;
% % xFit = linspace(min(x), max(x), 100);
% % yFit = max(x) * exp(-(xFit - muHat).^2/sigmaHat^2);
% % figure;
% % plot(xFit, yFit, 'r-', 'LineWidth', 2);
% % grid on;
% % Set up figure properties:
% % Enlarge figure to full screen.
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
% % Get rid of tool bar and pulldown menus that are along top of figure.
% set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% % Give a name to the title bar.
% set(gcf, 'Name', 'Line segmentation', 'NumberTitle', 'Off')
% 
% 
% 
% [h,p,ci,zval] = ztest(x0_a,0.9,sigmaHat,'Tail','right')
% 
% [h,p] = ztest(x0_a,mean(x0_a)*1.2,std(x0_a),'Alpha',0.01)
% 
% 
% %%
% tmp_a = [];
% nums = (tbl_scores{1}(:,1));
% nums_ids = sort(unique(nums(:)));
% 
% 
% jj = 6;
% for ii = 1:16
%     
%     % score
%     tmp_idx = 1:length(tbl_scores{jj}(:,end));
%     tmp_a(ii,1) = sum(any(ismember(tbl_scores{jj+1}(tmp_idx,1:end-1),nums_ids(ii)),2));
%     %tmp_a{jj} = tbl_scores{jj+1}(tmp_idx,1:end-1);
%     
% end
% array2table([nums_ids tmp_a])
% tmp_sum = tmp_a;
% [bb,iix]=sort(tmp_sum,'descend');
% 
% figure,bar(bb)
% xticks(1:length(bb));
% xticklabels(nums_ids(iix))
% xtickangle(45)
% 
% %%
