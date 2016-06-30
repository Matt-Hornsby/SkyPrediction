defmodule Cskparser do

  def categorize(lines) do
    lines |> Enum.map(&parse/1)
    # need to reduce here with an accumulator structure based on base_map
    # then fill in the data strcuture
    # Use pattern matching to find {:data = value}  or {:header = value}??
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
                :datetime=>datetime,
                :clouds=>clouds,
                :transparency=>transparency,
                :seeing=>seeing,
                :wind=>wind,
                :humidity=>humidity,
                :temperature=>temperature
              }
        ]
      true -> nil
    end
  end

  #TODO: Perhaps have some recursive functions to loop through and accumulate an list of just data points
  def parse_line([[header: %{:title => title}]|tail]) do
    IO.puts "title: #{title}"
    parse_line(tail)
  end

  def parse_line([[header: head]|tail]) do
    IO.inspect head
    parse_line(tail)
  end

  def parse_line([[data: head]|tail]) do
    IO.inspect(head, width: 150)
    parse_line(tail)
  end

  def parse_line([nil | tail]), do: parse_line(tail)  # handle empty entries
  def parse_line(input), do: input                    # handle all other patterns

end

#File.stream!("seattlecsp.txt") |> Cskparser.categorize  |> Cskparser.parse_line
