defmodule HourlyPrediction do
  defstruct hour: nil,
            clouds: nil,
            humidity: nil,
            limiting_magnitude: nil,
            temperature: nil,
            transparency: nil,
            wind: nil,
            seeing: nil

  defp cloud_colors do
    [254, 253, 249, 159, 117, 81, 75, 69, 26, 20, 18]
  end

  defp darkness_colors do
    [254, 253, 249, 159, 117, 81, 75, 69, 26, 20, 18]
  end

  defp transparency_colors do
    [254, 248, 116, 75, 27, 18]
  end

  defp seeing_colors do
    [254, 248, 116, 75, 27, 18]
  end

  def to_string(%__MODULE__{} = hourly_prediction) do
    cloud_format = cloud_colors |> format_string(hourly_prediction.clouds)
    transparency_format = transparency_colors |> format_string(hourly_prediction.transparency)
    seeing_format = seeing_colors |> format_string(hourly_prediction.seeing)
    darkness_format = darkness_colors |> format_string(hourly_prediction.limiting_magnitude)
    datetime_format = hourly_prediction.hour |> format_datetime

    "#{datetime_format}" <>
    "#{IO.ANSI.color_background(240)}" <>
    "#{cloud_format}" <>
    "#{transparency_format}" <>
    "#{seeing_format}" <>
    #"#{darkness_format}" <>
    "#{IO.ANSI.reset}"
  end

  defp format_datetime(nil), do: ""
  defp format_datetime(datetime) do
    datetime = datetime |> String.split(" ")
    day = datetime |> Enum.at(0)
    hour = datetime |> Enum.at(1) |> String.slice(0..1)
    "#{day}@#{hour}:"
  end

  defp format_string(_color_array, nil), do: ""
  defp format_string(color_array, index) when index in 0..length(color_array) do
    color = color_array |> Enum.at(index)
    "#{IO.ANSI.color(color)}■"
  end
  defp format_string(_color_array, val), do: "#{val}"


  def all_rgb(0), do: IO.puts("#{IO.ANSI.color(0)} 0")
  def all_rgb(val) do
    IO.puts("#{IO.ANSI.color(val)} #{val}")
    all_rgb(val - 1)
  end

end
