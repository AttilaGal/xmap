defmodule XMaxTest do
  use ExUnit.Case, async: true
  doctest XMax

  test "parses empty nodes as empty maps" do
    xml = """
    <comments>
      <comment>
        <author/>
        <body>Hello world!</body>
        <footer></footer>
      </comment>
      <comment></comment>
      <comment/>
    </comments>
    """

    map = XMax.from_xml(xml)

    assert map == %{
             "comments" => %{
               "$" => %{},
               "_" => %{
                 "comment" => [
                   %{
                     "$" => %{},
                     "_" => %{
                       "author" => %{"$" => %{}, "_" => %{}},
                       "body" => %{"$" => %{}, "_" => "Hello world!"},
                       "footer" => %{"$" => %{}, "_" => %{}}
                     }
                   },
                   %{"$" => %{}, "_" => %{}},
                   %{"$" => %{}, "_" => %{}}
                 ]
               }
             }
           }
  end

  test "parses HTML special entities" do
    xml = """
    <comment>
      <author>Fernando Tapia</author>
      <body>&quot;Hello world!&quot;</body>
    </comment>
    """

    map = XMax.from_xml(xml)

    assert map == %{
             "comment" => %{
               "$" => %{},
               "_" => %{
                 "author" => %{"$" => %{}, "_" => "Fernando Tapia"},
                 "body" => %{"$" => %{}, "_" => "\"Hello world!\""}
               }
             }
           }
  end

  test "parses CDATA" do
    xml = """
    <?xml version="1.0" encoding="UTF-8" ?>
    <post>
      <title>Hello!</title>
      <body><![CDATA[Hello world!]]></body>
    </post>
    """

    map = XMax.from_xml(xml)

    assert map == %{
             "post" => %{
               "$" => %{},
               "_" => %{
                 "body" => %{"$" => %{}, "_" => "Hello world!"},
                 "title" => %{"$" => %{}, "_" => "Hello!"}
               }
             }
           }
  end

end
