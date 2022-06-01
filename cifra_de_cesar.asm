.data
	#LISTA DE MENSAGENS AO USUÁRIO
	msgBemVindo: .asciiz "\n##########################################################################\nBEM-VINDO - PROGRAMA CIFRA DE CÉSAR Assembly MIPS32\nAutor: Éderson Renan de Bomfim\nAno: 2022\nLicense: GNU GPL v3.0\nCódigo Fonte:github.com/edersonRB/cifra_de_cesar_assembly_mips32\n---\nO programa não trata todos os erros para o caso das entradas estarem\nfora dos padrões estabelecidos pela documentação\n(e reforçados pelas mensagens ao usuário durante o uso)\nEntrada de opções do menu: números {0,1,2,3}\nEntrada de chaves criptográficas (inclusive dentro dos arquivos): números inteiros de 0 à 94\nCaracteres válidos na frase de entrada:\n!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~\n##########################################################################\n"
	msgMenu: .asciiz "\n=======MENU=======\n  1 - Cifrar\n  2 - Decifrar\n  3 - Entrada por arquivo\n  0 - Sair\n"
	  msgCifrar: .asciiz "Informe o texto a ser CIFRADO: "
	    msgChaveCifra: .asciiz "Informe a chave para cifrar: "
	  msgDecifrar: .asciiz "Informe o texto a ser DECIFRADO: "
	    msgChaveDecifra: .asciiz "Informe a chave com que a mensagem foi cifrada: "
	  msgArquivo: .asciiz "ATENÇÃO: o arquivo de entrada deve estar na mesma pasta do\nexecutável do MARS e deve sempre ter apenas 1 linha contendo:\nA opção (0 para cifrar ou 1 para decifrar), a chave de\ncriptografia (seja para cifrar ou decifrar a mensagem)\ne em seguida a mensagem, os 3 separados por espaços\nINFORME O NOME DO ARQUIVO (com a extensão): \n"
	    msgSaidaArquivo: .asciiz "\nEscrito no arquivo \"cesar_output.txt\"\n"
	  msgSair: .asciiz "Saindo...\n"
	msgOpInvalida: .asciiz "Opção inválida!\n"
	msgCaracterInvalido: .asciiz "Possui caractéres inválidos!\n"
	
	#Lugar na memória para armazenar a string do usuário que deve possuir até 1022 caracteres
	input: .space 1024	#1022 caracteres + LF + 0 = 1022 espaços necessários	
	
	nomeArquivoSaida: .asciiz "cesar_output.txt"
	nomeArquivo: .space 1024#nome do arquivo digitado pelo usuário
	buffer: .space 2048	#espaço para ler o arquivo, ao final irá armazenar somente a primeira linha
	 #bufferChave: .space 2048#espaço para ler a chave de criptografia
	 #bufferOpcao: .space 2048#espaço para ler a opção
	
	newLine: .asciiz "\n"	#usado para imprimir uma quebra de linha
.text
main:#----------------MAIN------------------#
	la $a0,msgBemVindo
	jal print
	
	loopMenu: #do
		#imprime mensagem menu
		la $a0, msgMenu
		jal print
	
		#lê opção do usuario
		jal scan
		addi $s0,$v0,0
		
		#if s0 == 1
		bne $s0,1,endIf1
			jal cifrar
			j endLoop
		endIf1:
		
		#else if s0 == 2
		bne $s0,2,endIf2
			jal decifrar
			j endLoop
		endIf2:
		
		#else if s0 == 3
		bne $s0,3,endIf3
			jal arquivo
			j endLoop
		endIf3:
		
		#else if s0 == 0
		beq $s0,0,endLoop
		
		#opção inválida
		la $a0,msgOpInvalida
		jal print
		
	endLoop: bne $s0,$zero,loopMenu
	
	la $a0,msgSair
	jal print

li $v0,10 #fim_programa
syscall
#-----------------CIFRAR--------------------#
cifrar:#opção 1 do menu
	addi $sp,$sp,-4	#pilha -4
	sw $ra,0($sp)	#guarda ra
	
	#imprime mensagem
	la $a0, msgCifrar
	jal print
	#lê a string a ser criptografada
	la $a0, input	#endereço para armazenar a entrada do usuário
	jal scanString	#lê a string digitada para 'input'
	la $s0, input	#s0 guarda a string digitada pelo usuario
	addi $t0,$zero,0#t0 'variavel' de iteração, iniciando em 0
	
	#imprime a mensagem
	la $a0,msgChaveCifra
	jal print
	#lê a chave de criptografia
	jal scan
	addi $t1,$v0,0
	
	jal updateString
	
	lw $ra,0($sp)	#pilha +4
	addi $sp,$sp,4	#restaura ra da ram
jr $ra
#-----------------DECIFRAR------------------#
decifrar:#opção 2 do menu
	addi $sp,$sp,-4	#pilha -4
	sw $ra,0($sp)	#guarda ra
	
	#imprime mensagem
	la $a0, msgDecifrar
	jal print
	#lê a string a ser descriptografada
	la $a0, input	#endereço para armazenar a entrada do usuário
	jal scanString	#lê a string digitada para 'input'
	la $s0, input	#s0 guarda a string digitada pelo usuario
	addi $t0,$zero,0#t0 'variavel' de iteração, iniciando em 0
	
	#imprime a mensagem
	la $a0,msgChaveDecifra
	jal print
	#lê a chave de criptografia
	jal scan
	addi $t1,$v0,0
	addi $t2,$t2,-1	#salva -1
	mult $t1,$t2	#multiplica a chave lida por -1
	mflo $t1	#move from low -> $t1
	
	jal updateString	
	
	lw $ra,0($sp)	#pilha +4
	addi $sp,$sp,4	#restaura ra da ram
jr $ra
#-----------------ARQUIVO------------------#
arquivo:#opção 3 do menu
	addi $sp,$sp,-4	#pilha -4
	sw $ra,0($sp)	#guarda ra
	
	#imprime mensagem
	la $a0, msgArquivo
	jal print
	
	#lê a string com o nome do arquivo
	la $a0, nomeArquivo	#endereço para armazenar a entrada do usuário
	jal scanString		#lê a string digitada para 'nomeArquivo'
	
	#REMOVE O CARACTER 10 AO FINAL DO NOME DO ARQUIVO
	la $s0, nomeArquivo	#s0 guarda a string digitada pelo usuario
	jal remove10
	
	###############################################################
  	# Abre arquivo (para leitura)
  	li   $v0, 13		# syscall para abrir arquivo
  	la   $a0, nomeArquivo   # nome do arquivo como argumento
  	li   $a1, 0        	# flag para leitura (flags são 0: leitura, 1: escrita)
  	li   $a2, 0        	# modo é ignorado
  	syscall           	# abre o arquivo (endereço do arquivo retorna em $v0)
  	move $s6, $v0      	# salva o endereço em $s6 (file descriptor)
  	###############################################################
  	li $v0, 14		#syscall para ler arquivo
  	move $a0,$s6		#endereço do arquivo a ser lido
  	la $a1, buffer		#buffer de leitura do arquivo
  	addi $a2,$zero,2048	#tamanho máximo da leitura do arquivo
  	syscall
  	
  	#DETECTA OPCAO (0 = cifrar,1 = decifrar)
  	la $s0,buffer
  	jal detectaOpcao
  	move $t3, $v1	#guarda a opção
  	
  	#corta a string
  	la $s0,buffer
  	jal cortaArquivo	#$v1 irá armazenar o endereço da string cortada
  	
  	#CALCULA CHAVE CRIPTOGRÁFICA
  	move $s0,$v1
  	jal calculaChave	
  	move $t1,$s5
  		
  	#corta a string
  	jal cortaArquivo	#$v1 irá armazenar o endereço da string cortada
  		
  	move $s0,$v1
  	
  	#if opção = 0 ->cifrar if opção = 1 decifrar
  	beq $t3,0,cifrarArquivo  
  	bne $t3,1,loopMenu	
  	#decifrar arquivo
  		addi $t2,$t2,-1	#salva -1
		mult $t1,$t2	#multiplica a chave lida por -1
		mflo $t1	#move from low -> $t1
  	cifrarArquivo:
  		
  	jal updateString	
  		
  	la $a0,msgSaidaArquivo
  	jal print
  	  	  	
  	###############################################################
	#Fecha o arquivo
 	li   $v0, 16       # syscall para fechar arquivo
  	move $a0, $s6      # endereço do arquivo para fechar
 	syscall
  	###############################################################
  	#OUTPUT EM ARQUIVO
  	###############################################################
  	# Abre arquivo (para escrita) - o arquivo será criado se não existir
  	li   $v0, 13       	# syscall para abrir arquivo
  	la   $a0, nomeArquivoSaida	# nome do arquivo de saida
 	li   $a1, 1       	# flag para escrita (flags são 0: leitura, 1: escrita)
  	li   $a2, 0       	# modo é ignorado
  	syscall           	# abre o arquivo (endereço do arquivo retorna em $v0)
  	move $s6, $v0      	# salva o endereço em $s6 (file descriptor)
  	###############################################################
  	# Escreve no arquivo que foi aberto
  	li   $v0, 15       	# syscall para escrever em arquivo
  	move $a0, $s6		# endereço do arquivo
  	move $a1, $s0	   	# endereço da string que será escrita no arquivo
  	li   $a2, 2048     	# tamanho pré-definido da string
  	syscall            	
  	###############################################################
  	#Fecha o arquivo
 	li   $v0, 16       # syscall para fechar arquivo
  	move $a0, $s6      # endereço do arquivo para fechar
 	syscall
  	###############################################################
	
	lw $ra,0($sp)	#pilha +4
	addi $sp,$sp,4	#restaura ra da ram
jr $ra
#-----------CALCULA-CHAVE-ARQUIVO------------#
calculaChave:	#transforma a parte da string lida do arquivo em um numero inteiro para ser usado
		#como chave criptográfica
		#soma os 'n' (d1d2d3...dn) digitos do número multiplicados pelas respectivas potências de 10
		#referentes as casas em que se encontram:
		# S = d1*10^(n-1) + d2*10^(n-2) + ... + dn*10^(0) 
	addi $sp,$sp,-4	#pilha -4
	sw $ra,0($sp)	#guarda ra
	################################# conta quantos digitos o numero possui
	
	addi $t0,$zero,0	#variavel de iteração -> i = 0;

	addi $s4,$zero,-1	#se o numero tiver n digitos; $s4 irá armazenar n-1 para facilitar o cálculo
	loopDigitos:
    		add $s1, $s0, $t0   	#$s1 = string[i] // -> $ss1 = *(string+i)
   		lb $s2, 0($s1)      	#Carrega o caracter da posição $s1 para $s2
   		  		
   		beq $s2,32,exitLoopDigitos	#Sai quando detecta um espaço
   		
   		add $s4,$s4,1		#cont++
   		
    		addi $t0, $t0, 1    	#i++
    	j loopDigitos		#volta ao inicio do loop
	exitLoopDigitos:
	
	################################# efetua o somatório para calcular o numero final
	addi $t0,$zero,0	#variavel de iteração -> i = 0;
	
	addi $s5,$zero,0	#S = d1*10^(n-1) + d2*10^(n-2) + ... + dn*10^(0) 
	loopChave:
    		add $s1, $s0, $t0   	#$s1 = string[i] // -> $ss1 = *(string+i)
   		lb $s2, 0($s1)      	#Carrega o caracter da posição $s1 para $s2
   		  		
   		beq $s2,32,exitLoopChave#Sai quando detecta um espaço
   	
   		addi $s3,$s2,-48	#converte o caracter atual (ascii) para um digito inteiro
   		
   		#multiplica $s3 * 10^($s4)
   		jal vezes10
   		addi $s4,$s4,-1		#(n-1)--
   		
   		add $s5,$s5,$s3		#soma+=dk*10(n-k)
   		
    		addi $t0, $t0, 1    	#i++
    	j loopChave		#volta ao inicio do loop
	exitLoopChave:
	#sb $a0,nomeArquivo
	
	lw $ra,0($sp)	#pilha +4
	addi $sp,$sp,4	#restaura ra da ram
jr $ra
#-------------------VEZES-10----------------------#
vezes10:	#multiplica $s3 por 10 elevado a $s4 potência
	addi $sp,$sp,-8	#pilha -8
	sw $ra,0($sp)	#guarda ra
	sw $s4,4($sp)	#guarda s4
		
	loopX10:
	addi $t7,$zero,10	#registrador apenas para armazenar o 10
	beq $s4,0,endLoopX10
		mult $s3,$t7	#s3*=10 lo = s3*10
		mflo $s3	#	s3 = lo
			
		addi $s4,$s4,-1	#n - -
	j loopX10
	endLoopX10:
		
	lw $ra,0($sp)	#restaura ra da ram
	lw $s4,4($sp)	#restaura s4 da ram
	addi $sp,$sp,8	#pilha +8
jr $ra
#----------------DETECTA-OPCAO---------------#
detectaOpcao:	#Detecta a opção pela entrada de arquivos: 0 = cifrar frase, 1 = decifrar frase,
		#armazena a opção em $v1, armazenando -1 caso a opção seja inválida
	addi $sp,$sp,-4	#pilha -4
	sw $ra,0($sp)	#guarda ra
	
	addi $s1, $s0, 0   	#$s1 = string[i] // -> $ss1 = *(string+i)
   	lb $s2, 0($s1)      	#Carrega o caracter da posição $s1 para $s2
	
	
	#if op = 0 //como 48 é 0 em ascii - cifrar
	bne $s2,48,NotOpCifrar
		addi $v1,$zero,0
		j endDetectaOp
	NotOpCifrar:
	
	#if op = 1 //como 49 é 1 em ascii - decifrar
	bne $s2,49,notOpDecifrar
		addi $v1,$zero,1
		j endDetectaOp
	notOpDecifrar:
	
	#opção inválida (não é 0 nem 1)
		addi $v1,$zero,-1
	endDetectaOp:
	
	lw $ra,0($sp)	#pilha +4
	addi $sp,$sp,4	#restaura ra da ram
jr $ra
#-------------CORTA-STRING-ARQUIVO-----------#
cortaArquivo:	#corta o arquivo do início até primeiro caracter 32 (espaço) e coloca em $v1
	addi $sp,$sp,-4	#pilha -4
	sw $ra,0($sp)	#guarda ra
	
	addi $t0,$zero,0	#variavel de iteração -> i = 0;
	
	loopCorta:
    		add $s1, $s0, $t0   	#$s1 = string[i] // -> $ss1 = *(string+i)
   		lb $s2, 0($s1)      	#Carrega o caracter da posição $s1 para $s2
   		
   		#move $a0,$s2
   		#jal println
   		  		
   		#substitui por 10 quando detecta o caracter de codigo 13 marcando o final da linha
   		beq $s2,32,cortar
   		j pularCortar
   		cortar:
   			addi $t0, $t0, 1
   			add $s1, $s0, $t0
   			add $v1, $zero, $s1
   			#jal print
   			j exitLoopCorta
		pularCortar:
    		
    		addi $t0, $t0, 1    	#i++
    	j loopCorta		#volta ao inicio do loop
	exitLoopCorta:
	#sb $a0,nomeArquivo
	
	lw $ra,0($sp)	#pilha +4
	addi $sp,$sp,4	#restaura ra da ram
jr $ra
#-------------REMOVE-CARACTER-10------------#
remove10:	#quando o usuário digita o nome do arquivo, a string termina com o caracter 10, por isso é
		#necessáro remover este caracter para não gerar erro na leitura do arquivo
	addi $sp,$sp,-4	#pilha -4
	sw $ra,0($sp)	#guarda ra
	
	addi $t0,$zero,0	#variavel de iteração -> i = 0;
	
	loop10:
    		add $s1, $s0, $t0   	#$s1 = string[i] // -> $ss1 = *(string+i)
   		lb $s2, 0($s1)      	#Carrega o caracter da posição $s1 para $s2
   		  		
   		#substitui por 0 quando detecta o caracter de codigo 10, final da string
   		beq $s2,10,substituir
   		j pular
   		substituir:
   			addi $s2,$zero,0
   			sb $s2 ($s1)	#salva o caracter em $s2 na posição $s1 (dentro de $s0)
   			j exitLoop10
		pular:
    		
    		addi $t0, $t0, 1    	#i++
    	j loop10		#volta ao inicio do loop
	exitLoop10:
	#sb $a0,nomeArquivo
	
	lw $ra,0($sp)	#pilha +4
	addi $sp,$sp,4	#restaura ra da ram
jr $ra
#---------------UPDATE-STRING---------------#
updateString:	#função genérica que atualiza a string com base numa chave criptográfica, se
		#for chamada da função decifrar a chave é negativada (*-1) antes da chamada
	addi $sp,$sp,-4	#pilha -4
	sw $ra,0($sp)	#guarda ra
	
	addi $t0,$zero,0	#variavel de iteração -> i = 0;
	
	loop:
    		add $s1, $s0, $t0   	#$s1 = mensagem[i] // -> $ss1 = *(mensagem+i)
   		lb $s2, 0($s1)      	#Carrega o caracter da posição $s1 para $s2
   		
   		#sai do loop quando detecta o caracter de codigo 10, final da string
   		beq $s2, 0, exitLoop	#o caracter'NULL' marca o fim da string, em ascii = '0'
    		beq $s2, 10, exitLoop	#o caracter'LF' marca o fim da string, em ascii = '10'
   		
   		#CARACTERES INVÁLIDOS
   		#se o caracter atual for < 0, significa que é inválido, pois
   		#faz parte da tabela ASCII expandida;
   		#porém podemos assumir que os caracteres de 0 a 31 e o 127 também são inválidos pois 
   		#não são digitáveis ou imprimíveis (ver tabela ASCII e referências do relatório)126-33+1
   		slti $t2, $s2, 32
   		bne $t2, 0, invalido
   		beq $s2, 127, invalido
    		
    		beq $s2, 32, aposIncremento	#32 é o espaço, que é aceito como entrada mas não é cifrado
    		
    		add $s2, $s2, $t1   	#soma o caracter atual com o valor da chave criptográfica
    		
    		#CHAVE DE CRIPTOGRAFIA > 0
    		#caso o caractere atual complete um ciclo na tabela ascii, acima do ultimo valor possivel (127)
    		slti $t2, $s2,127
    		beq $t2, 1, aposDecremento
    			addi $s2, $s2, -94
    		aposDecremento:		
    		
    		#CHAVE DE CRIPTOGRAFIA < 0
    		#caso o caractere atual complete um ciclo na tabela ascii, abaixo do ultimo valor aceito (33)
    		slti $t2, $s2,33
    		beq $t2, 0, aposIncremento
    			addi $s2, $s2, 94
    		aposIncremento:
    		
    		sb $s2 ($s1)       	#salva o caracter em $s2 na posição $s1 (dentro de $s0)
    		addi $t0, $t0, 1    	#i++
    		
    	j loop    #volta ao inicio do loop
    	invalido:
    		la $a0,msgCaracterInvalido
    		jal print
    		j aposResultado
	exitLoop:
	
	addi $a0,$s0,0
	jal print
	aposResultado:
	
	lw $ra,0($sp)	#pilha +4
	addi $sp,$sp,4	#restaura ra da ram
jr $ra
#-----------------LER-INT-------------------#
scan:#lê um int e armazena-o em $v0
	li $v0,5
	syscall
jr $ra
#----------------LER-STRING-----------------#
scanString:#lê uma string de tamanho 1024 para o espaço armazenado em $a0 na memória
	li $v0, 8	#syscall para ler string
	li $a1, 1024	#guarda o tamanho da string a ser lida
	syscall
jr $ra
#---------------PRINT-STRING----------------#
print:#imprime a string que está no endereço armazenado em $a0
	addi $sp, $sp,-4	#pilha -4
	sw $a0, 0($sp)		#guarda a0 em pilha

	li $v0, 4
	syscall
	
	lw $a0, 0($sp)		#restaura a0
	addi $sp,$sp,4		#pilha +4
			
jr $ra
#--------------PRINT-INT\n-----------------#
println:#imprime o inteiro armazenado em $a0 e em seguida imprime "\n"
	addi $sp, $sp,-4	#pilha -4
	sw $a0, 0($sp)		#guarda a0 em pilha

	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, newLine
	syscall
	
	lw $a0, 0($sp)		#restaura a0
	addi $sp,$sp,4		#pilha +4
jr $ra