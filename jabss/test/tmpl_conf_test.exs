defmodule TmplConfTest do
  use ExUnit.Case

  test "Output a command templated with the configuration" do
    tmpl = Jabss.conf_file( "test_files/auth_nested_conf.yaml" )
    |> Jabss.exec_tmpl( "-H 'Authorization: Bearer {{auth.slack.token}}'" )

    assert tmpl == "-H 'Authorization: Bearer foobar'"
  end
end
