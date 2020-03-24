defmodule Linker do
  def outputBin(asm, flag, path) do
      {:ok, genExe(asm, flag, path)}
  end

  def genExe(asm , flag , path ) do 
    File.write!(String.replace_trailing(path, ".c", ".s"), asm)
    if flag == :no_output , do: ( write_p(path) ) , else: ( write_p(path, flag) )
  end

  #Escribe en disco el programa con el mismo nombre 
  def write_p(path) do
    program_name = Path.basename(path, ".c")
    dir_name = Path.dirname(path)
    asm_file_path = Path.basename(path, ".c")
    asm_file_path = asm_file_path <> ".s"
    System.cmd("gcc", [asm_file_path, "-o#{program_name}"], cd: dir_name)
    File.rm(asm_file_path)
    IO.puts ("Ejecutable generado, para ver la salida del programa: ./#{program_name}; echo $?")
  end

  #Escribe en disco el programa con un nuevo nombre 
  def write_p(path, flag) do
    dir_name = Path.dirname(path)
    asm_file_path = Path.basename(path, ".c")
    asm_file_path = asm_file_path <> ".s"
    System.cmd("gcc", [asm_file_path, "-o#{flag}"], cd: dir_name)
    File.rm(asm_file_path)
    IO.puts ("Ejecutable generado, para ver la salida del programa: ./#{flag}; echo $?")
  end


end 