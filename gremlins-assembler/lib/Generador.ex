defmodule Generador do

  def code_gen(ast, flag, path) do
    post_stack = postorden_rec(ast, [])
    asm_string = postorden(ast, "", post_stack)
    if flag == :gen_asm, do: genera_archivo(asm_string, path), else: {:ok, asm_string}
  end
  

  defp postorden_rec({_, value, izquierda ,derecha }, l_rec) do
    l_rec = postorden_rec(izquierda, l_rec)
    l_rec = postorden_rec(derecha, l_rec)
    l_rec ++ [value]
  end

  defp postorden_rec({}, l_rec), do: l_rec;

  #Búsqueda en postorden
  defp postorden({atomo, value, izquierda ,derecha }, code, post_stack) do
    [code, post_stack] = postorden(izquierda, code, post_stack)
    [code, post_stack] = postorden(derecha, code, post_stack)
    post_stack = Enum.drop(post_stack, 1)
    [codigo_gen(atomo, value, code, post_stack ), post_stack];
  end

  defp postorden({}, code, post_stack), do: [code, post_stack];


  def codigo_gen(:program, _, codigo, _) do
    """
    .p2align        4, 0x90
    """ <> codigo 
  end

  def codigo_gen(:function, _, codigo, _) do
    """
        .globl  _main         ## -- Begin function main
    _main:                    ## @main
    """  <> codigo 
  end

def codigo_gen(:constant, value, codigo, post_stack) do
<<<<<<< HEAD
    if "+" in post_stack or "-" in post_stack or "*" in post_stack or "/" in post_stack do 
        if List.first(post_stack) == "+" or List.first(post_stack) == "-" or List.first(post_stack) == "*" or List.first(post_stack) == "/" or List.first(post_stack) == "~"  or List.first(post_stack) == "!" do 
            codigo <> """
                movl $#{value},%eax
            """
        else 
            codigo <> """
                mov  $#{value}, %eax
                push    %rax
            """
        end  
    else
      codigo <> """
          movl $#{value},%eax
      """
    end
=======
    if List.first(post_stack) == "+" 
        or List.first(post_stack) == "-" 
        or List.first(post_stack) == "*" 
        or List.first(post_stack) == "/" 
        or List.first(post_stack) == "~"  
        or List.first(post_stack) == "!" do 
        codigo <> """
            movl $#{value},%eax
        """
    else 
        codigo <> """
            mov  $#{value}, %rax
            push    %rax
        """
    end  
>>>>>>> refs/remotes/origin/master
end

  def codigo_gen(:negation_Reserveword, _, codigo, _) do
    codigo <> """
        neg  %eax
    """
  end

  def codigo_gen(:logicalNeg, _, codigo, _) do
    codigo <> """
        cmpl     $0, %eax
        movl     $0, %eax
        sete    %al
    """
  end

  def codigo_gen(:return_Reserveword, _, codigo, _) do
    codigo <> """
        ret
    """
  end

  def codigo_gen(:bitewise_Reserveword, _, codigo,post_stack) do
     if List.first(post_stack) == "return" do
       codigo <> """
           not     %eax
       """
     else
       codigo <> """
           not     %eax
           push    %eax
       """
     end

  end

  # Operadores binarios 3a entrega

  # Operador "-"
  def codigo_gen(:min_Reserveword, _, codigo, _) do
     codigo <> """
        pop     %rcx
        sub     %rax, %rcx
        mov     %rcx, %rax
      """
  end

  # Operador "+"
  def codigo_gen(:add_Reserveword, _, codigo, _) do
     codigo <> """
<<<<<<< HEAD
          pop     %rcx
          add     %rcx, %rax
=======
        pop    %rcx
        add    %rcx, %rax
>>>>>>> refs/remotes/origin/master
      """
  end

  # Operador "*"
  def codigo_gen(:multiplication_Reserveword, _, codigo, _) do
      codigo <> """
<<<<<<< HEAD
          pop    %rcx
          imul    %rcx, %rax
=======
        pop    %rcx
        imul   %rcx, %rax
>>>>>>> refs/remotes/origin/master
      """
  end

  #Operador "/"
  def codigo_gen(:division_Reserveword, _, codigo, _) do
    codigo <> """
<<<<<<< HEAD
        pop     %rcx
        div     %rcx
=======
        pop   %rcx
        div   %rcx
    """
  end

  #Operadores binarios 4ta entrega


  # Operador binario "&&"
  def codigo_gen(:logicalAnd_Reserveword, _, codigo, _) do
    #  Con Regex.scan se escanea el codigo para ver si cumple con la expresion regular 
    #  que contiene la clausula And
    list1 = Regex.scan(~r/clause_and\d{1,}/, codigo)
    list2 = Regex.scan(~r/clause_and\d{1,}/, codigo)
    number = Integer.to_string(length(list1) + length(list2) + 1)

    codigo <>
      """
                cmp $0, %rax
                jne clause_and#{num}
                jmp end_and#{num}
            clause_and#{num}:
                cmp $0, %rax
                mov $0, %rax
                setne %al
            end_and#{num}:
      """
  end

  # Operador binario "||"
  def codigo_gen(:logicalOr_Reserveword, _, codigo, _) do
    # Con Regex.scan se escanea el codigo para ver si cumple con la expresion regular 
    #  que contiene la clausula Or
    list1 = Regex.scan(~r/clause_or\d{1,}/, codigo)
    list2 = Regex.scan(~r/clause_or\d{1,}/, codigo)
    number = Integer.to_string(length(list1) + length(list2) + 1)

    codigo <>
      """
                cmp $0, %rax
                je clause_or#{num}
                mov $1,%rax
                jmp end_or#{num}
            clause_or#{num}:
                cmp $0, %rax
                mov $0, %rax
                setne %al
            end_or#{num}:
      """
  end


  # Operador "=="
  def codigo_gen(:equalTo_Reserveword, _, codigo, _) do
      codigo <> """
          push %rax
          pop %rbx
          cmp %rax, %rbx
          mov $0, %rax
          sete %al
      """
  end

  # Operador "!="
  def codigo_gen(:notEqualTo_Reserveword, _, codigo, _) do
    codigo <> """
        push %rax
        pop %rbx
        cmp %rax, %rbx
        mov $0, %rax
        setne %al
    """
  end

  # Operador "<"
  def code_gen(:lessThan_Reserveword, _, codigo, _) do
    codigo <> """
        push %rax
        pop %rbx
        cmp %rax, %rbx
        mov $0, %rax
        setl %al
    """
  end

  # Operador "<="
  def code_gen(:lessEqual_Reserveword, _, codigo, _) do
    codigo <> """
        push %rax
        pop %rbx
        cmp %rax, %rbx
        mov $0, %rax
        setle %al
    """
  end

  # Operador ">"
  def code_gen(:greaterThan_Reserveword, _, codigo, _) do
    codigo <> """
        push %rax
        pop %rbx
        cmp %rax, %rbx
        mov $0, %rax
        setg %al
>>>>>>> refs/remotes/origin/master
    """
  end

  # Operador ">="
  def code_gen(:greaterEqual_Reserveword, _, codigo, _) do
    codigo <> """
        push %rax
        pop %rbx
        cmp %rax, %rbx
        mov $0, %rax
        setge %al
    """
  end
  #######################################################################################

  def genera_archivo(code,path) do
    asm_path = String.replace_trailing(path, ".c", ".s")
    File.write!((asm_path), code)
    {:only_asm, "Archivo ensamblador generado correctamente,  ir a ruta: " <> asm_path}
  end

end 