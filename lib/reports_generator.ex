defmodule ReportsGenerator do
  alias ReportsGenerator.Parser

  # is a module variable, constant value that does not change
  @available_foods [
    "açaí",
    "churrasco",
    "esfirra",
    "hambúrguer",
    "pastel",
    "pizza",
    "prato_feito",
    "sushi"
  ]

  @options ["foods", "users"]

  def build(filename) do
    # this string will be send how argument to after functions
    filename
    # this function brings a struct - struct is a map with a name - this function brings just meta data - we can return the file data if we want - this function not returns error, it reads the file gradually together with Enum
    |> Parser.parse_file()
    # the first argument comes from File.stream
    |> Enum.reduce(report_acc(), fn line, report ->
      # we let's use pattern matching for get id, food_name and price
      sum_values(line, report)
    end)
  end

  # we let's receive a list of files
  # implicit syntax -> &build(&1)
  # in reduce always have each element and accumulator
  def build_from_many(filenames) do
    filenames
    |> Task.async_stream(fn filenames -> build(filenames) end)
    |> Enum.reduce(report_acc(), fn {:ok, result}, report -> sum_reports(report, result) end)
  end

  # guards - we use guards with the word 'when' -> we can use guards when we define the function to extend the pattern matching power
  def fetch_higher_cost(report, option) when option in @options do
    {:ok, Enum.max_by(report[option], fn {_key, value} -> value end)}
  end

  # if there is no error in the above function, it will enter the next function
  def fetch_higher_cost(_report, _option) do
    {:error, "Invalid option!"}
  end

  defp sum_values([id, food_name, price], %{"foods" => foods, "users" => users} = report) do
    users = Map.put(users, id, users[id] + price)
    foods = Map.put(foods, food_name, foods[food_name] + 1)

    report
    |> Map.put("users", users)
    |> Map.put("foods", foods)

    # %{report | "users" => users, "foods" => foods}

    # line = ["1", "churrasco", 30]
    # users = %{"1" => 30}
    # = foods = %{"churrasco" => 0}
  end

  # this function will add the blank accumulator with the current value that is being read (in this case, the file read at the moment) in order to sum all the files in the same accumulator
  defp sum_reports(%{"foods" => foods1, "users" => users1}, %{
         "foods" => foods2,
         "users" => users2
       }) do
    foods = merge_maps(foods1, foods2)
    users = merge_maps(users1, users2)

    build_report(foods, users)
  end

  defp merge_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> value1 + value2 end)
  end

  defp report_acc do
    foods = Enum.into(@available_foods, %{}, &{&1, 0})
    users = Enum.into(1..30, %{}, &{Integer.to_string(&1), 0})

    build_report(foods, users)
  end

  defp build_report(foods, users) do
    %{"foods" => foods, "users" => users}
  end
end
