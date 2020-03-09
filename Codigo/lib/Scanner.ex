defmodule Scanner do
  #el parser se encargará de mandar error si no se encuentra "main"
  def fix_format(source_code) do
    Regex.split(~r/\s+/, String.trim(source_code))
  end
  #borrara los saltos de linea antes y despues
end