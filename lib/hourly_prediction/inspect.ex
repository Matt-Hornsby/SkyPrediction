defimpl Inspect, for: HourlyPrediction do
  alias HourlyPrediction

  def inspect(d, %{:structs => false} = opts) do
    Inspect.Algebra.to_doc(d, opts)
  end

  def inspect(d, _opts) do
    "#{IO.ANSI.reset}#<HourlyPrediction(#{HourlyPrediction.to_string(d)})>#{IO.ANSI.reset}"
  end
end
