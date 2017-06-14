function images_to_gif(imgs)
  date_str = datestr(now,'yyyymmddTHHMMSS');
  filename = [date_str '.gif'];
  for t=1:size(imgs,3)
      [imind,cm] = rgb2ind(squeeze(imgs(:,:,t,:)),256);
        if t == 1;
          imwrite(imind,cm,filename,'gif', 'DelayTime',0.1, 'Loopcount',inf);
        else
           imwrite(imind,cm,filename,'gif', 'DelayTime',0.1, 'WriteMode','append');
        end
      
      
%       if t==1;
%         imwrite(imgs(:,:,t,:)./12,filename,'gif', 'DelayTime',0.5, 'Loopcount',inf);
%       else
%         imwrite(imgs(:,:,t,:)./12,filename,'gif', 'DelayTime',0.5, 'WriteMode','append');
%       end
  end
end

