require 'textacular/tasks'
require 'bundler/setup'
Bundler.require(:default)

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }

database_configurations = YAML::load(File.open('./db/config.yml'))
development_configuration = database_configurations['development']
ActiveRecord::Base.establish_connection(development_configuration)

def main_menu
  choice = nil
  until choice == 'x'
    puts "\nMAIN MENU"
    puts "============"
    puts "\nPress 'E' for the event menu"
    puts "Press 'T' for the to-do menu"
    puts "Press 'S' to search"
    puts "Press 'X' to exit"
    choice = gets.chomp.downcase
    case choice
    when 'e'
      event_menu
    when 't'
      to_do_menu
    when 's'
      search
    when 'x'
      puts "Goodbye!"
    end
  end
end

def search
  puts "Enter your search term(s):"
  search = gets.chomp
  events = Event.basic_search(:description => search)
  puts "\nFound #{events.count} event(s):"
  events.each_with_index do |event, index|
    puts "#{index + 1}. #{event.description}"
    event.notes.each { |note| puts "- #{note.description}" }
  end
  to_dos = To_do.basic_search(:description => search)
  puts "\nFound #{to_dos.count} to-do(s):"
  to_dos.each_with_index do |to_do, index|
    puts "#{index + 1}. #{to_do.description}"
    to_do.notes.each { |note| puts "- #{note.description}" }
  end
end

def to_do_menu
  system "clear"
  puts "TO DO MENU"
  puts "============"
  puts "\nPress 'A' to add a new to-do item"
  puts "Press 'V' to view all to-do items"
  puts "Press 'N' to add a note to a to-do item"
  puts "Press 'M' to go to main menu"
  user_input = gets.chomp.upcase
  case user_input
  when 'A'
    add_to_do
  when 'V'
    view_to_do
  when 'N'
    note_to_do
  when 'M'
    main_menu
  else
    puts "Invalid input"
  end
end

def add_to_do
  puts "\nPlease enter the description of your to-do item"
  description_input = gets.chomp
  to_do = To_do.create(:description => description_input)
  puts "\nCongratulations! You have successfully added the to-do item: #{to_do.description}"
end

def view_to_do
  puts "\nHere are your to-dos:"
  To_do.all.each_with_index do |to_do, index|
    puts "\n#{index + 1}. #{to_do.description}"
    to_do.notes.each { |note| puts "- #{note.description}"}
  end
end

def note_to_do
  puts "Which to_do would you like attach a note to?"
  to_do_description = gets.chomp
  to_do = To_do.find_by :description => to_do_description
  puts "Type your note here:"
  note_description = gets.chomp
  note = Note.create(:description => note_description, :notable_id => to_do.id, :notable_type => "To_do")
  puts "Note '#{to_do.notes.last.description}' added to '#{note.notable.description}'"
end

def event_menu
  system "clear"
  choice = nil
  until choice == 'M'
    puts "\nEVENT MENU"
    puts "============"
    puts "Press 'A' to add an event"
    puts "Press 'E' to edit an event"
    puts "Press 'D' to delete an event"
    puts "Press 'V' to view an event"
    puts "Press 'N' to attach a note to an event"
    puts "Press 'M' to return to main menu"
    choice = gets.chomp.upcase
    case choice
    when 'A'
      add_event
    when 'E'
      edit_event
    when 'D'
      delete_event
    when 'V'
      view_event_menu
    when 'N'
      add_note_to_event
    when 'M'
      puts "Returning to main menu...\n\n"
    else
      puts "Invalid selection, jerk!"
    end
  end
end

def view_event_menu
  puts "\nVIEW EVENT MENU"
  puts "==========="
  puts "\nPress 'ALL' if you would like to view all future events"
  puts "Press 'DAY' if you would like to view all events for the current day"
  puts "Press 'WEEK' if you would like to view all events for this week"
  puts "Press 'MONTH' if you would like to view all events for this month"
  puts "Press 'X' to exit to the event menu"
  user_input = gets.chomp.downcase
  case user_input
  when 'all'
    time_loop(Time.now, nil, user_input)
  when 'day'
    time_loop(Time.now, Time.now, user_input)
  when 'week'
    time_loop(Time.now.beginning_of_week, Time.now.end_of_week, user_input)
  when 'month'
    time_loop(Time.now.beginning_of_month, Time.now.end_of_month, user_input)
  when 'x'
    puts "\nReturning to event menu"
  else
    puts "Invalid input"
  end
end

def time_loop(start, finish, period)
  if period == 'all'
    occurances = Occurance.where('start > ?', start)
    puts "\nAll future events"
  else
    occurances = Occurance.where('start > ? AND start < ?', start.send("beginning_of_#{period}".to_sym), finish.send("end_of_#{period}".to_sym))
    puts "\nEvents for #{start.strftime('%m/%d/%Y')} - #{finish.strftime('%m/%d/%Y')}"
  end
  occurances.each_with_index do |occurance, index|
    puts "\n#{index + 1}. #{occurance.event.description} #{occurance.start.strftime("%l:%M%p %m/%d/%Y")}"
    occurance.event.notes.each { |note| puts "- #{note.description}" }
  end
  next_previous_menu(start, finish, period)
end

def next_previous_menu(start, finish, period)
  puts "Press 'P' to view events from previous #{period}"
  puts "Press 'N' to view events for the next #{period}"
  puts "Press 'V' to return to view event menu"
  user_input = gets.chomp.upcase
  case user_input
  when 'P'
    if period == 'day'
      time_loop(start.beginning_of_day.yesterday, finish.end_of_day.yesterday, period)
    else
      time_loop(start.send("last_#{period}".to_sym).send("beginning_of_#{period}".to_sym), finish.send("last_#{period}".to_sym).send("end_of_#{period}".to_sym), period)
    end
  when 'N'
    if period == 'day'
      time_loop(start.beginning_of_day.tomorrow, finish.end_of_day.tomorrow, period)
    else
      time_loop(start.send("next_#{period}".to_sym).send("beginning_of_#{period}".to_sym), finish.send("next_#{period}".to_sym).send("end_of_#{period}".to_sym), period)
    end
  when 'V'
    puts "Returning to event menu..."
  else
    puts "Invalid input, sucka!"
  end
end

def delete_event
  puts "\nPlease enter the description of the event you would like to delete"
  description_input = gets.chomp
  event = Event.find_by :description => description_input
  occurance = Occurance.find_by :event_id => event.id
  puts "#{event.description} has been destroyed!!"
  occurance.destroy
  event.destroy
end

def add_event
  puts "\nPlease enter the description of your event"
  description_input = gets.chomp
  puts "Please enter the location of your event"
  location_input = gets.chomp
  puts "Please enter the start date of your event (e.g. April 21, 1992)"
  start_input = gets.chomp
  puts "Please enter the end date of your event (e.g. April 21, 1992)"
  end_input = gets.chomp
  @event = Event.create(:description => description_input, :location => location_input)
  occurance = Occurance.new(:start => start_input, :end => end_input, :event_id => @event.id)
  if occurance.save
    puts "\nCongratulations! You have successfully added the event: #{@event.description}"
    puts "At the following time: #{occurance.start.strftime("%l:%M%p %m/%d/%Y")} until #{occurance.end.strftime("%l:%M%p %m/%d/%Y")}"
  else
    puts "Try again, bum!"
    add_event
  end
  repeat_menu(occurance)
end

def repeat_menu(occurance)
  puts "\nHow often would you like this event to repeat?"
  puts "Enter 'daily', 'weekly', 'monthly', or 'never'"
  user_input = gets.chomp.downcase
  if user_input != 'never'
    puts "\nHow many times would you like this event to repeat?"
    repeat_times = gets.chomp
  end
  case user_input
  when 'daily'
    repeat_daily(occurance.start, occurance.end, repeat_times.to_i)
  when 'weekly'
    repeat_weekly(occurance.start, occurance.end, repeat_times.to_i)
  when 'monthly'
    repeat_monthly(occurance.start, occurance.end, repeat_times.to_i)
  when 'never'
  else
    puts "Invalid selection, monkey-brain!"
  end
  puts "Events entered!"
end

def repeat_daily(start, finish, length)
  if length != 0
    occurance = Occurance.create(:start => start.tomorrow, :end => finish.tomorrow, :event_id => @event.id)
    repeat_daily(occurance.start, occurance.end, length -= 1)
  end
end

def repeat_weekly(start, finish, length)
  if length != 0
    occurance = Occurance.create(:start => start + 604_800, :end => finish + 604_800, :event_id => @event.id)
    repeat_weekly(occurance.start, occurance.end, length -= 1)
  end
end

def repeat_monthly(start, finish, length)
  if length != 0
    occurance = Occurance.create(:start => start + 2_628_000, :end => finish + 2_628_000, :event_id => @event.id)
    repeat_monthly(occurance.start, occurance.end, length -= 1)
  end
  # Doesn't skip to the next month exactly...
end

def edit_event
  puts "Which event would you like edit?"
  description = gets.chomp
  event = Event.find_by :description => description
  #FOR MULTIPLES, USE WHERE THEN LOOP THROUGH
  occurance = Occurance.find_by :event_id => event.id
  puts "Enter the updated event description"
  description_input = gets.chomp
  puts "Enter the updated event location"
  location_input = gets.chomp
  puts "Enter the updated event start (format YYYY-MM-DD HH:MM)"
  start_input = gets.chomp
  puts "Enter the updated event end (format YYYY-MM-DD HH:MM)"
  end_input = gets.chomp
  event.update(:description => description_input, :location => location_input)
  occurance.update(:start => start_input, :end => end_input)
  puts "Event #{event.description} at #{event.location} Updated"
  puts "New time: #{occurance.start.strftime("%l:%M%p %m/%d/%Y")} - #{occurance.end.strftime("%l:%M%p %m/%d/%Y")}"
end

def add_note_to_event
  puts "Which event would you like attach a note to?"
  event_description = gets.chomp
  event = Event.find_by :description => event_description
  puts "Type your note here:"
  note_description = gets.chomp
  note = Note.create(:description => note_description, :notable_id => event.id, :notable_type => "Event")
  puts "Note '#{event.notes.last.description}' added to '#{note.notable.description}'"
end

main_menu
