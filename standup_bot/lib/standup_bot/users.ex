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

end