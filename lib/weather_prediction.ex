defmodule WeatherPrediction do

  def good_chance_of_seeing?(row), do: clear_sky?(row) && good_seeing?(row) && dark?(row) && transparent?(row)

  def clear_sky?(%{:clouds => clouds}), do: clouds >= 7
  #def clear_sky?(row), do: Map.has_key?(row, :clouds) && row.clouds >= 7

  def good_seeing?(%{:seeing => seeing}), do: seeing >= 4
  #def good_seeing?(row), do: Map.has_key?(row, :seeing) && row.seeing >= 4

  def dark?(%{:limiting_magnitude => magnitude}), do: magnitude > 4.0
  #def dark?(row), do: Map.has_key?(row, :limiting_magnitude) && row.limiting_magnitude <= -4.0

  def transparent?(%{:transparency => transparency}), do: transparency >= 3

  def get_file_stream_for(city_key), do: File.stream!("#{city_key}csp.txt")

  def get_good_candidates_for(city_key) do
    get_file_stream_for(city_key)
      |> Cskparser.parse_file
      |> Enum.filter(&good_chance_of_seeing?/1)
  end

  def get_clear_skies_for(city_key) do
    get_file_stream_for(city_key)
      |> Cskparser.parse_file
      |> Enum.filter(&clear_sky?/1)
  end

  def get_dark_skies_for(city_key) do
    get_file_stream_for(city_key)
      |> Cskparser.parse_file
      |> Enum.filter(&dark?/1)
  end

  def get_good_candidates_for_seattle, do: get_good_candidates_for("Seattle")
end
