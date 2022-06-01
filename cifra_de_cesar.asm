.data
	#LISTA DE MENSAGENS AO USU�RIO
	msgBemVindo: .asciiz "\n##########################################################################\nBEM-VINDO - PROGRAMA CIFRA DE C�SAR Assembly MIPS32\nAutor: �derson Renan de Bomfim\nAno: 2022\nLicense: GNU GPL v3.0\nC�digo Fonte:github.com/edersonRB/cifra_de_cesar_assembly_mips32\n---\nO programa n�o trata todos os erros para o caso das entradas estarem\nfora dos padr�es estabelecidos pela documenta��o\n(e refor�ados pelas mensagens ao usu�rio durante o uso)\nEntrada de op��es do menu: n�meros {0,1,2,3}\nEntrada de chaves criptogr�ficas (inclusive dentro dos arquivos): n�meros inteiros de 0 � 94\nCaracteres v�lidos na frase de entrada:\n!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~\n##########################################################################\n"
	msgMenu: .asciiz "\n=======MENU=======\n  1 - Cifrar\n  2 - Decifrar\n  3 - Entrada por arquivo\n  0 - Sair\n"
	  msgCifrar: .asciiz "Informe o texto a ser CIFRADO: "
	    msgChaveCifra: .asciiz "Informe a chave para cifrar: "
	  msgDecifrar: .asciiz "Informe o texto a ser DECIFRADO: "
	    msgChaveDecifra: .asciiz "Informe a chave com que a mensagem foi cifrada: "
	  msgArquivo: .asciiz "ATEN��O: o arquivo de entrada deve estar na mesma pasta do\nexecut�vel do MARS e deve sempre ter apenas 1 linha contendo:\nA op��o (0 para cifrar ou 1 para decifrar), a chave de\ncriptografia (seja para cifrar ou decifrar a mensagem)\ne em seguida a mensagem, os 3 separados por espa�os\nINFORME O NOME DO ARQUIVO (com a extens�o): \n"
	    msgSaidaArquivo: .asciiz "\nEscrito no arquivo \"cesar_output.txt\"\n"
	  msgSair: .asciiz "Saindo...\n"
	msgOpInvalida: .asciiz "Op��o inv�lida!\n"
	msgCaracterInvalido: .asciiz "Possui caract�res inv�lidos!\n"
	
	#Lugar na mem�ria para armazenar a string do usu�rio que deve possuir at� 1022 caracteres
	input: .space 1024	#1022 caracteres + LF + 0 = 1022 espa�os necess�rios	
	
	nomeArquivoSaida: .asciiz "cesar_output.txt"
	nomeArquivo: .space 1024#nome do arquivo digitado pelo usu�rio
	buffer: .space 2048	#espa�o para ler o arquivo, ao final ir� armazenar somente a primeira linha
	 #bufferChave: .space 2048#espa�o para ler a chave de criptografia
	 #bufferOpcao: .space 2048#espa�o para ler a op��o
	
	newLine: .asciiz "\n"	#usado para imprimir uma quebra de linha
.text
main:#----------------MAIN------------------#
	la $a0,msgBemVindo
	jal print
	
	loopMenu: #do
		#imprime mensagem menu
		la $a0, msgMenu
		jal print
	
		#l� op��o do usuario
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
		
		#op��o inv�lida
		la $a0,msgOpInvalida
		jal print
		
	endLoop: bne $s0,$zero,loopMenu
	
	la $a0,msgSair
	jal print

li $v0,10 #fim_programa
syscall
#-----------------CIFRAR--------------------#
cifrar:#op��o 1 do menu
	addi $sp,$sp,-4	#pilha -4
	sw $ra,0($sp)	#guarda ra
	
	#imprime mensagem
	la $a0, msgCifrar
	jal print
	#l� a string a ser criptografada
	la $a0, input	#endere�o para armazenar a entrada do usu�rio
	jal scanString	#l� a string digitada para 'input'
	la $s0, input	#s0 guarda a string digitada pelo usuario
	addi $t0,$zero,0#t0 'variavel' de itera��o, iniciando em 0
	
	#imprime a mensagem
	la $a0,msgChaveCifra
	jal print
	#l� a chave de criptografia
	jal scan
	addi $t1,$v0,0
	
	jal updateString
	
	lw $ra,0($sp)	#pilha +4
	addi $sp,$sp,4	#restaura ra da ram
jr $ra
#-----------------DECIFRAR------------------#
decifrar:#op��o 2 do menu
	addi $sp,$sp,-4	#pilha -4
	sw $ra,0($sp)	#guarda ra
	
	#imprime mensagem
	la $a0, msgDecifrar
	jal print
	#l� a string a ser descriptografada
	la $a0, input	#endere�o para armazenar a entrada do usu�rio
	jal scanString	#l� a string digitada para 'input'
	la $s0, input	#s0 guarda a string digitada pelo usuario
	addi $t0,$zero,0#t0 'variavel' de itera��o, iniciando em 0
	
	#imprime a mensagem
	la $a0,msgChaveDecifra
	jal print
	#l� a chave de criptografia
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
arquivo:#op��o 3 do menu
	addi $sp,$sp,-4	#pilha -4
	sw $ra,0($sp)	#guarda ra
	
	#imprime mensagem
	la $a0, msgArquivo
	jal print
	
	#l� a string com o nome do arquivo
	la $a0, nomeArquivo	#endere�o para armazenar a entrada do usu�rio
	jal scanString		#l� a string digitada para 'nomeArquivo'
	
	#REMOVE O CARACTER 10 AO FINAL DO NOME DO ARQUIVO
	la $s0, nomeArquivo	#s0 guarda a string digitada pelo usuario
	jal remove10
	
	###############################################################
  	# Abre arquivo (para leitura)
  	li   $v0, 13		# syscall para abrir arquivo
  	la   $a0, nomeArquivo   # nome do arquivo como argumento
  	li   $a1, 0        	# flag para leitura (flags s�o 0: leitura, 1: escrita)
  	li   $a2, 0        	# modo � ignorado
  	syscall           	# abre o arquivo (endere�o do arquivo retorna em $v0)
  	move $s6, $v0      	# salva o endere�o em $s6 (file descriptor)
  	###############################################################
  	li $v0, 14		#syscall para ler arquivo
  	move $a0,$s6		#endere�o do arquivo a ser lido
  	la $a1, buffer		#buffer de leitura do arquivo
  	addi $a2,$zero,2048	#tamanho m�ximo da leitura do arquivo
  	syscall
  	
  	#DETECTA OPCAO (0 = cifrar,1 = decifrar)
  	la $s0,buffer
  	jal detectaOpcao
  	move $t3, $v1	#guarda a op��o
  	
  	#corta a string
  	la $s0,buffer
  	jal cortaArquivo	#$v1 ir� armazenar o endere�o da string cortada
  	
  	#CALCULA CHAVE CRIPTOGR�FICA
  	move $s0,$v1
  	jal calculaChave	
  	move $t1,$s5
  		
  	#corta a string
  	jal cortaArquivo	#$v1 ir� armazenar o endere�o da string cortada
  		
  	move $s0,$v1
  	
  	#if op��o = 0 ->cifrar if op��o = 1 decifrar
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
  	move $a0, $s6      # endere�o do arquivo para fechar
 	syscall
  	###############################################################
  	#OUTPUT EM ARQUIVO
  	###############################################################
  	# Abre arquivo (para escrita) - o arquivo ser� criado se n�o existir
  	li   $v0, 13       	# syscall para abrir arquivo
  	la   $a0, nomeArquivoSaida	# nome do arquivo de saida
 	li   $a1, 1       	# flag para escrita (flags s�o 0: leitura, 1: escrita)
  	li   $a2, 0       	# modo � ignorado
  	syscall           	# abre o arquivo (endere�o do arquivo retorna em $v0)
  	move $s6, $v0      	# salva o endere�o em $s6 (file descriptor)
  	###############################################################
  	# Escreve no arquivo que foi aberto
  	li   $v0, 15       	# syscall para escrever em arquivo
  	move $a0, $s6		# endere�o do arquivo
  	move $a1, $s0	   	# endere�o da string que ser� escrita no arquivo
  	li   $a2, 2048     	# tamanho pr�-definido da string
  	syscall            	
  	###############################################################
  	#Fecha o arquivo
 	li   $v0, 16       # syscall para fechar arquivo
  	move $a0, $s6      # endere�o do arquivo para fechar
 	syscall
  	###############################################################
	
	lw $ra,0($sp)	#pilha +4
	addi $sp,$sp,4	#restaura ra da ram
jr $ra
#-----------CALCULA-CHAVE-ARQUIVO------------#
calculaChave:	#transforma a parte da string lida do arquivo em um numero inteiro para ser usado
		#como chave criptogr�fica
		#soma os 'n' (d1d2d3...dn) digitos do n�mero multiplicados pelas respectivas pot�ncias de 10
		#referentes as casas em que se encontram:
		# S = d1*10^(n-1) + d2*10^(n-2) + ... + dn*10^(0) 
	addi $sp,$sp,-4	#pilha -4
	sw $ra,0($sp)	#guarda ra
	################################# conta quantos digitos o numero possui
	
	addi $t0,$zero,0	#variavel de itera��o -> i = 0;

	addi $s4,$zero,-1	#se o numero tiver n digitos; $s4 ir� armazenar n-1 para facilitar o c�lculo
	loopDigitos:
    		add $s1, $s0, $t0   	#$s1 = string[i] // -> $ss1 = *(string+i)
   		lb $s2, 0($s1)      	#Carrega o caracter da posi��o $s1 para $s2
   		  		
   		beq $s2,32,exitLoopDigitos	#Sai quando detecta um espa�o
   		
   		add $s4,$s4,1		#cont++
   		
    		addi $t0, $t0, 1    	#i++
    	j loopDigitos		#volta ao inicio do loop
	exitLoopDigitos:
	
	################################# efetua o somat�rio para calcular o numero final
	addi $t0,$zero,0	#variavel de itera��o -> i = 0;
	
	addi $s5,$zero,0	#S = d1*10^(n-1) + d2*10^(n-2) + ... + dn*10^(0) 
	loopChave:
    		add $s1, $s0, $t0   	#$s1 = string[i] // -> $ss1 = *(string+i)
   		lb $s2, 0($s1)      	#Carrega o caracter da posi��o $s1 para $s2
   		  		
   		beq $s2,32,exitLoopChave#Sai quando detecta um espa�o
   	
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
vezes10:	#multiplica $s3 por 10 elevado a $s4 pot�ncia
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
detectaOpcao:	#Detecta a op��o pela entrada de arquivos: 0 = cifrar frase, 1 = decifrar frase,
		#armazena a op��o em $v1, armazenando -1 caso a op��o seja inv�lida
	addi $sp,$sp,-4	#pilha -4
	sw $ra,0($sp)	#guarda ra
	
	addi $s1, $s0, 0   	#$s1 = string[i] // -> $ss1 = *(string+i)
   	lb $s2, 0($s1)      	#Carrega o caracter da posi��o $s1 para $s2
	
	
	#if op = 0 //como 48 � 0 em ascii - cifrar
	bne $s2,48,NotOpCifrar
		addi $v1,$zero,0
		j endDetectaOp
	NotOpCifrar:
	
	#if op = 1 //como 49 � 1 em ascii - decifrar
	bne $s2,49,notOpDecifrar
		addi $v1,$zero,1
		j endDetectaOp
	notOpDecifrar:
	
	#op��o inv�lida (n�o � 0 nem 1)
		addi $v1,$zero,-1
	endDetectaOp:
	
	lw $ra,0($sp)	#pilha +4
	addi $sp,$sp,4	#restaura ra da ram
jr $ra
#-------------CORTA-STRING-ARQUIVO-----------#
cortaArquivo:	#corta o arquivo do in�cio at� primeiro caracter 32 (espa�o) e coloca em $v1
	addi $sp,$sp,-4	#pilha -4
	sw $ra,0($sp)	#guarda ra
	
	addi $t0,$zero,0	#variavel de itera��o -> i = 0;
	
	loopCorta:
    		add $s1, $s0, $t0   	#$s1 = string[i] // -> $ss1 = *(string+i)
   		lb $s2, 0($s1)      	#Carrega o caracter da posi��o $s1 para $s2
   		
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
remove10:	#quando o usu�rio digita o nome do arquivo, a string termina com o caracter 10, por isso �
		#necess�ro remover este caracter para n�o gerar erro na leitura do arquivo
	addi $sp,$sp,-4	#pilha -4
	sw $ra,0($sp)	#guarda ra
	
	addi $t0,$zero,0	#variavel de itera��o -> i = 0;
	
	loop10:
    		add $s1, $s0, $t0   	#$s1 = string[i] // -> $ss1 = *(string+i)
   		lb $s2, 0($s1)      	#Carrega o caracter da posi��o $s1 para $s2
   		  		
   		#substitui por 0 quando detecta o caracter de codigo 10, final da string
   		beq $s2,10,substituir
   		j pular
   		substituir:
   			addi $s2,$zero,0
   			sb $s2 ($s1)	#salva o caracter em $s2 na posi��o $s1 (dentro de $s0)
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
updateString:	#fun��o gen�rica que atualiza a string com base numa chave criptogr�fica, se
		#for chamada da fun��o decifrar a chave � negativada (*-1) antes da chamada
	addi $sp,$sp,-4	#pilha -4
	sw $ra,0($sp)	#guarda ra
	
	addi $t0,$zero,0	#variavel de itera��o -> i = 0;
	
	loop:
    		add $s1, $s0, $t0   	#$s1 = mensagem[i] // -> $ss1 = *(mensagem+i)
   		lb $s2, 0($s1)      	#Carrega o caracter da posi��o $s1 para $s2
   		
   		#sai do loop quando detecta o caracter de codigo 10, final da string
   		beq $s2, 0, exitLoop	#o caracter'NULL' marca o fim da string, em ascii = '0'
    		beq $s2, 10, exitLoop	#o caracter'LF' marca o fim da string, em ascii = '10'
   		
   		#CARACTERES INV�LIDOS
   		#se o caracter atual for < 0, significa que � inv�lido, pois
   		#faz parte da tabela ASCII expandida;
   		#por�m podemos assumir que os caracteres de 0 a 31 e o 127 tamb�m s�o inv�lidos pois 
   		#n�o s�o digit�veis ou imprim�veis (ver tabela ASCII e refer�ncias do relat�rio)126-33+1
   		slti $t2, $s2, 32
   		bne $t2, 0, invalido
   		beq $s2, 127, invalido
    		
    		beq $s2, 32, aposIncremento	#32 � o espa�o, que � aceito como entrada mas n�o � cifrado
    		
    		add $s2, $s2, $t1   	#soma o caracter atual com o valor da chave criptogr�fica
    		
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
    		
    		sb $s2 ($s1)       	#salva o caracter em $s2 na posi��o $s1 (dentro de $s0)
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
scan:#l� um int e armazena-o em $v0
	li $v0,5
	syscall
jr $ra
#----------------LER-STRING-----------------#
scanString:#l� uma string de tamanho 1024 para o espa�o armazenado em $a0 na mem�ria
	li $v0, 8	#syscall para ler string
	li $a1, 1024	#guarda o tamanho da string a ser lida
	syscall
jr $ra
#---------------PRINT-STRING----------------#
print:#imprime a string que est� no endere�o armazenado em $a0
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