#Include "Rwmake.ch"
//==========================================================================================
/*/
Rotinas para geracao do CNAB
@author     A.Shibao
@since      18/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================  
*----------------------------------*
User Function AxCadPZW              // Cadastro de caminhos de onde ser�o gravados os arquivos de cnabs
*----------------------------------*

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "PZW"

dbSelectArea("PZW")
dbSetOrder(1)

AxCadastro(cString,"Locais de grava��o CNAB DOS BANCOS - GPE",cVldExc,cVldAlt)

Return    

*----------------------------------*
User Function fValidCNAB()             // funcao para validar os perguntes do cnab obrigatoriamente devem ser iguais
*----------------------------------*

//seta a filial do parametro 4 para o mv_par05 
//If Empty(mv_par05) 
If Empty(mv_par04) //Compatibilizado para Grupo GPEM080R2
    NaoVazio()
Else
	//_cFil_4		:= MV_PAR04
	_cFil_4		:= cFilAnt//Compatibilizado para Grupo GPEM080R2
	
Endif
Return()



*----------------------------------*
User Function GP410ARQ()             // funcao para buscar o local de gravacao do cnab e nomear o arquivo conforme processo.
*----------------------------------*
//DorCnbLoc
//_cFil		:= mv_par05
_cFil		:= cFilant
_cEmp       := cEmpAnt 
 mvRet		:= Alltrim(ReadVar())
 cTime 		:= TIME()
 cSeq       := u_fInfCnab(11) 
 cShSaida   := ""
 nSFilial   := Val(str(GetSx3Cache("RA_FILIAL","X3_TAMANHO")))
 //cSBank     := mv_par30
 cSBank     := mv_par24
 
dbSelectArea("PZW")
dbSetOrder(1)

If PZW->(!DbSeek(_cFil+cSBank)) .And. PZW->(!DbSeek(space(nSFilial)+cSBank)) 
	Alert("Nao foi encontrado nenhum registro de configura��o na tabela PZW", "Avisar a Equipe de TI")
    Return
Else
	If !Empty(PZW->PZW_LOCAL+PZW->PZW_BANCO)
		//Ex: ROTEIRO(MV_PAR01) + FILIAL + DT REFERENCIA(MV_PAR25) + SEQUENCIA + Time + .txt
		//Ex: FOL992016010100001125151.TXT                           ate  26/07/17 foi gerado dessa forma
		//cShSaida := alltrim(PZW->PZW_LOCAL)+alltrim(PZW->PZW_ARQCFG) + alltrim(MV_PAR01) + alltrim(cFilDe) + alltrim(dtoS(mv_par25)) + cSeq + alltrim(StrTran(cTime,":","")) + ".txt"
		//santfol.2re-res-01310011-20170731-151542-ari.oliveira.txt  apos 26/07/17 sera gerado dessa forma
		//cShSaida := alltrim(PZW->PZW_LOCAL)+alltrim(PZW->PZW_ARQCFG) + "-" + alltrim(MV_PAR01) + "-" + alltrim(cFilDe) + "-" + alltrim(dtoS(mv_par25)) + "-" + alltrim(StrTran(cTime,":","")) + "-" + alltrim(substr(cusuario,7,15)) +".txt"
		cShSaida := alltrim(PZW->PZW_LOCAL)+alltrim(PZW->PZW_ARQCFG) + "-" + alltrim(MV_PAR01) + "-" + subs(alltrim(MV_PAR04),16,8) + "-" + alltrim(dtoS(mv_par19)) + "-" + alltrim(StrTran(cTime,":","")) + "-" + alltrim(substr(cusuario,7,15)) +".txt"
		If !Empty(PZW->PZW_ARQCFG)
			If !FILE(PZW->PZW_ARQCFG)
				Help(" ",1,"NOARQPAR")
				Return
			Else	
				cArqent  := alltrim(PZW->PZW_ARQCFG)
			Endif	
		Else
			Alert("Arquivo de configuracao nao encontrado na tabela PZW para essa filial", "Avisar a Equipe de TI")
			Return
		Endif	
	Else
		Alert("Banco nao encontrado na tabela PZW para essa filial", "Avisar a Equipe de TI")	
		Return
	Endif
//	If !Empty(PZW->PZW_ARQCFG)
//		cArqEnt  := alltrim(PZW->PZW_ARQCFG)
//	Else
//		Alert(" Arquivo de configura��o nao encontrado na tabela PZW para essa filial", "Avisar a Equipe de TI")		
//		Return .F.			
//	Endif	
Endif

//mv_par19:= cShArq

Return (cShSaida)



*----------------------------------*
User Function fInfCnab(nRet)          // funcao para buscar o conteudo da tabela S052
/*
Abaixo apenas um exemplo de como colocar no arquivo de configuracao do banco
21H COD. CONV. BCO 0330520 U_fInfCnab(5)                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
21H AG. MANT CC    0530570 U_fInfCnab(7)                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
21H DIG. AG        0580580 U_fInfCnab(8)                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
21H CONTA CORRENTE 0590700 U_fInfCnab(9)                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
21H DIG. VERF.CC   0710710 U_fInfCnab(10) 
*/
*----------------------------------*

Private xaTabS052 := {}
//Private xcCodBanco := mv_par30
Private xcCodBanco := mv_par24 //Compatibilizado para Grupo GPEM080R2

fCarrTab( @xaTabS052, "S052", Nil)

If Len( xaTabS052 ) == 0 .Or. ( nPos := aScan(xaTabS052,{|x| x[6] == xcCodBanco .and. (Empty(x[2]) .or. x[2] == xFilial("SRA"))}) ) == 0
   Aviso("ATENCAO","Banco e Filial para processamento do CNAB n�o cadastrados na tabela S052! Favor verificar!",{"Sair"}) 
	  Return .F.
EndIf

Private xcCodFilial := xaTabS052[nPos,2]  //2
Private xcCodConve  := xaTabS052[nPos,5]  //5
Private xcCodAgenc  := xaTabS052[nPos,7]  //7
Private xcDigAgenc  := xaTabS052[nPos,8]  //8
Private xcCodConta  := xaTabS052[nPos,9]  //9
Private xcDigConta  := xaTabS052[nPos,10] //10
Private xcSequenci  := xaTabS052[nPos,11] //10

Return xaTabS052[nPos,nRet]

