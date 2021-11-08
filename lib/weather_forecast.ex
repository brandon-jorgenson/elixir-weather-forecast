defmodule WeatherForecast do
  @base_url "https://www.metaweather.com/api"
  @city_id_map [%{"Salt Lake City": 2_487_610}, %{"Los Angeles": 2_442_047}, %{Boise: 2_366_355}]
  @moduledoc """
  Documentation for `WeatherForecast`.
  """

  def get_average_max_temp_for_cities do
    @city_id_map
    |> Task.async_stream(
      fn map -> Enum.map(map, fn {k, v} -> WeatherForecast.get_average_max_temp(k, v) end) end,
      ordered: true
    )
    |> Enum.each(fn {_ok, result} -> IO.puts(result) end)
  end

  def get_average_max_temp(location, location_id) do
    case get_weather_from_location(location_id) do
      {:ok, json} ->
        max_temps = filter_list_of_map_by_key(json["consolidated_weather"], "max_temp")
        average_max_temp = average(max_temps)
        decimal_average = Decimal.round(Decimal.from_float(average_max_temp), 2)
        "#{location}" <> " Average Max Temp: " <> "#{decimal_average}"

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec get_weather_from_location(any) ::
          {:error, any} | {:ok, false | nil | true | binary | list | number | map}
  def get_weather_from_location(id) do
    url = "#{@base_url}/location/#{id}"

    case(HTTPoison.get(url, [], follow_redirect: true)) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        {:ok, Poison.decode!(body)}

      {:ok, %HTTPoison.Response{body: body, status_code: _}} ->
        {:error, Poison.decode!(body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def filter_list_of_map_by_key(list, key) do
    for map <- list, do: map[key]
  end

  @spec average(list) :: float
  def average(list) do
    Enum.sum(list) / length(list)
  end
end
