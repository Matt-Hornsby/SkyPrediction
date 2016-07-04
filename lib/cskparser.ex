defmodule Cskparser do

  def categorize(lines) do
    lines |> Enum.map(&parse/1)
  end

  def match_data_line(line) do
    Regex.run(~r/"(.*)",\s(\d*),\t(\d*),\t(\d*),\t(\d*),\t(\d*),\t(\d*),\t/, line)
  end

  def match_darkness_line(line) do
    Regex.run(~r/"(.*)",\s(-?[0-9]\d*\.\d+)?,\t(-?[0-9]\d*\.\d+)?,\t(-?[0-9]\d*\.\d+)?/, line)
  end

  def match_quoted(line, key) do
    Regex.run(~r/#{key}(\s*)=(\s*)\"(.*)\"/, line)
  end

  def match_unquoted(line, key) do
    Regex.run(~r/#{key}(\s*)=(\s*)(.*)/, line)
  end

  def create_kv_from(match, keyname) do
    [ _, _, _, val ] = match
    [header: Map.put(%{}, keyname, val)]
  end

  def create_data_map(match) do
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

  def create_darkness_map(match) do
    #IO.inspect(match, width: 150)
    [_, datatime, limiting_magnitude, sun_altitude, moon_altitude] = match
    [darkness:
      %{
        datetime: datatime,
        limiting_magnitude: String.to_float(limiting_magnitude),
        sun_altitude: String.to_float(sun_altitude),
        moon_altitude: String.to_float(moon_altitude)
      }
    ]
  end

  def parse(line) do
    cond do
      match = match_quoted(line, "title") -> create_kv_from(match, :title)
      match = match_quoted(line, "version") -> create_kv_from(match, :version)
      match = match_quoted(line, "lp_rating_mags_per_square_arcsec") -> create_kv_from(match, :lp_rating_mags_per_square_arcsec)
      match = match_unquoted(line, "lp_rating_RGB_color") -> create_kv_from(match, :lp_rating_RGB_color)
      match = match_unquoted(line, "UTC_offset") -> create_kv_from(match, :utc_offset)
      match = match_data_line(line) -> create_data_map(match)
      match = match_darkness_line(line) -> create_darkness_map(match)

      true -> nil
    end
  end

  def parse_lines(map) do
    parse_line(map, [])
  end

  defp parse_line([[header: _]|tail], accum), do: parse_line(tail, accum)
  defp parse_line([[data: head]|tail], accum), do: parse_line(tail, [head] ++ accum)
  defp parse_line([[darkness: head]|tail], accum), do: parse_line(tail, [head] ++ accum)
  defp parse_line([nil | tail], accum), do: parse_line(tail, accum)   # handle empty entries
  defp parse_line([], accum), do: accum                               # handle end of recursive loop

  def clear_day?(data), do: Map.has_key?(data, :clouds) && data.clouds >= 7
  def good_seeing?(data), do: Map.has_key?(data, :seeing) && data.seeing >= 4

end

#File.stream!("seattlecsp.txt") |> Cskparser.categorize  |> Cskparser.parse_lines

  File.stream!("seattlecsp.txt")
  |> Cskparser.categorize
  |> Cskparser.parse_lines
  |> Enum.filter(&clear_day?/1)
