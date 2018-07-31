# XMax

[![Build Status](https://travis-ci.org/fertapric/xmax.svg?branch=master)](https://travis-ci.org/fertapric/xmax)

XML to Map converter.

XMax transforms an XML string into a [`Map`](https://hexdocs.pm/elixir/Map.html) containing a collection of pairs
  where the key is the node name and the value is its content.

  XMax was originally forked from XMap. There are 2 notable difference between the packages:

  1) XMax will also map xml attributes. This does however cause for larger mapped objects.
  Attributes are mapped to the `"$"` key, while contents are mapped to the `"_"` key. If you know
  you're never going to need xml attributes, XMap may be a better fit.

  2) XMax does not support atom keys, it's usually not a good idea to generate atoms on the fly.
  So to prevent unexpected memory leaks, this feature has been ommitted


## Examples

Here is an example:

```elixir
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
```


## Installation

Add XMap to your project's dependencies in `mix.exs`:

```elixir
def deps do
  [{:xmax, "~> 1.0"}]
end
```

And fetch your project's dependencies:

```shell
$ mix deps.get
```

## Documentation

Documentation is available at https://hexdocs.pm/xmax

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Attila/xmax. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

### Running tests

Clone the repo and fetch its dependencies:

```shell
$ git clone git@github.com:attilagal/xmax.git
$ cd xmax
$ mix deps.get
$ mix test
```

### Building docs

```shell
$ mix docs
```

## Copyright and License

Copyright 2018 Attila Gal

XMax source code is licensed under the [MIT License](LICENSE).
