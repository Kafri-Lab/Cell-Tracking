x = [1];
y = [2;3];
distances = squareform(pdist([x;y]))
distances=distances(length(x)+1:end,1:length(x))

x = [1;2];
y = [3;4;5];
distances = squareform(pdist([x;y]))
distances2=distances(length(x)+1:end,1:length(x))

x = [1;2];
y = [3;4;5;6];
distances = squareform(pdist([x;y]))
distances2=distances(length(x)+1:end,1:length(x))

x = [1;2;3];
y = [4;5;6;7;8;9];
distances = squareform(pdist([x;y]))
distances2=distances(length(x)+1:end,1:length(x))

x = [2;3];
y = [1];
distances = squareform(pdist([x;y]))
distances=distances(length(x)+1:end,1:length(x))

x = [3;4;5];
y = [1;2];
distances = squareform(pdist([x;y]))
distances2=distances(length(x)+1:end,1:length(x))
