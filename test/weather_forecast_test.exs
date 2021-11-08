defmodule WeatherForecastTest do
  use ExUnit.Case
  doctest WeatherForecast

  import Mock

  @api_good_response "{\"consolidated_weather\":[{\"id\":5765563302281216,\"weather_state_name\":\"Heavy Cloud\",\"weather_state_abbr\":\"hc\",\"wind_direction_compass\":\"WNW\",\"created\":\"2021-11-08T20:29:15.962322Z\",\"applicable_date\":\"2021-11-08\",\"min_temp\":3.8649999999999998,\"max_temp\":11.535,\"the_temp\":10.504999999999999,\"wind_speed\":4.33755375979745,\"wind_direction\":300.5015301055326,\"air_pressure\":1018.5,\"humidity\":68,\"visibility\":13.010580708661418,\"predictability\":71},{\"id\":6676631964876800,\"weather_state_name\":\"Heavy Rain\",\"weather_state_abbr\":\"hr\",\"wind_direction_compass\":\"SSE\",\"created\":\"2021-11-08T20:29:19.739849Z\",\"applicable_date\":\"2021-11-09\",\"min_temp\":6.529999999999999,\"max_temp\":11.105,\"the_temp\":9.92,\"wind_speed\":6.910015358843023,\"wind_direction\":167.1762224589536,\"air_pressure\":1016.5,\"humidity\":79,\"visibility\":6.979551916805853,\"predictability\":77},{\"id\":5562292700708864,\"weather_state_name\":\"Light Rain\",\"weather_state_abbr\":\"lr\",\"wind_direction_compass\":\"WSW\",\"created\":\"2021-11-08T20:29:22.170302Z\",\"applicable_date\":\"2021-11-10\",\"min_temp\":5.46,\"max_temp\":9.145,\"the_temp\":9.97,\"wind_speed\":5.208254662324028,\"wind_direction\":257.07983939200466,\"air_pressure\":1024.0,\"humidity\":67,\"visibility\":13.262236041517538,\"predictability\":75},{\"id\":6296230108856320,\"weather_state_name\":\"Light Rain\",\"weather_state_abbr\":\"lr\",\"wind_direction_compass\":\"S\",\"created\":\"2021-11-08T20:29:25.138137Z\",\"applicable_date\":\"2021-11-11\",\"min_temp\":5.82,\"max_temp\":10.030000000000001,\"the_temp\":10.905000000000001,\"wind_speed\":4.737355421103422,\"wind_direction\":179.33417736024788,\"air_pressure\":1025.0,\"humidity\":66,\"visibility\":11.161380040563111,\"predictability\":75},{\"id\":5658332808347648,\"weather_state_name\":\"Heavy Cloud\",\"weather_state_abbr\":\"hc\",\"wind_direction_compass\":\"SE\",\"created\":\"2021-11-08T20:29:28.363450Z\",\"applicable_date\":\"2021-11-12\",\"min_temp\":7.465,\"max_temp\":13.915,\"the_temp\":11.995000000000001,\"wind_speed\":4.100867991990774,\"wind_direction\":145.67345824036954,\"air_pressure\":1028.5,\"humidity\":65,\"visibility\":13.696574504891434,\"predictability\":71},{\"id\":5069656168595456,\"weather_state_name\":\"Clear\",\"weather_state_abbr\":\"c\",\"wind_direction_compass\":\"SW\",\"created\":\"2021-11-08T20:29:31.276832Z\",\"applicable_date\":\"2021-11-13\",\"min_temp\":6.91,\"max_temp\":14.56,\"the_temp\":13.67,\"wind_speed\":2.8023470929770142,\"wind_direction\":229.49999999999994,\"air_pressure\":1020.0,\"humidity\":58,\"visibility\":9.999726596675416,\"predictability\":68}],\"time\":\"2021-11-08T14:27:00.043712-07:00\",\"sun_rise\":\"2021-11-08T07:06:39.231685-07:00\",\"sun_set\":\"2021-11-08T17:16:33.374687-07:00\",\"timezone_name\":\"LMT\",\"parent\":{\"title\":\"Utah\",\"location_type\":\"Region / State / Province\",\"woeid\":2347603,\"latt_long\":\"39.499741,-111.547318\"},\"sources\":[{\"title\":\"BBC\",\"slug\":\"bbc\",\"url\":\"http://www.bbc.co.uk/weather/\",\"crawl_rate\":360},{\"title\":\"Forecast.io\",\"slug\":\"forecast-io\",\"url\":\"http://forecast.io/\",\"crawl_rate\":480},{\"title\":\"HAMweather\",\"slug\":\"hamweather\",\"url\":\"http://www.hamweather.com/\",\"crawl_rate\":360},{\"title\":\"Met Office\",\"slug\":\"met-office\",\"url\":\"http://www.metoffice.gov.uk/\",\"crawl_rate\":180},{\"title\":\"OpenWeatherMap\",\"slug\":\"openweathermap\",\"url\":\"http://openweathermap.org/\",\"crawl_rate\":360},{\"title\":\"Weather Underground\",\"slug\":\"wunderground\",\"url\":\"https://www.wunderground.com/?apiref=fc30dc3cd224e19b\",\"crawl_rate\":720},{\"title\":\"World Weather Online\",\"slug\":\"world-weather-online\",\"url\":\"http://www.worldweatheronline.com/\",\"crawl_rate\":360}],\"title\":\"Salt Lake City\",\"location_type\":\"City\",\"woeid\":2487610,\"latt_long\":\"40.759499,-111.888229\",\"timezone\":\"America/Denver\"}"

  test "average_whole_num" do
    assert WeatherForecast.average([1, 2, 3]) == 2
  end

  test "average_float" do
    assert WeatherForecast.average([1, 2]) == 1.5
  end

  test "map_filter_keys_present" do
    map_list = [%{"min_temp" => 12.2, "max_temp" => 20.5}, %{"min_temp" => 9.567}]
    expected = [12.2, 9.567]
    assert WeatherForecast.filter_list_of_map_by_key(map_list, "min_temp") == expected
  end

  test "map_filter_keys_not_present" do
    map_list = [%{"max_temp" => 20.5}, %{"min_temp" => 9.567}]
    expected = [nil, 9.567]
    assert WeatherForecast.filter_list_of_map_by_key(map_list, "min_temp") == expected
  end

  test "successful_weather_api_call" do
    good_response = {:ok, %{}}

    with_mock HTTPoison,
      get: fn _url, [], follow_redirect: true ->
        {:ok, %HTTPoison.Response{body: "{}", status_code: 200}}
      end do
      assert WeatherForecast.get_weather_from_location(1) == good_response
    end
  end

  test "failed_weather_call" do
    with_mock HTTPoison,
      get: fn _url, [], follow_redirect: true ->
        {:ok, %HTTPoison.Response{body: "{\"detail\":\"Not found.\"}", status_code: 404}}
      end do
      assert WeatherForecast.get_weather_from_location(1) ==
               {:error, %{"detail" => "Not found."}}
    end
  end

  test "successful_average_max_temp" do
    with_mock HTTPoison,
      get: fn _url, [], follow_redirect: true ->
        {:ok, %HTTPoison.Response{body: @api_good_response, status_code: 200}}
      end do
      assert WeatherForecast.get_average_max_temp("SLC", 1) == "SLC Average Max Temp: 11.71"
    end
  end

  test "failed_average_max_temp" do
    with_mock HTTPoison,
      get: fn _url, [], follow_redirect: true ->
        {:ok, %HTTPoison.Response{body: "{\"detail\":\"Not found.\"}", status_code: 404}}
      end do
      assert WeatherForecast.get_average_max_temp("SLC", 1) ==
               {:error, %{"detail" => "Not found."}}
    end
  end

  test "successful_end_to_end" do
    # the console should print out the city average max temp (along with the temp of 11.71)
    with_mock HTTPoison,
      get: fn _url, [], follow_redirect: true ->
        {:ok, %HTTPoison.Response{body: @api_good_response, status_code: 200}}
      end do
      assert WeatherForecast.get_average_max_temp_for_cities() == :ok
    end
  end

  test "failed_end_to_end" do
    # the console should print out the city average max temp (along with the temp of 11.71)
    with_mock HTTPoison,
      get: fn _url, [], follow_redirect: true ->
        {:ok, %HTTPoison.Response{body: "{\"detail\":\"Not found.\"}", status_code: 404}}
      end do
      assert WeatherForecast.get_average_max_temp_for_cities() == [
               error: %{"detail" => "Not found."}
             ]
    end
  end
end
