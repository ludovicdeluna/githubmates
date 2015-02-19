json.user do
  json.id          @owner.id_github
  json.login       @owner.login
  json.url_avatar  @owner.avatar
  json.cache_date  @owner.updated_at.strftime("%d/%m/%Y")
  json.projects    @projects do |project|
    json.path           project.path
  end
end

