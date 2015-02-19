require 'rails_helper'

RSpec.describe "repos/index", :type => :view do
  before(:each) do
    assign(:repos, [
      Repo.create!(
        :id_github => 1,
        :url => "Url"
      ),
      Repo.create!(
        :id_github => 1,
        :url => "Url"
      )
    ])
  end

  it "renders a list of repos" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Url".to_s, :count => 2
  end
end
