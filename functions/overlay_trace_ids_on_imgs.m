function imgs = overlay_trace_ids_on_imgs(CellsTable, imgs)
  x_offset = 0; % used if image is cropped on a region of interest for debugging
  y_offset = 0; % used if image is cropped on a region of interest for debugging
  count=1;
  for t=min(CellsTable.Ti):max(CellsTable.Ti)
    ObjectsInFrame = CellsTable(CellsTable.Ti==t,:);
    seed_mask_slice = zeros(size(imgs,1),size(imgs,2));
    for i=1:height(ObjectsInFrame)
      Object = ObjectsInFrame(i,:);
      x = floor(Object.Ycoord-y_offset);
      y = floor(Object.Xcoord-x_offset);
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
end