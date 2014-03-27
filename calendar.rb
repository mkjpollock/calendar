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
    puts "\nPlease press 'e' for the event menu"
    puts "Press 't' to enter a to-do item"
    puts "Press 'x' to exit"
    choice = gets.chomp.downcase
    case choice
    when 'e'
      event_menu
    when 't'
      to_do_menu
    when 'x'
      puts "Goodbye!"
    end
  end
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
    puts "Press 'M' to return to main menu"
    choice = gets.chomp.upcase
    case choice
    when 'A'
      add_event
    when 'E'
      edit_event
    when 'V'
      view_event_menu
    when 'D'
      delete_event
    when 'M'
      puts "Returning to main menu...\n\n"
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
  occurances.each do |occurance|
    puts "#{occurance.event.description} #{occurance.start.strftime("%l:%M%p %m/%d/%Y")}"
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
    event_menu
  else
    puts "Invalid input, sucka!"
  end
end

# def view_today_events(start, finish)
  # occurances = Occurance.where('start > ? AND start < ?', Time.now.beginning_of_day, Time.now.end_of_day)
  # puts "\nToday's events"
  # occurances.each do |occurance|
  #   puts "#{occurance.event.description} #{occurance.start.strftime("%l:%M%p %m/%d/%Y")}"
  # end
  # puts "Press 'P' to view events from previous day"
  # puts "Press 'N' to view events for the next day"
  # user_input = gets.chomp.upcase
  # case user_input
  # when 'P'
  # occurances = Occurance.where('start > ? AND start < ?', Time.now.beginning_of_day, Time.now.end_of_day)
  # puts "\nToday's events"
  # occurances.each do |occurance|
  #   puts "#{occurance.event.description} #{occurance.start.strftime("%l:%M%p %m/%d/%Y")}"
  # end
# end

# def view_week_events
#   occurances = Occurance.where('start > ? AND start < ?', Time.now.beginning_of_week, Time.now.end_of_week)
#   puts "\nEvents for the week of #{Time.now.beginning_of_week.strftime('%m/%d/%Y')} - #{Time.now.end_of_week.strftime('%m/%d/%Y')}"
#   occurances.each do |occurance|
#     puts "#{occurance.event.description} #{occurance.start.strftime("%l:%M%p %m/%d/%Y")}"
#   end
# end

# def view_month_events
#   occurances = Occurance.where('start > ? AND start < ?', Time.now.beginning_of_month, Time.now.end_of_month)
#   puts "\nEvents for #{Time.now.beginning_of_month.strftime('%B')}"
#   occurances.each do |occurance|
#     puts "#{occurance.event.description} #{occurance.start.strftime("%l:%M%p %m/%d/%Y")}"
#   end
# end

def view_all_future_events
  occurances = Occurance.where('start > ?', Time.now)
  puts "\nAll future events"
  occurances.each do |occurance|
    puts "#{occurance.event.description} #{occurance.start.strftime("%l:%M%p %m/%d/%Y")}"
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
  puts "Please enter the start date of your event as YYYY-MM-DD HH:MM"
  start_input = gets.chomp
  puts "Please enter the end date of your event YYYY-MM-DD HH:MM"
  end_input = gets.chomp
  @event = Event.create(:description => description_input, :location => location_input)
  @occurance = Occurance.create(:start => start_input, :end => end_input, :event_id => @event.id)
  puts "\nCongratulations! You have successfully added the event: #{@event.description}"
  puts "At the following time: #{@occurance.start.strftime("%l:%M%p %m/%d/%Y")} until #{@occurance.end.strftime("%l:%M%p %m/%d/%Y")}"
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

main_menu
