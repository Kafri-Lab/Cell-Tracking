
%% Overlay on cyto
labelled_cyto = cyto;
for t=1:max(SubsetTable.Ti)
  ObjectsInFrame = SubsetTable(SubsetTable.Ti==t,:);
  seed_mask_slice = zeros(size(cyto,1),size(cyto,2));
  for i=1:height(ObjectsInFrame)
    Object = ObjectsInFrame(i,:);
    x = floor(Object.Ycoord);
    y = floor(Object.Xcoord);
    trace_id=0;
    trace_id_im = text2im(num2str(Object.TraceID));
    trace_id_im = imresize(trace_id_im ,1);
    labelled_cyto(x:x-1+size(trace_id_im,1),y:y-1+size(trace_id_im,2),t)=trace_id_im*max(cyto(:))*0.8; % overlay text
  end
end
figure; imshow3D(labelled_cyto,[]);

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