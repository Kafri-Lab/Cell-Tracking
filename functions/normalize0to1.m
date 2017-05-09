function normalized = normalize0to1(mat)
  if length(mat)==1
    % one sample can't be normalized
    normalized = mat;
  else
    normalized = (mat-min(mat(:)))./(max(mat(:))-min(mat(:)));
  end
end
