defmodule ReportsGenerator.Parser do
  def parse_file(filename) do
    # this string will be send how argument to after functions
    "reports/#{filename}"
    # this function brings a struct - struct is a map with a name - this function brings just meta data - we can return the file data if we want - this function not returns error, it reads the file gradually together with Enum
    |> File.stream!()
    # module Stream only execute operations when we need of values
    |> Stream.map(fn line -> parse_line(line) end)
  end

  defp parse_line(line) do
    # first argument of functions
    line
    |> String.trim()
    |> String.split(",")
    # with '&' we can call an anonymous function
    |> List.update_at(2, &String.to_integer/1)
  end
end
