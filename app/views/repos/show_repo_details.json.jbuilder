json.repo do
  json.id          @repo.id_github
  json.path        @repo.path
  json.cache_date  @repo.updated_at.strftime("%d/%m/%Y")
  json.users       @repo.cache_users do |user|
    json.login          user.login
    json.fullname       user.fullname
    json.id             user.id_github
    json.url_avatar     user.avatar
    json.geocode        user.latlng
    json.location       user.location
    json.cache_date     user.updated_at.strftime("%d/%m/%Y")
    json.timestamp      user.get_timestamp
  end
end
