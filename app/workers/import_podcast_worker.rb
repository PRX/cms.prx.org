
# For a new podcast
## Must be logged in
  # Select an account in which to import
  # Will create a new series

# Record the creation of the Podcast Import
  # Will keep track of status, and all related entities
  # Allow to see when it is completed
  # Will also allow further imports to pick up more feed entries

# Start by pulling the feed
  # Make sure you have the podcast, and that it is valid rss

# Create a cms.Series entry to import into
  # Use whatever defaults come from the podcast channel: title, etc.

# Create a related feeder.Feed and distribution

# Per podcast entry, create a cms.Story, which will also create a feeder.FeedEntry entry
  # When creating the story, include the URL to the audio

# Override data in the feeder.FeedEntry, such as the original guid
