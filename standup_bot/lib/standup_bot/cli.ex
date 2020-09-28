defmodule StandupBot.CLI do
  @doc """
  Entry point of the program. Parse args plus start initialize
  """
  def main(args \\ []) do
    [config_file, temp_dir] =
      case args do
        [config_file, temp_dir] ->
          [
            config_file,
            String.trim_trailing(temp_dir, "/")
          ]

        _ ->
          IO.puts("Error: Need arguments for config file path and temp directory")
      end

    %{
      "bot_token" => bot_token,
      "tasks" => tasks
    } = Utils.read_json_file(config_file)

    # Start supervisor
    StandupBot.start_link([
      config_file,
      bot_token,
      temp_dir,
      tasks
    ])

    Process.sleep(:infinity)
  end
end
