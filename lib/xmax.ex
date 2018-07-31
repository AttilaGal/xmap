defmodule XMax do
  @moduledoc ~S'''
  XML to Map conversion.

  XMax transforms an XML string into a `Map` containing a collection of pairs
  where the key is the node name and the value is its content.

  XMax was originally forked from XMap. There are 2 notable difference between the packages:

  1) XMax will also map xml attributes. This does however cause for larger mapped objects.
  Attributes are mapped to the `"$"` key, while contents are mapped to the `"_"` key. If you know
  you're never going to need xml attributes, XMap may be a better fit.

  2) XMax does not support atom keys, it's usually not a good idea to generate atoms on the fly.
  So to prevent unexpected memory leaks, this feature has been ommitted

  ## Examples

  Here is an example:

      iex> xml = """
      ...> <?xml version="1.0" encoding="UTF-8"?>
      ...> <blog>
      ...>   <post>
      ...>     <title>Hello Elixir!</title>
      ...>   </post>
      ...>   <post>
      ...>     <title>Hello World!</title>
      ...>   </post>
      ...> </blog>
      ...> """
      iex> XMax.from_xml(xml)
      %{
        "blog" => %{
          "$" => %{},
          "_" => %{
            "post" => [
              %{
                "$" => %{},
                "_" => %{"title" => %{"$" => %{}, "_" => "Hello Elixir!"}}
              },
              %{
                "$" => %{},
                "_" => %{"title" => %{"$" => %{}, "_" => "Hello World!"}}
              }
            ]
          }
        }
      }
  '''

  @doc ~S'''
  Returns a `Map` containing a collection of pairs where the key is the node name
  and the value is its content.

  ## Examples

  Here is an example:

      iex> xml = """
      ...> <?xml version="1.0" encoding="UTF-8"?>
      ...> <post id="1">
      ...>   <title>Hello world!</title>
      ...>   <stats>
      ...>     <visits type="integer">1000</visits>
      ...>     <likes type="integer">3</likes>
      ...>   </stats>
      ...> </post>
      ...> """
      iex> XMax.from_xml(xml)
      %{
        "post" => %{
          "$" => %{"id" => '1'},
          "_" => %{
            "stats" => %{
              "$" => %{},
              "_" => %{
                "likes" => %{"$" => %{"type" => 'integer'}, "_" => "3"},
                "visits" => %{"$" => %{"type" => 'integer'}, "_" => "1000"}
              }
            },
            "title" => %{"$" => %{}, "_" => "Hello world!"}
          }
        }
      }

  ### XML attributes and comments

  Both XML attributes and comments are mapped as well:

      iex> xml = """
      ...> <?xml version="1.0" encoding="UTF-8"?>
      ...> <post id="1">
      ...>   <title>Hello world!</title>
      ...>   <stats>
      ...>     <visits type="integer">1000</visits>
      ...>     <likes type="integer">3</likes>
      ...>   </stats>
      ...> </post>
      ...> """
      iex> XMax.from_xml(xml)
      %{
        "post" => %{
          "$" => %{"id" => '1'},
          "_" => %{
            "stats" => %{
              "$" => %{},
              "_" => %{
                "likes" => %{"$" => %{"type" => 'integer'}, "_" => "3"},
                "visits" => %{"$" => %{"type" => 'integer'}, "_" => "1000"}
              }
            },
            "title" => %{"$" => %{}, "_" => "Hello world!"}
          }
        }
      }

  ### Empty XML nodes

  Empty XML nodes are parsed as empty maps:

      iex> xml = """
      ...> <?xml version="1.0" encoding="UTF-8"?>
      ...> <post>
      ...>   <author/>
      ...>   <body>Hello world!</body>
      ...>   <footer></footer>
      ...> </post>
      ...> """
      iex> XMax.from_xml(xml)
      %{
        "post" => %{
          "$" => %{},
          "_" => %{
            "author" => %{"$" => %{}, "_" => %{}},
            "body" => %{"$" => %{}, "_" => "Hello world!"},
            "footer" => %{"$" => %{}, "_" => %{}}
          }
        }
      }

  ### Casting

  The type casting of the values is delegated to the developer.
  '''
  @spec from_xml(String.t) :: map
  def from_xml(xml) do
    xml
    |> :erlang.bitstring_to_list()
    |> :xmerl_scan.string(space: :normalize, comments: false)
    |> elem(0)
    |> parse_record()
  end

  defp parse_record([]), do: %{}
  defp parse_record([head]), do: parse_record(head)

  defp parse_record([head | tail]),
    do: head |> parse_record() |> merge_records(parse_record(tail))

  defp parse_record({:xmlText, _, _, _, value, _}), do: value |> to_string() |> String.trim()

  defp parse_record({:xmlElement, name, _, _, _, _, _, attributes, value, _, _, _}) do
    case length(attributes) do
      0 -> %{"#{name}" => %{"$" => %{}, "_" => parse_record(value)}}
      _ -> %{"#{name}" => %{"$" => parse_attributes(attributes), "_" => parse_record(value)}}
    end
  end

  defp parse_attributes([head]), do: head |> parse_attribute()

  defp parse_attributes([head | tail]),
    do: head |> parse_attribute() |> merge_records(parse_attributes(tail))

  defp parse_attribute({:xmlAttribute, name, _, _, _, _, _, _, value, _}),
    do: %{"#{name}" => value}

  defp merge_records(r, ""), do: r # Spaces between tags are normalized but parsed as
  defp merge_records("", r), do: r # empty xmlText elements.
  defp merge_records(r1, r2) when is_binary(r1) and is_binary(r2), do: r1 <> r2
  defp merge_records(r1, r2), do: Map.merge(r1, r2, fn _, v1, v2 -> List.flatten([v1, v2]) end)

end
