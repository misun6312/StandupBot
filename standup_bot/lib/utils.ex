defmodule Utils do

  def validate_users(users) do
    users
    |> Enum.filter(&Regex.match?(~r/<@[A-Z\d]+>/, &1))
    |> Enum.map(&String.replace(&1, "<@", ""))
    |> Enum.map(&String.replace(&1, ">", ""))
  end

  defp standup_time(ndt, hour \\ 10, minute \\ 45) do
    %DateTime{
      year: ndt.year,
      month: ndt.month,
      day: ndt.day,
      zone_abbr: ndt.zone_abbr,
      hour: 10,
      minute: 45,
      second: 0,
      microsecond: {0, 0},
      utc_offset: ndt.utc_offset,
      std_offset: ndt.std_offset,
      time_zone: ndt.time_zone,
    }
  end

  def ms_til_next_standup(hour \\ 10, minute \\ 45) do
    curr_dt = DateTime.utc_now()
    standup_dt = if curr_dt.hour > hour and curr_dt.minute > minute do
      standup_time(DateTime.add(curr_dt, 86400, :second, FakeTimeZoneDatabase))
    else
      standup_time(curr_dt, hour, minute)
    end
    IO.inspect standup_dt
    DateTime.diff(standup_dt, curr_dt) * 1000
  end
end

