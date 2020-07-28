defmodule StandupBot.Messages do
  def start_standup(person, direction) do
    """
    *Standup time!* 
    <@#{person}> starts - moves to their #{direction}.
    """
  end

  def help do
    "Supported Commands (precede with `!toursteam`):\n • `standup`\n • `greenkeeping`\n • `help`"
  end

  def unknown do
    "Unknown command. Use `!toursteam help` to see supported commands."
  end

  def greenkeeping(person, pr_links) do
    pr_bullets =
      pr_links
      |> Enum.map(fn {link, title} -> " • <#{link}|#{title}>\n" end)
      |> Enum.join()

    """
    *Time for Weekly Greenkeeping!* 🍃🌿
    This week's greenkeeper is <@#{person}> 💚🚜

    Instructions can be found <https://docs.google.com/document/d/1Bo77hbjQnX3dnqiUn4prV1zbd71P839q-72GDmfwSsg/edit?usp=sharing|here>

    Greenkeeping PRs 👇
    #{pr_bullets}
    """
  end
end
