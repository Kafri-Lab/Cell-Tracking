function overlay = overlay_cyto_and_nuc_on_cyto(CellsTable, imgs)

    labelled_by_trace = zeros(size(imgs,1), size(imgs,2), size(imgs,3), 3);
   
    for t=min(CellsTable.Time):max(CellsTable.Time)
        
        ObjectsInFrame = CellsTable(CellsTable.Time==t,:); %ResultTable for cells in frame
        boundaries_nuc = ObjectsInFrame.nuc_boundaries; %nuclei boundaries
        boundaries_cyto = ObjectsInFrame.cyto_boundaries; %cytoplasm boundaries
        NumberOfCells = size(boundaries_nuc, 1);
        point_in_time = zeros(size(imgs,1), size(imgs,2), 3);

        %colour nucleus
        for i=1:NumberOfCells
                
          Object = ObjectsInFrame(i,:);
          trace = Object.Trace{:};
          trace = strsplit(trace,'-');

          %calculate RGB values
          red = mod(sum(uint8(trace{1})),255);
          green = mod(sum(uint8(trace{2})),255);
          blue = mod(sum(uint8(trace{3})),255);

          %apply colours to nucleus
          point_in_time(boundaries_nuc{i}) = red;
          point_in_time(boundaries_nuc{i}+size(imgs,1)*size(imgs,2)) = green;
          point_in_time(boundaries_nuc{i}+size(imgs,1)*size(imgs,2)*2) = blue;

        end
            
        %checks for dulls colours on nucleus
        hsv = rgb2hsv(point_in_time);
        luminance = hsv(:,:,3);
        for i=1:NumberOfCells

            boundaries = boundaries_nuc{i};
            if luminance(boundaries(1)) > 0 && luminance(boundaries(1)) < 77
                luminance(boundaries_nuc{i}) = 150;
            end

        end 
        hsv(:,:,3) = luminance;
        point_in_time = hsv2rgb(hsv);

        %fill in perimeter of nucleus
        point_in_time(:,:,1) = imfill(point_in_time(:,:,1),'holes');
        point_in_time(:,:,2) = imfill(point_in_time(:,:,2),'holes');
        point_in_time(:,:,3) = imfill(point_in_time(:,:,3),'holes');

        
        
        %colour cyto
        for i=1:NumberOfCells

          Object = ObjectsInFrame(i,:);
          trace = Object.Trace{:};
          trace = strsplit(trace,'-');

          %calculate RGB values
          red = mod(sum(uint8(trace{1})),255);
          green = mod(sum(uint8(trace{2})),255);
          blue = mod(sum(uint8(trace{3})),255);

          %apply colours to cyto
          point_in_time(boundaries_cyto{i}) = red;
          point_in_time(boundaries_cyto{i}+size(imgs,1)*size(imgs,2)) = green;
          point_in_time(boundaries_cyto{i}+size(imgs,1)*size(imgs,2)*2) = blue;

        end

        %check for dull colours on cyto
        hsv = rgb2hsv(point_in_time);
        luminance = hsv(:,:,3);
        for i=1:NumberOfCells
            boundaries = boundaries_cyto{i};
            if luminance(boundaries(1)) > 0 && luminance(boundaries(1)) < 77
               luminance(boundaries_cyto{i}) = 150;
            end
        end 
        hsv(:,:,3) = luminance;
        point_in_time = hsv2rgb(hsv);

        point_in_time = uint8(point_in_time);
        labelled_by_trace(:,:,t,:) = point_in_time;
    end
  
    rgb = cat(4, imgs, imgs, imgs); 
    overlay = uint8(labelled_by_trace./2) ... % add segmented boundries
                 + uint8(rgb./12);           % add original cyto image
    
    figure; imshow3D(overlay, [])
   
end 
 