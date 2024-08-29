defmodule LogTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "Basic log" do
    assert capture_io( fn -> Jabss.log( :stdio, "foo" ) end )
      |> String.match?( ~r/"msg": "foo"/ )
  end

  test "Log with embedded quotes" do
    assert capture_io( fn -> Jabss.log( :stdio, "foo\"bar\"" ) end )
      |> String.match?( ~r/"msg": "foo\\"bar\\""/ )
  end

  test "Log with embedded newlines" do
    assert capture_io( fn -> Jabss.log( :stdio, "foo\nbar" ) end )
      |> String.match?( ~r/"msg": "foo\\nbar"/ )
  end

  test "Log with embedded quotes and newlines" do
    assert capture_io( fn -> Jabss.log( :stdio, "foo\n\"bar\"" ) end )
      |> String.match?( ~r/"msg": "foo\\n\\"bar\\""/ )
  end

  test "Log with multiple embedded newlines" do
    assert capture_io( fn -> Jabss.log( :stdio, "foo\nbar\nbaz" ) end )
      |> String.match?( ~r/"msg": "foo\\nbar\\nbaz"/ )
  end
end
