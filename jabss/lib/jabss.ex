defmodule Jabss do
  @moduledoc """
  Just A Bunch of Shell Scripts CI/CD
  """

  @conf_file_name "jabss.yaml"
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
  Renders a template based on the args.

  ### Examples

  ```
  Jabss.exec_tmpl( %{ auth: "foobar" }, "Auth is {{auth}}" )
  ```
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

  @doc """
  Opens a new log file. Uses the config from `conf_file/1` by default, and 
  fetches the log subdir from the config key `logs.dir`.
  """
  def open_new_log() do
    open_new_log( &conf_file/0 )
  end

  def open_new_log( fetch_conf_callback )
    when is_function( fetch_conf_callback, 0 ) do
    conf = fetch_conf_callback.()
    base_path = conf[ "logs" ][ "dir" ]

    run_id = get_run_id_from_environment()
    full_path = Path.join([
      base_path,
      run_id,
      "log.json_list"
    ])

    fh = File.open!( full_path, [ :write ] )
    log( fh, "Begin" )
    { :ok, fh, full_path, run_id }
  end

  @doc """
  Writes a log entry to `file`. It can be a full file path, a PID (from 
  `File.open()`), or an atom for `:stdio`.

  Note that any newlines in the log message will be replaced with `\n`, and 
  double quotes will be replaced with `\"`.
  """
  def log( file, msg )
    when is_binary( file )
  do
    fh = File.open!( file, :append )
    log( fh, msg )
    File.close( fh )

    :ok
  end

  def log( file, msg )
    when is_pid( file ) or is_atom( file )
  do
    now_iso8601 = DateTime.now!( "Etc/UTC" )
      |> DateTime.to_iso8601()

    msg = Regex.replace( ~r/"/, msg, "\\\"", multiline: true )
    msg = Regex.replace( ~r/\n/, msg, "\\n", multiline: true )

    IO.write( file,
      "{ \"dt\": \"#{now_iso8601}\", \"msg\": \"#{msg}\" }\n" )
    :ok
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

  defp get_run_id_from_environment() do
    System.get_env( @env_run_id )
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
      logs: %{
        dir: default_log_dir(),
      },
    }
    yaml_conf = Ymlr.document!( conf, sort_maps: true )

    File.write!( path, yaml_conf )
    parse_conf_file( path )
  end

  defp default_log_dir() do
    :filename.basedir( :user_log, "jabss" )
  end
end
