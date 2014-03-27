require 'spec_helper'

describe Occurance do

  it 'should belong to event' do
    event = Event.create(:description => "shower", :location => "bathroom")
    occurance = Occurance.create(:start => "12-12-2012 08", :end => "12-12-2012 09", :event_id => event.id)
    event.occurances[0].start.should eq "12-12-2012 08"
    occurance.event.description.should eq "shower"
  end
end
