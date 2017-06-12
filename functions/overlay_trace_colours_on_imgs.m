function imgs = overlay_trace_ids_on_imgs(CellsTable, imgs)
  x_offset = 0; % used if image is cropped on a region of interest for debugging
  y_offset = 0; % used if image is cropped on a region of interest for debugging
  count=1;
  for t=min(CellsTable.Time):max(CellsTable.Time)
    ObjectsInFrame = CellsTable(CellsTable.Time==t,:);
    for i=1:height(ObjectsInFrame)
      Object = ObjectsInFrame(i,:);
      Ycoord = Object.Centroid(1,2);
      Xcoord = Object.Centroid(1,1);
      x = floor(Ycoord-y_offset);
      y = floor(Xcoord-x_offset);
      trace = Object.Trace{:};
      TRACEID_MAX_LENGTH = 3;
      trace = trace(1:TRACEID_MAX_LENGTH);
      trace_id_im = text2im(trace); % DEPEDENCY
      trace_id_im = imresize(trace_id_im ,1);
      imgs(x:x-1+size(trace_id_im,1),y:y-1+size(trace_id_im,2),count)=trace_id_im*max(imgs(:))*0.8; % overlay text
    end
    count = count+1;
  end
  figure; imshow3D(imgs,[]);
  
  
  
  
      %% 1) RGB segmentation overlay BY SIZE (useful for seeing size)
    boundries_rgb = zeros(size(cyto, 1), size(cyto, 2), size(cyto, 3), 3);
    %for i = 1:size(cyto, 3)
    for t=min(CellsTable.Time):max(CellsTable.Time)
      labelled_by_size_color_fix=labelled_by_size(:,:,i);
      labelled_by_size_color_fix(1)=min(ResultsTable.CellSize);
      labelled_by_size_color_fix(2)=COLOR_LIMIT;
      boundries_rgb(:,:,i,:) = label2rgb(round(labelled_by_size_color_fix),'jet', 'k');
    end
    mod(sum(uint8('19oueiueoif')), 255); % calculate a colour value between 0 and 255
    cyto_rgb = cat(4, cyto, cyto, cyto);
    cyto_overlay = uint8(boundries_rgb./6) ... % segmented boundries
                 + uint8(cyto_rgb);           % original cyto
    % figure('name','cyto_overlay', 'NumberTitle','off');imshow3Dfull(uint8(cyto_overlay),[]);
end