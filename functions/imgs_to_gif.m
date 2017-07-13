function imgs_to_gif(imgs)
  date_str = datestr(now,'yyyymmddTHHMMSS');
  filename = [date_str '.gif'];
  for t=1:size(imgs,3)
      if t==1;
        imwrite(imgs(:,:,t,:)./12,filename,'gif', 'DelayTime',0.5, 'Loopcount',inf);
      else
        imwrite(imgs(:,:,t,:)./12,filename,'gif', 'DelayTime',0.5, 'WriteMode','append');
      end
  end
end

