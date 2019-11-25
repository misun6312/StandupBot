defmodule StandupBot.Users do
  use Agent

  # Primitives
  def start_link(_opts) do
    Agent.start_link(fn -> %MapSet{} end)
  end

  defp get(bucket, value) do
    Agent.get(bucket, &MapSet.get(&1, value))
  end

  defp put(bucket, value) do
    Agent.update(bucket, &MapSet.put(&1, value))
  end

  defp delete(bucket, value) do
    Agent.update(bucket, &MapSet.delete(&1, value))
  end

  # Interface
  def teamlist(bucket) do
    Agent.get(bucket, &MapSet.to_list(&1))
  end

  def enroll_users(bucket, users) do
    Enum.each(users, &put(bucket, &1))
  end

  def unenroll_users(bucket, users) do
    Enum.map(users, &delete(bucket, &1))
  end

end