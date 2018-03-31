defmodule Bow.Exec do
  @moduledoc """
  Transform files with shell commands

  This module allows executing any external command taking care of temporary path generation and error handling.
  It is as reliable as [erlexec](https://github.com/saleyn/erlexec) module (very!).

  It is also possible to provide custom command timeout. See `exec/4` to see all available options.
  """

  defp default_timeout, do: Application.get_env(:bow, :exec_timeout, 15_000)

  @doc """
  Execute command

  Arguments:
  - `source` - source file to be transformed
  - `target_name` - target file
  - `command` - the command to be executed. Placeholders `${input}` and `${output}` will be replaced with source and target paths

  Options:
  - `:timeout` - time in which the command must return. If it's exceeded the command process will be killed.

  Examples

      # generate image thumbnail from first page of pdf
      def transform(file, :pdf_thumbnail) do
        Bow.Exec.exec file, filename(file, :pdf_thumbnail),
          "convert '${input}[0]' -strip -gravity North -background '#ffffff'" <>
                            " -resize 250x175^ -extent 250x175 -format png png:${output}"
      end

  """
  @spec exec(Bow.t, Bow.t, [String.t], keyword) :: {:ok, Bow.t} | {:error, any}
  def exec(source, target, program, command, opts \\ []) do
    timeout = opts[:timeout] || default_timeout()
    # TODO: use a task that times out with yield_many

    source_path = source.path
    target_path = Plug.Upload.random_file!("bow-exec") <> target.ext

    cmd = Enum.map(command, fn
        {:input, idx} when is_integer(idx) -> "#{source_path}[#{idx}]"
        :input -> source_path
        :output -> target_path
        arg -> arg
      end)

    case System.cmd(program, cmd, stderr_to_stdout: true) do
      {_, 0} ->
        {:ok, Bow.set(target, :path, target_path)}
      {error_message, _exit_code} ->
        {:error, error_message}
    end
  end
end
