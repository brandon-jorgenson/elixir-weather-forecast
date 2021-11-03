defmodule WeatherForecastTest do
  use ExUnit.Case
  doctest WeatherForecast

  test "greets the world" do
    assert WeatherForecast.hello() == :world
  end
end
