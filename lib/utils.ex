defmodule Utils do
  @doc """
  Transform a json file into a Map
  """
  def read_json_file(file_name) do
    file_name
    |> File.read!()
    |> Poison.decode!()
  end

  @doc """
  Assert and filter a collection to only valid slack
  user ids
  """
  def validate_users(users) do
    users
    |> Enum.filter(&Regex.match?(~r/<@[A-Z\d]+>/, &1))
    |> Enum.map(&String.replace(&1, "<@", ""))
    |> Enum.map(&String.replace(&1, ">", ""))
  end

  def write_json_file(file_name, contents) do
    contents = contents |> Poison.encode!()

    file_name
    |> File.write!(contents)
  end

  @doc """
  Supplies an immutable copy of a datetime
  with the seconds/microseconds set to 0.
  TODO: is there an `update` function for a datetime object?
  """
  defp standup_time(ndt, hour, minute) do
    %DateTime{
      year: ndt.year,
      month: ndt.month,
      day: ndt.day,
      zone_abbr: ndt.zone_abbr,
      hour: hour,
      minute: minute,
      second: 0,
      microsecond: {0, 0},
      utc_offset: ndt.utc_offset,
      std_offset: ndt.std_offset,
      time_zone: ndt.time_zone
    }
  end

  @doc """
  Calculates the delta in milliseconds from the current time
  until the next scheduled action
  """
  def ms_til_next_action(hour, minute) do
    curr_dt = DateTime.utc_now() |> DateTime.add(-18000, :second)
    todays_standup_dt = standup_time(curr_dt, hour, minute)

    standup_dt =
      case DateTime.compare(curr_dt, todays_standup_dt) do
        :lt -> todays_standup_dt
        _gt_or_eq -> standup_time(DateTime.add(curr_dt, 86400, :second), hour, minute)
      end

    abs(DateTime.diff(curr_dt, standup_dt)) * 1000
  end

  def temp_filepath(tmp_dir, job) do
    tmp_dir <> "/" <> ".#{job}.json"
  end
end
