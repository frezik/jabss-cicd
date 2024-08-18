import Jabss


{ options, _, _ } = System.argv()
  |> OptionParser.parse( switches: [
    conf: :string,
  ])
conf = conf_file( options[ :conf ] )
IO.inspect( conf )
