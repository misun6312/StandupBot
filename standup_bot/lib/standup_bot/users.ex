defmodule StandupBot.Users do
  def pick_without_replacement(cfg, tmp_dir, job) do
    # Get users
    tmp_file = Utils.temp_filepath(tmp_dir, job)

    users =
      if File.exists?(tmp_file) do
        Utils.read_json_file(tmp_file)
        |> Map.get("users")
      else
        config_map = Utils.read_json_file(cfg)

        all_users =
          config_map
          |> get_in(["tasks", job, "users"])

        Utils.write_json_file(tmp_file, %{"users" => all_users})
        all_users
      end

    # Normalize and shuffle list
    users =
      users
      |> MapSet.new()
      |> Enum.to_list()
      |> Enum.shuffle()

    # Pick starter
    starter = Enum.random(users)
    remaining = Enum.filter(users, &(&1 != starter))

    # Handle round-robin reset if applicable
    remaining =
      if length(remaining) == 0 do
        Utils.read_json_file(cfg)
        |> get_in(["tasks", job, "users"])
      else
        remaining
      end

    Utils.write_json_file(tmp_file, %{"users" => remaining})

    starter
  end
end
