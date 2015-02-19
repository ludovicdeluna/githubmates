require 'rails_helper'

RSpec.describe "repos/edit", :type => :view do
  before(:each) do
    @repo = assign(:repo, Repo.create!(
      :id_github => 1,
      :url => "MyString"
    ))
  end

  it "renders the edit repo form" do
    render

    assert_select "form[action=?][method=?]", repo_path(@repo), "post" do

      assert_select "input#repo_id_github[name=?]", "repo[id_github]"

      assert_select "input#repo_url[name=?]", "repo[url]"
    end
  end
end
