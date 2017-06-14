function cyto_overlay = overlay_trace_colours_on_imgs(CellsTable, imgs)

    labelled_by_trace_id_this = zeros(size(imgs,1), size(imgs,2), size(imgs,3), 3);
   
    for t=min(CellsTable.Time):max(CellsTable.Time)

        ObjectsInFrame = CellsTable(CellsTable.Time==t,:); %ResultTable for cells in frame
        boundaries_nuc = ObjectsInFrame.nuc_boundaries; %nuclei boundaries
        boundaries_cyto = ObjectsInFrame.cyto_boundaries; %cytoplasm boundaries
        NumberOfCells = size(boundaries_nuc, 1);
        point_in_time = zeros(size(imgs,1), size(imgs,2), 3);

        
            
            for i=1:NumberOfCells

              Object = ObjectsInFrame(i,:);
              trace = Object.Trace{:};
              trace = strsplit(trace,'-');

              %calculate RGB values
              red = mod(sum(uint8(trace{1})),255);
              green = mod(sum(uint8(trace{2})),255);
              blue = mod(sum(uint8(trace{3})),255);

              point_in_time(boundaries_nuc{i}) = red;
              point_in_time(boundaries_nuc{i}+size(imgs,1)*size(imgs,2)) = green;
              point_in_time(boundaries_nuc{i}+size(imgs,1)*size(imgs,2)*2) = blue;

            end
            
            %fill in perimeter
              point_in_time(:,:,1) = imfill(point_in_time(:,:,1),'holes');
              point_in_time(:,:,2) = imfill(point_in_time(:,:,2),'holes');
              point_in_time(:,:,3) = imfill(point_in_time(:,:,3),'holes');
            
            for i=1:NumberOfCells
                
                Object = ObjectsInFrame(i,:);
              trace = Object.Trace{:};
              trace = strsplit(trace,'-');

              %calculate RGB values
              red = mod(sum(uint8(trace{1})),255);
              green = mod(sum(uint8(trace{2})),255);
              blue = mod(sum(uint8(trace{3})),255);

              point_in_time(boundaries_cyto{i}) = red;
              point_in_time(boundaries_cyto{i}+size(imgs,1)*size(imgs,2)) = green;
              point_in_time(boundaries_cyto{i}+size(imgs,1)*size(imgs,2)*2) = blue;
              point_in_time = uint8(point_in_time);
              imdilate(point_in_time, strel('disk',1));
              imdilate(point_in_time, strel('disk',1));
              imdilate(point_in_time, strel('disk',1));
            end
        

        labelled_by_trace_id_this(:,:,t,:) = point_in_time;

    end
  
    %to view nuc on nuc overlay pass in nuc images instead of cyto
    cyto_rgb = cat(4, imgs, imgs, imgs); 
    cyto_overlay = uint8(labelled_by_trace_id_this./2) ... % add segmented boundries
                 + uint8(cyto_rgb./12);           % add original cyto image
    
    figure; imshow3D(cyto_overlay, [])
  
end 
 
%       %% 1) RGB segmentation overlay BY SIZE (useful for seeing size)
%     boundries_rgb = zeros(size(cyto, 1), size(cyto, 2), size(cyto, 3), 3);
%     %for i = 1:size(cyto, 3)
%     for t=min(CellsTable.Time):max(CellsTable.Time)
%       labelled_by_size_color_fix=labelled_by_size(:,:,i);
%       labelled_by_size_color_fix(1)=min(ResultsTable.CellSize);
%       labelled_by_size_color_fix(2)=COLOR_LIMIT;
%       boundries_rgb(:,:,i,:) = label2rgb(round(labelled_by_size_color_fix),'jet', 'k');
%     end
%     mod(sum(uint8('19oueiueoif')), 255); % calculate a colour value between 0 and 255
%     cyto_rgb = cat(4, cyto, cyto, cyto);
%     cyto_overlay = uint8(boundries_rgb./6) ... % segmented boundries
%                  + uint8(cyto_rgb);           % original cyto
%     % figure('name','cyto_overlay', 'NumberTitle','off');imshow3Dfull(uint8(cyto_overlay),[]);
% end