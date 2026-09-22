/*
{Protheus.doc} F0600108()
Atualiza registros da tabela SRA para informar que todos os registros já foram integrados com o APDATA.
@Author     Nairan Alves
@Since	     14/12/2017
@Version    P12.7
@Project    MAN0000007423040_EF_001
@Return	 Nil
*/

User function F0600108()

	If MsgYesNo("Deseja atualizar os registros na do funcionário? Ao confirmar, o sistema entenderá que todos os funcionários já estão integrados com o Apdata","Atenção")
		Processa( { || AtuSRA() })
	EndIf
	
Return

Static function AtuSRA()
	Local cQuery 	:= ""
	Local nCont		:= 0

	cQuery := "	UPDATE "+RetSqlName("SRA")+" SET RA_XINTAPD = 'S' " 
	TcSqlExec( cQuery )
		
	Aviso('Atualização SRA',"Processo executado com sucesso", {'OK'}, 1)
	
Return