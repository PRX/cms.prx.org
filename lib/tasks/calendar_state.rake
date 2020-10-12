namespace :production_calendar do

  desc 'Print out a summary of the production calendar'
  task :movement => :environment do
    # For stories to be released in the future (drafts),
    # select the date they were created
    stories = Story.
      draft.
      where(app_version: 'v4').where('released_at >= ?', Time.now).select('*, date(created_at) as created_date').
      where('series_id is not null')

    # group by created date,
    # sum up the num of episodes created on a date
    stories.group_by(&:created_date).each do |date, stories|
      puts "========================================="
      puts "= #{date}"
      stories.group_by(&:series).each do |series, stories|
        puts "    series_id:#{series.id} <#{series.title}>"
        puts "        > created  #{stories.length} draft stories"
        puts "        > spanning #{stories.map(&:released_at).min.to_date} to #{stories.map(&:released_at).max.to_date}"
      end
    end; nil

  end

end
