defmodule Compilador do

  def main(args) do
    IO.puts args
    case args do
       ["-h"] -> help() |> IO.puts();
       [path] -> if path =~ ".c", do: compile(path, :no_output), else: errors(1) |> IO.puts;
       ["-st", path] -> compile(path, :gen_asm); #órden de generar asm
       ["-lt", path] -> compile(path, :show_token); #muestra la lista de tokens
       ["-aa", path] -> compile(path, :show_ast); #muestra el arbol AST
       ["-o", path, new_name] ->compile(path, new_name); #se recibe un nuevo nombre en vez de átomo
       _ -> errors(1) |> IO.puts;
            errors(1)
     end
   end

   def compile(path, flag_or_name) do
     if path =~ ".c" and File.exists?(path) do
       IO.puts "Valid path" <> path
       #Llamamos al organizador
       manager(File.read!(path), path, flag_or_name);
      else
        errors(3) |> IO.puts;
        errors(3);
      end
   end

   def help() do
     "
     Uso:\n ./gremlis-compiler nombre del archivo.c | [option] nombre del archivo.c\n
     \b -lt      Muestra Tokens.
     \b -st      Muestra el Árbol Sintáctico.
     \b -sa      Genera el código en ensamblador (x86).
     \b -o [nombre del archivo] [nombre_ejecutable] Especifica el nombre del ejecutable a generar.
     "
   end

   def errors(num) do
      case num do
        1 -> "Compilador de C. Escriba -h para la ayuda." #no hay argumento
        2 -> "Comando(s) no válido. Escriba -h para la ayuda." #mensaje de error
        3 -> "Archivo inválido o no existe en el directorio." #mensaje de archivo inexistente
      end
    end

  def manager(file, path, opt) do
  #Utilizando "with" se procesa el archivo. Si hay error deja de hacer la compilación.
  with  {:ok, tok} <- Lexer.scan_word(file, opt),
        {:ok , ast} <- Parser.parse_token_list(tok, opt)
        do
        IO.puts("Finalizó la compilación de forma exitosa.")
  else
  #Se muestra el motivo del error o la salida de la opción seleccionada al compilar
        {:error, error} -> IO.puts(error)
        {:only_tokens, _} -> IO.puts("Lista de tokens.")
        {:only_ast, _} -> IO.puts("Árbol Sintáctico.")
      end
  end

end
