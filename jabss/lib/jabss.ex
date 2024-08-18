defmodule Jabss do
  @moduledoc """
  Just A Bunch of Shell Scripts CI/CD
  """

  @conf_file_name "jabs.yaml"

  @doc """
  Check and fetch the configuration file. Parses it as YAML and returns 
  the result. Takes an optional `path` argument for the path to the file.

  By default, uses the user config path for the system. If the conf file 
  does not exist at this path, a default one will be created.

  ## Examples

  ```
  Jabss.conf_file()
  Jabss.conf_file( "/path/to/config.yml" )
  ```

  """
  def conf_file( path \\ nil ) do
    path = if path do
      path
    else
      default_conf_path()
    end

    if File.exists?( path ) do
      parse_conf_file( path )
    else
      File.mkdir_p!( default_conf_dir() )
      fresh_conf_file( path )
    end
  end


  defp default_conf_path() do
    Path.join([
      default_conf_dir(),
      default_conf_name()
    ])
  end

  defp default_conf_name() do
    @conf_file_name
  end

  defp default_conf_dir() do
    :filename.basedir( :user_config, "jabss" )
  end

  defp parse_conf_file( path ) do
    if File.exists?( path ) do 
      YamlElixir.read_from_file!( path )
    else
      raise "Config file does not exist: #{path}"
    end
  end

  defp fresh_conf_file( path ) do
    conf = %{
      auth: %{},
    }
    yaml_conf = Ymlr.document!( conf, sort_maps: true )

    File.write!( path, yaml_conf )
    parse_conf_file( path )
  end
end
