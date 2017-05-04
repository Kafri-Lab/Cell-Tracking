function uuid_array = uuid_array(size)
  uuid_array = {};
  for i=1:size
    uuid_array{i} = uuid();
  end
end