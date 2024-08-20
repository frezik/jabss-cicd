import Jabss


{ subcommand, other_args } = if length( System.argv() ) > 0 do
  { hd( System.argv() ), tl( System.argv() ) }
else
  { "help", [] }
end

subcommand_full_name = "jabss-" <> subcommand
System.cmd( subcommand_full_name, other_args )
