defmodule StandupBot.Messages do

  def init(hour, minute) do
    "Hey :wave: I'm back online!\nStandup at #{hour}:#{minute}.\nUse `!standup help` to see supported commands"
  end

  def no_users(hour, minute) do
    "Standup at #{hour}:#{minute} (enroll teammates via `!standup enroll @teammate1 @teammate2...`"
  end

  def start_standup(person, direction) do
    "Standup time! <@#{person}> starts - moves to their #{direction}"
  end

  def help do
    "Supported Commands (precede with `!standup`):\n • `enroll @teammate1 @teammate2...`\n • `unenroll @teammate1 @teammate2...`\n • `help`"
  end

  def unknown do
    "Unknown command"
  end

end