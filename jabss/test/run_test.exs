defmodule RunTest do
  use ExUnit.Case
  doctest Jabss

  test "Run script" do
    assert Jabss.run( "test_files/run_test.json" )
  end
end
