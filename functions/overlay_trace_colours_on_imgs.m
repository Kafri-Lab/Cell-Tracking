function cyto_overlay = overlay_trace_colours_on_imgs(CellsTable, imgs)

    labelled_by_trace_id_this = zeros(size(imgs,1), size(imgs,2), size(imgs,3), 3);
    %labelled_by_trace_id_this = zeros(size(imgs,1), size(imgs,2), 3);
   
    for t=min(CellsTable.Time):max(CellsTable.Time)

        ObjectsInFrame = CellsTable(CellsTable.Time==t,:); %ResultTable for cells in frame
        boundaries_nuc = ObjectsInFrame.nuc_boundaries; %nuclei boundaries
        boundaries_cyto = ObjectsInFrame.cyto_boundaries; %cytoplasm boundaries
        NumberOfCells = size(boundaries_nuc, 1);
        point_in_time = zeros(size(imgs,1), size(imgs,2), 3);
        %hsv_imgs = zeros(size(imgs,1),size(imgs,2),max(CellsTable.Time));

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
              
              %check for dull colour
              hsv = rgb2hsv(point_in_time);
              luminance = hsv(:,:,3);
              boundaries = boundaries_nuc{i};
              if luminance(boundaries(1)) > 0 & luminance(boundaries(1)) < 77
                  luminance(boundaries_nuc{i}) = 150;
                  hsv(:,:,3) = luminance;
                  point_in_time = hsv2rgb(hsv);
              end

            end
            
            %fill in perimeter
              point_in_time(:,:,1) = imfill(point_in_time(:,:,1),'holes');
              point_in_time(:,:,2) = imfill(point_in_time(:,:,2),'holes');
              point_in_time(:,:,3) = imfill(point_in_time(:,:,3),'holes');
            
              hsv(:,:,3) = imfill(hsv(:,:,3),'holes');
%             for i=1:NumberOfCells
%                 
%               Object = ObjectsInFrame(i,:);
%               trace = Object.Trace{:};
%               trace = strsplit(trace,'-');
% 
%               %calculate RGB values
%               red = mod(sum(uint8(trace{1})),255);
%               green = mod(sum(uint8(trace{2})),255);
%               blue = mod(sum(uint8(trace{3})),255);
% 
%               point_in_time(boundaries_cyto{i}) = red;
%               point_in_time(boundaries_cyto{i}+size(imgs,1)*size(imgs,2)) = green;
%               point_in_time(boundaries_cyto{i}+size(imgs,1)*size(imgs,2)*2) = blue;
%               
%               %check for dull colour
%               hsv = rgb2hsv(point_in_time);
%               luminance = hsv(:,:,3);
%                boundaries = boundaries_cyto{i};
%               if luminance(boundaries(1)) > 0 & luminance(boundaries(1)) < 77
%                   luminance(boundaries_cyto{i}) = 77;
%                   hsv(:,:,3) = luminance;
%                   point_in_time = hsv2rgb(hsv);
%               end
%               
%               point_in_time = uint8(point_in_time);
%               
% %               imdilate(point_in_time, strel('disk',1));
% %               imdilate(point_in_time, strel('disk',1));
% %               imdilate(point_in_time, strel('disk',1));
%             end
        luminance = uint8(luminance);
        figure; imshow(hsv(:,:,3),[])
        point_in_time = uint8(point_in_time);
        labelled_by_trace_id_this(:,:,t,:) = point_in_time;
        %labelled_by_trace_id_this(:,:,:) = point_in_time;
        
    end
  
    %to view nuc on nuc overlay pass in nuc images instead of cyto
    cyto_rgb = cat(4, imgs, imgs, imgs); 
    %cyto_rgb = cat(3, imgs, imgs, imgs);
    cyto_overlay = uint8(labelled_by_trace_id_this./2) ... % add segmented boundries
                 + uint8(cyto_rgb./12);           % add original cyto image
    
    figure; imshow3D(cyto_overlay, [])
    %figure;imshow3D(hsv_imgs,[])
    %figure; imshow(cyto_overlay, [])
    %figure; imshow3D(uint8(labelled_by_trace_id_this./2), []);
  
end 
 