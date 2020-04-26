defmodule StandupBot.Users do
  use Agent

  # Primitives
  def start_link(_opts) do
    Agent.start_link(fn -> %MapSet{} end)
  end

  defp put(bucket, value) do
    Agent.update(bucket, &MapSet.put(&1, value))
  end

  defp delete(bucket, value) do
    Agent.update(bucket, &MapSet.delete(&1, value))
  end

  defp to_list(bucket) do
    Agent.get(bucket, &MapSet.to_list(&1))
  end

  # Interface
  def teamlist(bucket) do
    to_list(bucket)
  end

  def enroll_users(bucket, users) do
    if length(users) > 0 do
      Enum.each(users, &put(bucket, &1))
    else
      {:error, nil}
    end
  end

  def unenroll_users(bucket, users) do
    if length(users) > 0 do
      Enum.map(users, &delete(bucket, &1))
    else
      {:error, nil}
    end
  end

  def pick_starter(cfg, tmp) do
    # Get users
    users = if File.exists?(tmp) do
      Utils.read_json_file(tmp) |> Map.get("users")
    else
      users = Utils.read_json_file(cfg) |> Map.get("users")
      Utils.write_json_file(tmp, %{"users" => users})
      users
    end
    # Normalize and shuffle list
    users = users
    |> MapSet.new()
    |> Enum.to_list()
    |> Enum.shuffle()
    # Pick starter
    starter = Enum.random(users)
    remaining = Enum.filter(users, &(&1!=starter))
    remaining = if length(remaining) == 0 do
      Utils.read_json_file(cfg) |> Map.get("users")
    else
      remaining
    end
    IO.inspect {:remaining_people, remaining}
    # Write updated file back
    Utils.write_json_file(tmp, %{
      "users" => remaining,
    })
    starter
  end

end