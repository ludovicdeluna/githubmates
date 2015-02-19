require 'rails_helper'

RSpec.describe "repos/show", :type => :view do
  before(:each) do
    @repo = assign(:repo, Repo.create!(
      :id_github => 1,
      :url => "Url"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Url/)
  end
end
