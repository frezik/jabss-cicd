defmodule Jabss.CLI do
  def main( args \\ [] ) do
    { subcommand, other_args } = if length( args ) > 0 do
      { hd( args ), tl( args ) }
    else
      { "help", [] }
    end

    case subcommand do
      "help" -> help( other_args )
      _ -> help( other_args )
    end
  end

  def help( _args ) do
    IO.puts(
      """
      jabss - Just A Bunch of Shell Scripts CI/CD

      Commands:
        help - This help screen
      """
    )
  end
end
