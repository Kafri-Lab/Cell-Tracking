function normalized = normalize0to1(mat)
  normalized = (mat-min(mat(:)))./(max(mat(:))-min(mat(:)))
end
