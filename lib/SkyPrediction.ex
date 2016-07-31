defmodule SkyPrediction do
  require Logger
  
  def get_data_for(city_key) do
    Application.ensure_all_started :inets
    {:ok, resp} = :httpc.request(:get, {'http://www.cleardarksky.com/txtc/#{city_key}csp.txt', []}, [], [body_format: :binary])
    {{_, 200, 'OK'}, _headers, body} = resp
    Logger.info "#{String.length(body)} bytes read."
    File.write!("seattlecsp.txt", body)
  end

  def get_data_for_seattle, do: get_data_for("Seattle")
end
