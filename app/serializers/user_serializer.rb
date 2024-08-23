class UserSerializer
  include JSONAPI::Serializer
  attributes :name, :username, :api_key
end