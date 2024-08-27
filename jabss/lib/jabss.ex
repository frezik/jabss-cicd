defmodule Jabss do
  @moduledoc """
  Just A Bunch of Shell Scripts CI/CD
  """

  @conf_file_name "jabs.yaml"
  @env_run_id "JABSS_RUN_ID"

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

  @doc """
  """
  def exec_tmpl( tmpl_args, tmpl ) do
    Mustache.render( tmpl, tmpl_args )
  end

  @doc """
  Run the given script.
  """
  def run( run_script_path ) do
    run_id = generate_run_id()
    dirpath = Path.absname( run_script_path )
      |> Path.dirname()

    case parse_script( run_script_path ) do
      { :ok, steps } -> exec_steps( steps, run_id, dirpath )
      { :error, err } -> IO.puts( "Error parsing script: #{err}" )
    end
  end


  defp generate_run_id() do
    UUID.uuid4()
  end

  defp parse_script( path )
    when is_binary( path )
  do
    case File.read( path ) do
      { :ok, json_text } -> parse_json_steps( json_text )
      { :error, err } -> { :error, err }
    end
  end

  defp exec_steps( steps, run_id, dirpath ) do
    set_run_environment( run_id )
    result_steps = Enum.take_while( steps,
      fn step -> exec_step( step, dirpath ) end )
    length( result_steps ) == length( steps )
  end

  defp exec_step( step, dirpath ) do
    _step_name = step[ "name" ]
    step_script = step[ "script" ]

    full_path = Path.join([
      dirpath,
      step_script,
    ])

    { _result, exit_status } = System.cmd( full_path, [] )
    exit_status == 0
  end

  defp set_run_environment( run_id ) do
    System.put_env( @env_run_id, run_id )
  end

  defp parse_json_steps( json_text ) do
    JSON.decode( json_text )
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
