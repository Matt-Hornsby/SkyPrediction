defmodule WeatherPrediction do
  def good_chance_of_seeing?(row), do: clear_sky?(row) && good_seeing?(row) && dark?(row)

  #def clear_sky?(%{:clouds => clouds}) when clouds >=7, do: true
  #def clear_sky?(_), do: false
  def clear_sky?(%{:clouds => clouds}), do: clouds >= 7
  #def clear_sky?(row), do: Map.has_key?(row, :clouds) && row.clouds >= 7

  def good_seeing?(%{:seeing => seeing}), do: seeing >= 4
  #def good_seeing?(row), do: Map.has_key?(row, :seeing) && row.seeing >= 4

  def dark?(%{:limiting_magnitude => magnitude}), do: magnitude <= -4.0
  #def dark?(row), do: Map.has_key?(row, :limiting_magnitude) && row.limiting_magnitude <= -4.0

  def get_file_stream, do: File.stream!("seattlecsp.txt")

  def get_good_candidates do
    get_file_stream |> Cskparser.parse_file |> Enum.filter(&good_chance_of_seeing?/1)
  end
end
