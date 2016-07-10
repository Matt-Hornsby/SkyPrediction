defmodule Cskparser do

  def categorize(lines) do
    lines |> Enum.map(&parse/1) |> Enum.filter(&(&1 != nil))
  end

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

  defp create_kv_from(match, keyname) do
    [ _, _, _, val ] = match
    [header: Map.put(%{}, keyname, val)]
  end

  defp create_data_map(match) do
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

  defp create_darkness_map(match) do
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

  defp parse(line) do
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

  def merge_darkness_and_data(darkness, data) do
    combined = darkness ++ data
    f = fn(key) -> {key, Map.take(combined, key)} end
    Enum.map(Map.keys(combined), f)
  end

  def parse_lines(map) do
    parse_line(map, [])
  end

  def headers(map), do: filter_by_data_type(map, :header)
  def data(map), do: filter_by_data_type(map, :data)
  def darkness(map), do: filter_by_data_type(map, :darkness)

  defp filter_by_data_type(map, type) when is_atom(type) do
    map |> Enum.filter(&(Keyword.has_key?(&1, type))) |> Enum.map(&(&1[type]))
  end

  defp parse_line([[header: _]|tail], accum), do: parse_line(tail, accum) # skip header entries
  defp parse_line([[data: head]|tail], accum), do: parse_line(tail, [head] ++ accum)
  defp parse_line([[darkness: head]|tail], accum), do: parse_line(tail, [head] ++ accum)
  defp parse_line([nil | tail], accum), do: parse_line(tail, accum)   # handle empty entries
  defp parse_line([], accum), do: accum                               # handle end of recursive loop

  def clear_sky?(row), do: Map.has_key?(row, :clouds) && row.clouds >= 7
  def good_seeing?(row), do: Map.has_key?(row, :seeing) && row.seeing >= 4
  def dark?(row), do: Map.has_key?(row,:limiting_magnitude) && row.limiting_magnitude >= 5

  def good_chance_of_seeing?(row), do: clear_sky?(row) && good_seeing?(row) && dark?(row)

end

# File.stream!("seattlecsp.txt") |> Cskparser.categorize  |> Cskparser.parse_lines |> Enum.filter(&Cskparser.good_seeing?/1)
# File.stream!("seattlecsp.txt") |> Cskparser.categorize|> Cskparser.data
# File.stream!("seattlecsp.txt") |> Cskparser.categorize|> Cskparser.darkness
# File.stream!("seattlecsp.txt") |> Cskparser.categorize|> Cskparser.headers

  #File.stream!("seattlecsp.txt")
  #|> Cskparser.categorize
  #|> Cskparser.parse_lines
  #|> Enum.filter(&Cskparser.clear_sky?/1)
