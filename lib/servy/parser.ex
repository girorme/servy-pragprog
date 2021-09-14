defmodule Servy.Parser do
  alias Servy.Conv, as: Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\r\n\r\n")
    [request_line | headers_lines] = String.split(top, "\r\n")
    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers(headers_lines)

    params = parse_params(headers["Content-Type"], params_string)

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  def parse_headers(headers_line) do
    Enum.reduce(headers_line, %{}, fn (line, headers) ->
      [key, value] = String.split(line, ": ")
      Map.put(headers, key, value)
    end)
  end

  # def parse_headers([head | tail], headers) do
  #   [key, value] = String.split(head, ": ")
  #   headers = Map.put(headers, key, value)
  #   parse_headers(tail, headers)
  # end

  # def parse_headers([], headers), do: headers

  @doc """
  Parses the given param string of the form `key1=value1&key2=value2`
  into a map with corresponding keys and values

  ## Examples
    iex> params_string = "name=Ballo&type=Brown"
    iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
    %{"name" => "Ballo", "type" => "Brown"}
    iex> Servy.Parser.parse_params("multipart/form-data", params_string)
    %{}
  """
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim |> URI.decode_query
  end

  def parse_params(_, _), do: %{}
end
