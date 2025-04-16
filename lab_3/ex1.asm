# Nome: Caio Ariel Cardoso Saraiva	RA: 10439611
# Nome: Isabela Hissa Pinto	RA: 10441873
# Nome: Kaique Barros Paiva	RA: 10441787

.data
    msg_n:         .asciiz "Digite a quantidade de numeros: "        # Mensagem para solicitar o tamanho do vetor
    erro_n:        .asciiz "A quantidade tem que ser maior que 0.\n" # Mensagem de erro se n <= 0
    erro_alocacao: .asciiz "Erro na alocacao de memoria.\n"
    msg_valor:     .asciiz "Digite um numero: "                      # Mensagem para ler cada número
    msg_resultado: .asciiz "\nNumeros ordenados: "                   # Mensagem para exibir os números ordenados
    msg_trocas:    .asciiz "\nTotal de trocas realizadas: "          # Mensagem para mostrar total de trocas
    espaco:        .asciiz " "                                       # Espaço para separar os números na impressão

.text

main:

# Leitura de n (quantidade de números)
le_n:
    li $v0, 4
    la $a0, msg_n
    syscall                      # Imprime "Digite a quantidade de numeros:"

    li $v0, 5
    syscall                      # Lê inteiro do usuário
    move $s1, $v0                # Armazena em $s1 (n)

    blez $s1, erro_n_invalido    # Se n <= 0, vai para erro

    # Aloca vetor dinamicamente (n * 4 bytes)
    mul $a0, $s1, 4              # Calcula tamanho em bytes
    li $v0, 9
    syscall                      # Aloca memória
    move $s0, $v0                # $s0 = ponteiro para início do vetor

    beqz $s0, erro_aloca         # Se $s0 == 0, falha de alocação

    li $t0, 0                    # Contador i = 0

# Leitura dos n números e armazenamento no vetor
leitura_loop:
    bge $t0, $s1, fim_leitura    # Se i >= n, fim da leitura

    li $v0, 4
    la $a0, msg_valor
    syscall                      # Imprime "Digite um numero:"

    li $v0, 5
    syscall                      # Lê o número
    # Calcula endereço: base + i * 4
    mul $t1, $t0, 4
    add $t2, $s0, $t1
    sw $v0, 0($t2)               # Armazena número no vetor

    addi $t0, $t0, 1             # i++
    j leitura_loop               # Repete

fim_leitura:
    # Chama a função bubble sort
    move $a0, $s0                # Endereço do vetor
    move $a1, $s1                # Tamanho do vetor
    jal bubble                   # Chamada de função
    move $s2, $v0                # Armazena retorno (total de trocas) em $s2

    # Imprime vetor ordenado
    li $v0, 4
    la $a0, msg_resultado
    syscall

    li $t0, 0                    # i = 0

# Loop de impressão do vetor
print_loop:
    bge $t0, $s1, imprime_trocas # Se i >= n, vai imprimir trocas

    mul $t1, $t0, 4
    add $t2, $s0, $t1
    lw $a0, 0($t2)               # Carrega A[i]
    li $v0, 1
    syscall                      # Imprime número

    li $v0, 4
    la $a0, espaco
    syscall                      # Imprime espaço

    addi $t0, $t0, 1             # i++
    j print_loop

# Imprime quantidade de trocas
imprime_trocas:
    li $v0, 4
    la $a0, msg_trocas
    syscall

    move $a0, $s2                # Carrega total de trocas
    li $v0, 1
    syscall                      # Imprime total de trocas

    # Encerra o programa
    li $v0, 10
    syscall

# ---------------------------------------------
# Função bubble sort: recebe base do vetor ($a0) e tamanho ($a1)
# Retorna em $v0 a quantidade de trocas feitas
bubble:
    addi $sp, $sp, -8
    sw $ra, 0($sp)               # Salva endereço de retorno
    sw $s0, 4($sp)               # Salva $s0 (caso seja usado na main)

    li $t6, 0                    # Contador de trocas

    li $t0, 0                    # i = 0
for_i:
    sub $t7, $a1, $t0
    addi $t7, $t7, -1
    blez $t7, finaliza_bb        # Se (n - i - 1) <= 0, fim

    li $t1, 0                    # j = 0
for_j:
    sub $t8, $a1, $t0
    addi $t8, $t8, -1
    bge $t1, $t8, end_for_j      # Se j >= (n - i - 1), fim da iteração j

    # A[j] e A[j+1]
    mul $t2, $t1, 4
    add $t3, $a0, $t2
    lw $t4, 0($t3)               # A[j]
    lw $t5, 4($t3)               # A[j+1]

    ble $t4, $t5, pula_troca     # Se A[j] <= A[j+1], não troca

    # Troca os valores
    sw $t5, 0($t3)
    sw $t4, 4($t3)
    addi $t6, $t6, 1             # Incrementa contador de trocas

pula_troca:
    addi $t1, $t1, 1             # j++
    j for_j

end_for_j:
    addi $t0, $t0, 1             # i++
    j for_i

finaliza_bb:
    move $v0, $t6                # Retorna total de trocas
    lw $ra, 0($sp)               # Restaura $ra
    lw $s0, 4($sp)               # Restaura $s0
    addi $sp, $sp, 8
    jr $ra                       # Retorna

# ---------------------------------------------
# Tratamento de erro: n inválido (<= 0)
erro_n_invalido:
    li $v0, 4
    la $a0, erro_n
    syscall
    j le_n

# Tratamento de erro: falha de alocação
erro_aloca:
    li $v0, 4
    la $a0, erro_alocacao
    syscall
    li $v0, 10
    syscall