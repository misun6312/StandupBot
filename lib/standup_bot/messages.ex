defmodule StandupBot.Messages do
  def start_standup(person, direction) do
    """
    *Standup time!* 
    <@#{person}> starts - moves to their #{direction}.
    """
  end

  def help do
    "Supported Commands (precede with `!teambot`):\n • `standup`\n • `greenkeeping`\n • `help`"
  end

  def unknown do
    "Unknown command. Use `!teambot help` to see supported commands."
  end

  def greenkeeping(person, pr_links) do
    pr_bullets =
      pr_links
      |> Enum.map(fn {link, title} -> " • <#{link}|#{title}>\n" end)
      |> Enum.join()

    """
    *Time for Greenkeeping!* 🍃🌿
    This sprint's greenkeeper is <@#{person}> 💚🚜

    Instructions can be found <https://docs.google.com/document/d/1jje76ug7ggWXnymPu4seylaZjV-4JzhBq7tXIjLU_1g/edit?usp=sharing|here>

    Greenkeeping PRs 👇
    #{pr_bullets}
    """
  end
end
