function uuid = uuid()
  uuid = java.util.UUID.randomUUID;
  uuid = sprintf('%s', uuid.toString);
end
