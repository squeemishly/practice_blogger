require 'rails_helper'

describe Suspension do
  context "relationships" do
    it { should belong_to(:user) }
  end
end
