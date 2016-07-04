defmodule Cskparser do

  def categorize(lines) do
    lines |> Enum.map(&parse/1)
  end

  def match_data_line(line) do
    Regex.run(~r/"(.*)",\s(\d*),\t(\d*),\t(\d*),\t(\d*),\t(\d*),\t(\d*),\t/, line)
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

  def parse(line) do
    cond do
      match = match_quoted(line, "title") -> create_kv_from(match, :title)
      match = match_quoted(line, "version") -> create_kv_from(match, :version)
      match = match_quoted(line, "lp_rating_mags_per_square_arcsec") -> create_kv_from(match, :lp_rating_mags_per_square_arcsec)
      match = match_unquoted(line, "lp_rating_RGB_color") -> create_kv_from(match, :lp_rating_RGB_color)
      match = match_unquoted(line, "UTC_offset") -> create_kv_from(match, :utc_offset)
      match = match_data_line(line) ->
        # Found a data line
        [ _, datetime, clouds, transparency, seeing, wind, humidity, temperature] = match
        [data:
              %{
                datetime: datetime,
                clouds: clouds,
                transparency: transparency,
                seeing: seeing,
                wind: wind,
                humidity: humidity,
                temperature: temperature
              }
        ]
      true -> nil
    end
  end

  def parse_lines(map) do
    parse_line(map, [])
  end

  #defp parse_line([[header: %{:title => title}]|tail], accum) do
    #IO.puts "title: #{title}"
    #parse_line(tail, accum)
  #end

  #defp parse_line([[header: head]|tail], accum) do
  #  IO.inspect head
  #  parse_line(tail, [head] ++ accum)
  #end

  defp parse_line([[data: head]|tail], accum), do: parse_line(tail, [head] ++ accum)
  defp parse_line([nil | tail], accum), do: parse_line(tail, accum)   # handle empty entries
  defp parse_line([], accum), do: accum                               # handle end of recursive loop

  def clear_day?(data), do: String.to_integer(data.clouds) >= 7
  def good_seeing?(data), do: String.to_integer(data.seeing) >= 4

end

#File.stream!("seattlecsp.txt") |> Cskparser.categorize  |> Cskparser.parse_lines
results =
  File.stream!("seattlecsp.txt")
  |> Cskparser.categorize
  |> Cskparser.parse_lines()
  |> Enum.filter(&(&1[:clouds] == "8"))
