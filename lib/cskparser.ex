defmodule Cskparser do

  @moduledoc """
  This module parses a file stream from http://www.ClearDarkSky.com.
  You'll need to find the right text file for your given observation area.

  The path follows the following pattern:
  http://www.cleardarksky.com/txtc/LOCATIONcsp.txt

  For example, you can find the latest predictions for the seattle area here:
  http://www.cleardarksky.com/txtc/Seattlecsp.txt
  """

  @doc """
  Parses the given input stream into an enumerable data structure

  ## Examples

      iex> File.stream!("seattlecsp.txt") |> Cskparser.parse_file

  """
  def parse_file(input_stream) do
    parsed_results = input_stream |> categorize_each_line
    hourly_darkness_averages = parsed_results |> extract_darkness_data |> collapse_magnitudes_into_hourly_chunks
    hourly_data = parsed_results |> extract_hourly_data
    combine(hourly_darkness_averages, hourly_data) |> Enum.map(&convert_to_hourly_prediction/1)
  end

  def categorize_each_line(lines) do
    lines
      |> Enum.map(&parse/1)
      |> Enum.filter(&(&1 != nil))
  end

  defp parse(line) do
    cond do
      match = match_quoted(line, "title") -> header(match, :title)
      match = match_quoted(line, "version") -> header(match, :version)
      match = match_quoted(line, "lp_rating_mags_per_square_arcsec") -> header(match, :lp_rating_mags_per_square_arcsec)
      match = match_unquoted(line, "lp_rating_RGB_color") -> header(match, :lp_rating_RGB_color)
      match = match_unquoted(line, "UTC_offset") -> header(match, :utc_offset)
      match = match_data_line(line) -> data(match)
      match = match_darkness_line(line) -> darkness(match)
      true -> nil
    end
  end

  defp data(match) do
    #IO.inspect(match, width: 150)
    [ _, datetime, clouds, transparency, seeing, wind, humidity, temperature] = match
    [data:
          %{
            datetime: datetime,
            clouds: String.to_integer(clouds),
            transparency: String.to_integer(transparency),
            seeing: String.to_integer(seeing),
            wind: String.to_integer(wind),
            humidity: String.to_integer(humidity),
            temperature: String.to_integer(temperature)
          }
    ]
  end

  defp darkness(match) do
    #IO.inspect(match, width: 150)
    [_, datetime, limiting_magnitude, sun_altitude, moon_altitude] = match
    [darkness:
      %{
        datetime: datetime,
        limiting_magnitude: String.to_float(limiting_magnitude),
        sun_altitude: String.to_float(sun_altitude),
        moon_altitude: String.to_float(moon_altitude)
      }
    ]
  end

  defp extract_headers(map), do: extract(map, :header)
  defp extract_hourly_data(map), do: extract(map, :data)
  defp extract_darkness_data(map), do: extract(map, :darkness)

  defp extract(map, type), do: for [{^type, data}] <- map, do: data

  defp match_data_line(line) do
    Regex.run(~r/"(.*)",\s(\d*),\t(\d*),\t(\d*),\t(\d*),\t(\d*),\t(\d*),\t/, line)
  end

  defp match_darkness_line(line) do
    Regex.run(~r/"(.*)",\s(-?[0-9]\d*\.\d+)?,\t(-?[0-9]\d*\.\d+)?,\t(-?[0-9]\d*\.\d+)?/, line)
  end

  defp match_quoted(line, key) do
    Regex.run(~r/#{key}(\s*)=(\s*)\"(.*)\"/, line)
  end

  defp match_unquoted(line, key) do
    Regex.run(~r/#{key}(\s*)=(\s*)(.*)/, line)
  end

  defp header(match, keyname) do
    [ _, _, _, val ] = match
    [header: Map.put(%{}, keyname, val)]
  end

  defp combine(darkness, data), do: combine(darkness, data, [])
  defp combine([], [], accum), do: accum
  defp combine([darkness_head | darkness_tail], [data_head | data_tail], accum) do
    new = Map.put(data_head, :limiting_magnitude, darkness_head)
    combine(darkness_tail, data_tail, accum ++ [new])
  end
  defp combine(_, _, accum), do: accum # This is necessary if the lists are unbalanced

  defp collapse_magnitudes_into_hourly_chunks(darkness_data),
    do: darkness_data |> Enum.chunk(5) |> Enum.map(&average_chunk/1)
  defp average_chunk(chunk), do: chunk |> Enum.map(&(&1.limiting_magnitude)) |> mean
  defp mean(list), do: (Enum.sum(list) / length(list)) |> Float.round(3)

  defp convert_to_hourly_prediction(map) do
    %HourlyPrediction{
                      hour: map.datetime,
                      clouds: map.clouds,
                      humidity: map.humidity,
                      limiting_magnitude: map.limiting_magnitude,
                      seeing: map.seeing,
                      transparency: map.transparency,
                      wind: map.wind,
                      temperature: map.temperature
                    }
  end


end
