require 'rails_helper'

RSpec.describe "repos/new", :type => :view do
  before(:each) do
    assign(:repo, Repo.new(
      :id_github => 1,
      :url => "MyString"
    ))
  end

  it "renders new repo form" do
    render

    assert_select "form[action=?][method=?]", repos_path, "post" do

      assert_select "input#repo_id_github[name=?]", "repo[id_github]"

      assert_select "input#repo_url[name=?]", "repo[url]"
    end
  end
end
