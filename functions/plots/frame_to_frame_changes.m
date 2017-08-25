function func(GivenTable)

  LinkedCells = table(); % Each row in this table will store all cells that are linked across two timepoints, and all data at both timepoints. Columns are appended with _T1 and _T2 to differentiate between timepoints.
  for t=min(GivenTable.Time):max(GivenTable.Time)-1
    T1 = GivenTable(GivenTable.Time==t,:);
    T2 = GivenTable(GivenTable.Time==t+1,:);
    % find cells in T1 and T2 that have the same Trace and append to table
    if height(LinkedCells) == 0
      LinkedCells = innerjoin(T1,T2,'Keys','Trace');
    else
      % append to table
      LinkedCells = [LinkedCells; innerjoin(T1,T2,'Keys','Trace')];
    end
  end


  %% NUCLEAR AREA
  nuc_size_growth = LinkedCells.NArea_T2 - LinkedCells.NArea_T1;

  figure
  ksdensity_resolution = 500;
  pts = linspace(prctile(nuc_size_growth, 0), prctile(nuc_size_growth, 100), ksdensity_resolution);
  [f,xi] = ksdensity(nuc_size_growth,pts);
  h=plot(xi,f,'white');
  set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % disable legend
  hold on;
  avg = median(nuc_size_growth);
  line([avg avg], ylim,'Color','red');
  title('Nuclear Area Growth (Frame to Frame)','color','white');
  xlabel('Amount of growth in pixels');
  ylabel('Frequency');
  legend_handle = legend({'Median'});

  % dark theme
  set(gca,'Color',[0 0 0]);
  set(gcf,'Color',[0 0 0]);
  set(gca,'ycolor','w');
  set(gca,'xcolor','w');
  legend_handle.Color = 'black';
  legend_handle.TextColor = 'white';
  legend_handle.EdgeColor = 'white';
  legend_handle.LineWidth = 1;
  export_fig('area.png','-m4')


  %% CENTROID MOTION (ksdensity)
  % Tranlation distances between T and T+1
  X_translation = LinkedCells.Centroid_T2(:,1)-LinkedCells.Centroid_T1(:,1);
  Y_translation = LinkedCells.Centroid_T2(:,2)-LinkedCells.Centroid_T1(:,2);
  [theta,rho] = cart2pol(X_translation,Y_translation);
  motion = rho;

  figure
  ksdensity_resolution = 500;
  pts = linspace(prctile(motion, 0), prctile(motion, 99), ksdensity_resolution);
  [f,xi] = ksdensity(motion,pts);
  h=plot(xi,f,'white');
  set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % disable legend
  hold on;
  avg = median(motion);
  line([avg avg], ylim,'Color','red');
  title('Cell Motion (Frame to Frame)','color','white');
  xlabel('Amount of motion in pixels');
  ylabel('Frequency');
  legend_handle = legend({'Median'});

  % dark theme
  set(gca,'Color',[0 0 0]);
  set(gcf,'Color',[0 0 0]);
  set(gca,'ycolor','w');
  set(gca,'xcolor','w');
  legend_handle.Color = 'black';
  legend_handle.TextColor = 'white';
  legend_handle.EdgeColor = 'white';
  legend_handle.LineWidth = 1;

  export_fig('motion_ksdensity.png','-m4')
  

  %% CENTROID MOTION (scatter plot)
  % Tranlation distances between T and T+1
  X_translation = LinkedCells.Centroid_T2(:,1)-LinkedCells.Centroid_T1(:,1);
  Y_translation = LinkedCells.Centroid_T2(:,2)-LinkedCells.Centroid_T1(:,2);

  figure
  h=scatter(X_translation,Y_translation,'white');
  set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % disable legend
  hold on
  % Add white crosshairs at 0,0
  h=line([0 0], xlim,'Color','white');
  set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % disable legend
  h=line(ylim, [0 0],'Color','white');
  set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % disable legend
  % Add median
  h=scatter(median(X_translation),median(Y_translation),400,'red','x','LineWidth',3);
  title('Cell Motion (Frame to Frame)','color','white');
  xlabel('Amount of motion in pixels');
  ylabel('Amount of motion in pixels');
  legend_handle = legend({'Median'});
  xlim([-100 100]);
  ylim([-100 100]);

  % dark theme
  set(gca,'Color',[0 0 0]);
  set(gcf,'Color',[0 0 0]);
  set(gca,'ycolor','w');
  set(gca,'xcolor','w');
  legend_handle.Color = 'black';
  legend_handle.TextColor = 'white';
  legend_handle.EdgeColor = 'white';
  legend_handle.LineWidth = 1;
  legend_handle.FontSize = 12;
  export_fig('motion_scatter.png','-m4')

end