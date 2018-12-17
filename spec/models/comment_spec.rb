require 'rails_helper'

RSpec.describe Comment, type: :model do
  context "attributes" do
    it { should validate_presence_of(:body) }
  end

  context "relationships" do
    it { should belong_to(:user) }
    it { should belong_to(:article) }
  end
end
