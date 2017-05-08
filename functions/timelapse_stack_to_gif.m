
%% SAVE GIF TO DISK
date_str = datestr(now,'yyyymmddTHHMMSS');
filename = [date_str '.gif'];
for t=1:max(SubsetTable.Ti)
    if t==1;
      imwrite(labelled_nuc(:,:,t)./12,filename,'gif', 'DelayTime',0.5, 'Loopcount',inf);
    else
      imwrite(labelled_nuc(:,:,t)./12,filename,'gif', 'DelayTime',0.5, 'WriteMode','append');
    end
end