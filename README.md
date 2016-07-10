# SkyPrediction

Get alerted when something interesting is going to be visible in the night sky in your area, taking into account weather predictions, light pollution, and more.

### Usage
> iex -S mix

> iex> WeatherPrediction.get_good_candidates

> [%{clouds: 7, datetime: "2016-06-25 13:00:00", humidity: 10, limiting_magnitude: -4.6, seeing: 4, temperature: 12, transparency: 0, wind: 5},
 %{clouds: 8, datetime: "2016-06-25 15:00:00", humidity: 10, limiting_magnitude: -4.18, seeing: 4, temperature: 12, transparency: 0, wind: 4},
 %{clouds: 10, datetime: "2016-06-26 05:00:00", humidity: 14, limiting_magnitude: 3.16, seeing: 4, temperature: 11, transparency: 3, wind: 4}]

### About this app

This app is being developed to help me learn the excellent Elixir programming language, and hopefully to provide a useful service to amateur stargazers. This app utilizes data from ClearDarkSky (http://cleardarksky.com) to determine if there will be clouds or other obstacles to viewing ISS flyovers, Iridium flares, and whatever else I can think of.
