defmodule BasicConfTest do
  use ExUnit.Case
  doctest Jabss

  test "Load config file" do
    assert Jabss.conf_file( "test_files/basic_conf.yaml" )
  end
end
