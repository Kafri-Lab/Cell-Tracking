function imgs = overlay_trace_ids_on_imgs(CellsTable, imgs)
  for t=1:max(CellsTable.Ti)
    ObjectsInFrame = CellsTable(CellsTable.Ti==t,:);
    seed_mask_slice = zeros(size(imgs,1),size(imgs,2));
    for i=1:height(ObjectsInFrame)
      Object = ObjectsInFrame(i,:);
      x = floor(Object.Ycoord);
      y = floor(Object.Xcoord);
      trace = Object.Trace{:};
      TRACEID_MAX_LENGTH = 2;
      trace = trace(1:TRACEID_MAX_LENGTH);
      trace_id_im = text2im(trace); % DEPEDENCY
      trace_id_im = imresize(trace_id_im ,1);
      imgs(x:x-1+size(trace_id_im,1),y:y-1+size(trace_id_im,2),t)=trace_id_im*max(imgs(:))*0.8; % overlay text
    end
  end
  figure; imshow3D(imgs,[]);
end