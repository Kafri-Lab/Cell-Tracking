
traces=SubsetTable.Trace;
% count each trace id
values=unique(traces,'stable');
counts=cellfun(@(x) sum(ismember(traces,x)),values,'un',0);
counts=cell2mat(counts);
% find trace ids with maximum length
max_len=max(counts);
longest=find(counts==max_len);

% Cell area trace plot
figure;
hold on;
set(gca,'Color',[0 0 0]);
set(gcf,'Color',[0 0 0]);
set(gca,'ycolor','w');
set(gca,'xcolor','w');
% legend_handle.Color = 'black';
% legend_handle.TextColor = 'white';
% legend_handle.EdgeColor = 'white';
% legend_handle.LineWidth = 1;
ylim([300 1300])
xlabel('Timepoint')
ylabel('Nuclear Area')
legend_values = {};
for i=1:length(longest)
  long_traceid =  values(longest(i));
  LongLivedCell = SubsetTable(strcmp(SubsetTable.Trace, long_traceid),:);
  plot(LongLivedCell.NArea(:,1))
  i
  longest(i)
  export_fig('frame.png','-m4');

  % Capture the plot as an image 
  frame = imread('frame.png');
  [imind,cm] = rgb2ind(frame,256); 
  % Write to the GIF File 
  if i == 1 
      imwrite(imind,cm,'traces.gif','gif', 'Loopcount',inf,'DelayTime',0.8); 
  else 
      imwrite(imind,cm,'traces.gif','gif','WriteMode','append','DelayTime',0.8); 
  end
  long_traceid=char(long_traceid);
  legend_values{i}=long_traceid(1:5);
end
legend_handle=legend(legend_values);
legend_handle.Color = 'black';
legend_handle.TextColor = 'white';
legend_handle.EdgeColor = 'white';
legend_handle.LineWidth = 1;

coloured_nuc = overlay_nuc_perim_and_nuc(SubsetTable, nuc);



% Single Cell Image Montage
for i=1:length(longest)
  long_traceid =  values(longest(i));
  LongLivedCell = SubsetTable(strcmp(SubsetTable.Trace, long_traceid),:);
  figure;
  res = 40; % resolution to create single cell montage at (each subimage)
  single_cell_montage = uint8(zeros(res*2,res*2,max_len,3));
  for n=1:max_len
    y = floor(LongLivedCell.Centroid(n,1));
    x = floor(LongLivedCell.Centroid(n,2));
    single_cell_montage(:,:,n,:) = coloured_nuc(x-res:x+res-1, y-res:y+res-1, n,:);
  end
  single_cell_montage = permute(single_cell_montage, [1 2 4 3]);
  montage(single_cell_montage,'DisplayRange',[]);
  export_fig([char(long_traceid) '.png'],'-m4');
%  pause
end