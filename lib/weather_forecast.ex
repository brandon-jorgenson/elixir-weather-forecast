defmodule WeatherForecast do
  @moduledoc """
  WeatherForecast provides weather forecast information based on metaweather.com
  """

  # The location -> location id mappings are in a list to preserve ordering.
  # If ordering didn't matter, this could be a simple map
  @location_id_map [
    %{"Salt Lake City": 2_487_610},
    %{"Los Angeles": 2_442_047},
    %{Boise: 2_366_355}
  ]

  @base_url "https://www.metaweather.com/api"

  @doc """
  Prints out the average max temperature over a six day forecast
  for the locations listed in @location_id_map
  """
  def get_average_max_temp_for_locations do
    @location_id_map
    |> Task.async_stream(
      fn map -> Enum.map(map, fn {k, v} -> WeatherForecast.get_average_max_temp(k, v) end) end,
      ordered: true
    )
    |> Enum.each(fn {:ok, result} -> IO.puts(result) end)
  end

  @doc """
  Returns the average max temperature over a six day forecast for a given location
  ## Parameters
    - location: The location we want the max temp for
    - location_id: The id that the metaweather id needs for the location
  """
  def get_average_max_temp(location, location_id) do
    case get_weather_from_location(location_id) do
      {:ok, json} ->
        json
        |> (fn json -> filter_list_of_map_by_key(json["consolidated_weather"], "max_temp") end).()
        |> average()
        |> Decimal.from_float()
        |> Decimal.round(2)
        |> (fn decimal_average ->
              "#{location}" <> " Average Max Temp: " <> "#{decimal_average}"
            end).()

      {:error, reason} ->
        reason
    end
  end

  @doc """
  Calls the weather api and returns the weather data
  ## Parameters
    - id: The id that the metaweather id needs to identify the location
  """
  def get_weather_from_location(id) do
    url = "#{@base_url}/location/#{id}"

    case(HTTPoison.get(url, [], follow_redirect: true)) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        {:ok, Poison.decode!(body)}

      {:ok, %HTTPoison.Response{body: _body, status_code: code}} ->
        {:error, "#{code}" <> " Error"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Takes a list of maps and returns the values that match a given key
  ## Parameters
    - list: The input list (list items must be maps)
    - key: The key to match on each nested map
  """
  def filter_list_of_map_by_key(list, key) do
    for map <- list, do: map[key]
  end

  @doc """
  Returns the average of a numeric list
  ## Parameters
    - list: The input list of numbers
  """
  def average(list) do
    Enum.sum(list) / length(list)
  end
end
