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
@client     RedeDor 
@alterado	Mauricio Siqueira 
@data		17/03/25
@motivo		Nexxera - passou a retornar o login (cpf), no lugar do nome completo do usuario 
/*/
//==========================================================================================  
*----------------------------------*
User Function AxCadPZW              // Cadastro de caminhos de onde serï¿½o gravados os arquivos de cnabs
*----------------------------------*

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "PZW"

dbSelectArea("PZW")
dbSetOrder(1)

AxCadastro(cString,"Locais de gravação CNAB DOS BANCOS - GPE",cVldExc,cVldAlt)

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
Local aAreaArq := FwGetArea() //Thais Paiva - 24422627
Local cArqCfg := "" //Thais Paiva - 24422627

_cFil	     := cFilant
_cEmp      := cEmpAnt 
mvRet	     := Alltrim(ReadVar())
cTime 	  := TIME()
cSeq       := u_fInfCnab(11)
cShSaida   := ""
nSFilial   := Val(str(GetSx3Cache("RA_FILIAL","X3_TAMANHO")))
cSBank     := mv_par24
cEmpLog    := cEmpAnt

dbSelectArea("PZW")
dbSetOrder(1)

If PZW->(!DbSeek(_cFil+cSBank)) .And. PZW->(!DbSeek(space(nSFilial)+cSBank)) 
	Alert("Nao foi encontrado nenhum registro de configuração na tabela PZW", "Avisar a Equipe de TI")
    Return
Else

	If !Empty(PZW->PZW_LOCAL+PZW->PZW_BANCO)
		//Ex: ROTEIRO(MV_PAR01) + FILIAL + DT REFERENCIA(MV_PAR25) + SEQUENCIA + Time + .txt
		//Ex: FOL992016010100001125151.TXT                           ate  26/07/17 foi gerado dessa forma
		//cShSaida := alltrim(PZW->PZW_LOCAL)+alltrim(PZW->PZW_ARQCFG) + alltrim(MV_PAR01) + alltrim(cFilDe) + alltrim(dtoS(mv_par25)) + cSeq + alltrim(StrTran(cTime,":","")) + ".txt"
		//santfol.2re-res-01310011-20170731-151542-ari.oliveira.txt  apos 26/07/17 sera gerado dessa forma
		//cShSaida := alltrim(PZW->PZW_LOCAL)+alltrim(PZW->PZW_ARQCFG) + "-" + alltrim(MV_PAR01) + "-" + alltrim(cFilDe) + "-" + alltrim(dtoS(mv_par25)) + "-" + alltrim(StrTran(cTime,":","")) + "-" + alltrim(substr(cusuario,7,15)) +".txt"
		//cShSaida := alltrim(PZW->PZW_LOCAL)+alltrim(PZW->PZW_ARQCFG) + "-" + alltrim(MV_PAR01) + "-" + subs(alltrim(MV_PAR04),16,8) + "-" + alltrim(dtoS(mv_par19)) + "-" + alltrim(StrTran(cTime,":","")) + "-" + alltrim(substr(cusuario,7,15)) +".txt"
		//cShSaida := alltrim(PZW->PZW_LOCAL)+alltrim(PZW->PZW_ARQCFG) + "-" + alltrim(MV_PAR01) + "-" + subs(alltrim(MV_PAR04),16,8) + "-" + alltrim(dtoS(mv_par19)) + "-" + alltrim(StrTran(cTime,":","")) + "-" + alltrim(substr(cUserName,1,11)) +".txt"	// 17/03/25 - Passou a retornar o CPF

      // Siqueira - Nexxera 28/04/25
		If cEmpLog = '01'
         cTipCNab := MV_PAR01
         cCodUsu  := RetCodUsr()
         nRCCLin  := fPosTab("U016", cCodUsu, "=",4,)
         cTipAce  := fTabela("U016", nRCCLin, 6)+fTabela("U016", nRCCLin, 8)
         cCPFRes  := fTabela("U016", nRCCLin, 7)

         If '01310060' $ Trim(mv_par04) 
            cTipCNab := 'EXE' 
         Else
            If cTipCNAB = 'VEX' .And. 'BEN' $ cTipAce
               cTipCNAB := 'BEN'
            Else
               If cTipCNab $ ('FOL|VEX|131|132|AUT')
                  cTipCNab := 'FOL'
               Endif
            EndIf
         EndIf

   		cShSaida := alltrim(PZW->PZW_LOCAL)                 // Local de gravação
	   	cShSaida += alltrim(mv_par24) + "_"					    // Banco
         cShSaida += alltrim(cTipCNAB) + "_"					    // Tipo de Cnab
         cShSaida += subs(alltrim(MV_PAR04),16,8)  + "_"		 // Filial
         cShSaida += alltrim(dtoS(mv_par19)) + "_"			    // Data
         cShSaida += alltrim(StrTran(Time(),":","")) + "_"	 // Hora
         cShSaida += alltrim(cCPFRes) + ".txt"   		       // CPF responsável pela geração	
      Else	
   		cShSaida := alltrim(mv_par13)                       // Local de gravação
		EndIf

		If !Empty(PZW->PZW_ARQCFG)
			If !FILE(PZW->PZW_ARQCFG)
				Help(" ",1,"NOARQPAR")
				Return
			/*Else	Thais Paiva - 24422627
				cArqent  := alltrim(PZW->PZW_ARQCFG) Thais Paiva - 24422627*/
			Endif	
		Else
			Alert("Arquivo de configuracao nao encontrado na tabela PZW para essa filial", "Avisar a Equipe de TI")
			Return
		Endif	
	Else
		Alert("Banco nao encontrado na tabela PZW para essa filial", "Avisar a Equipe de TI")	
		Return
	Endif

Endif
FwRestArea(aAreaArq) //Thais Paiva - 24422627

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
   Aviso("ATENCAO","Banco e Filial para processamento do CNAB nï¿½o cadastrados na tabela S052! Favor verificar!",{"Sair"}) 
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


/*---------------------------------------------------------------------------
 // Siqueira - Nexeera - 28/04/25
 // Ponto de Entrada para validar permissões do usuário
 --------------------------------------------------------------------------*/
User Function GP080US1()

Local aArea    := FWGetArea()
Local lRet     := .T.
Local cTipCNab := MV_PAR01
Local cCodUsu  := RetCodUsr()
Local nRCCLin  := fPosTab("U016", cCodUsu, "=",4,)
Local cTipAce  := fTabela("U016", nRCCLin, 6)+fTabela("U016", nRCCLin, 8)
Local cEmpLog  := cEmpAnt

If cEmpLog = '01'
   If '01310060' $ Trim(mv_par04)
      cTipCNab := 'EXE' 
   Else
      If cTipCNAB = 'VEX' .And. 'BEN' $ cTipAce
         cTipCNAB := 'BEN'
      Else
         If cTipCNab $ ('FOL|VEX|131|132|AUT')
            cTipCNab := 'FOL'
         EndIf
      EndIf
   EndIf

   If !cTipCNab $ cTipAce
      lRet := .F.
   EndIf

   If !lRet
      FWAlertError("Usuário sem permissão para gerar este CNAB (" + cTipCNAB + ") !")
   EndIf

   FWRestArea(aArea)
EndIf

Return (lRet)


/*---------------------------------------------------------------------------
 // Siqueira - Nexeera - 28/04/25
 // Função para 'montar' as informações do segmento 5
 --------------------------------------------------------------------------*/
User Function DORSEGM5()

Local aArea    := FWGetArea()
Local cSegmen5 := ""
Local cTipCNAB := MV_PAR01
Local cCodUsu  := RetCodUsr()
Local nRCCLin  := fPosTab("U016", cCodUsu, "=",4,)
Local cTipAce  := fTabela("U016", nRCCLin, 6)+fTabela("U016", nRCCLin, 8)
Local cCPFRes  := fTabela("U016", nRCCLin, 7)

If '01310060' $ Trim(mv_par04) 
   cTipCNab := 'EXE' 
Else
   If cTipCNAB = 'VEX' .And. 'BEN' $ cTipAce
      cTipCNAB := 'BEN'
   Else
      If cTipCNab $ ('FOL|VEX|131|132|AUT')
         cTipCNab := 'FOL'
      EndIf
   EndIf
EndIf

cSegmen5 := alltrim(mv_par24) + " "					   // Banco
cSegmen5 += alltrim(cTipCNAB) + " "				      // Tipo de Cnab
cSegmen5 += alltrim(RA_FILIAL) + " "		         // Filial
cSegmen5 += alltrim(dtoS(mv_par19)) + " "			   // Data
cSegmen5 += alltrim(StrTran(Time(),":","")) + " "	// Hora
cSegmen5 += alltrim(cCPFRes)   					      // CPF responsável pela geração

FWRestArea(aArea)

Return (cSegmen5)
