defmodule Scanner do
  def fix_format(source_code) do
    Regex.split(~r/\s+/, String.trim(source_code))
  end
  #Elimina los saltos de linea antes y despues
end