#include "totvs.ch"
#include "rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DORAPDT01บ Autor ณ Jose Carlos Noronhaบ Data ณ  20/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Geracao de ArquivoS Texto para Apdata.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ RedeDor                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function DORAPDT01

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Private oGeraTxt

dbSelectArea("SRA")
dbSetOrder(1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem da tela de processamento.                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

@ 200,1 TO 380,380 DIALOG oGeraTxt TITLE OemToAnsi("Integra็ใo ApData")
@ 02,10 TO 080,190
@ 10,018 Say " Este programa ira gerar um arquivo texto, a partir de parโmetros "
@ 18,018 Say " informados pelo usuแrio, de  acordo com o layout  definido  pela "
@ 26,018 Say " ApData.                                                          "

@ 70,128 BMPBUTTON TYPE 01 ACTION OkGeraTxt()
@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oGeraTxt)

Activate Dialog oGeraTxt Centered

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ OKGERATXTบ Autor ณ AP5 IDE            บ Data ณ  20/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao chamada pelo botao OK na tela inicial de processamenบฑฑ
ฑฑบ          ณ to. Executa a geracao do arquivo texto.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function OkGeraTxt

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria o arquivo texto                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local lRet := .F. //Thais Paiva - 9527152
Private cArqTxt := "" //ALLTRIM(MV_PAR02) //"C:\APDATA\FERIAS.TXT"
Private nHdl
Private cEOL    := "CHR(13)+CHR(10)"
Private cPerg   := "APDATA01"
Private cEmpFil
ValidPerg()    // 26/10/2011

If Pergunte(cPerg,.T.)
	
	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif
	
	cArqTxt := ALLTRIM(MV_PAR02)
	nHdl    := fCreate(cArqTxt)
	
	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArqTxt+" nao pode ser executado! Verifique os parametros.","Atencao!")
		Return
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Inicializa a regua de processamento                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	/*21/07/2020 - comentado
	// 26/10/2011 - Carga ID ApData do Centro de Custo
	If SuperGetMV("MV_XCCAPDT",,"N") == "S"
	//If GETMV("MV_XCCAPDT") = "S"
		If Select("CCAPD") > 0
			DbSelectArea("CCAPD")
			DbCloseArea()
		EndIf
		
		dbselectarea("CTT")
		dbsetorder(1)
		USE \APDATA\CCAPDATA.DBF  VIA "DBFCDXADS" ALIAS CCAPD NEW
		Do While !EOF()
			c_CCAP := Alltrim(STR(CCAPD->CODAPD))
			dbselectarea("CTT")
			dbseek(xFilial("CTT")+CCAPD->CODSIGA)
			If Found()
				Reclock("CTT",.F.)
				CTT->CTT_XAPDAT := c_CCAP
				msunlock()
			Endif
			dbselectarea("CCAPD")
			dbskip()
		Enddo
	Endif
	21/07/2020 - Final do comentario*/
	//Inํcio - Thais Paiva - 9527152
	//dbselectarea("SX6")
	//dbseek(xFilial("SX6")+"MV_XCCAPDT")
	//If Found()
	lRet := FWSX6Util():ExistsParam( "MV_XCCAPDT" )
	If lRet
		//Reclock("SX6",.F.)
		//SX6->X6_CONTEUD := "N"
		PutMv("MV_XCCAPDT","N")
		//msunlock()
	Endif
	//Fim - Thais Paiva - 9527152
	
	If MV_PAR01 = 1       // Funcionarios Contratados
		Processa({|| FunContrat() },"Processando...")
	ElseIf MV_PAR01 = 2   // Movimento de Ferias
		Processa({|| MovFerias() },"Processando...")
	// 27/10/2011     
	ElseIf MV_PAR01 = 3   // Altera็ใo de Salarios
		Processa({|| AltSalario() },"Processando...")
	Endif
	
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFunContratบ Autor ณ Jose Carlos Noronhaบ Data ณ  20/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FunContrat

Local cQuery := ""
Local cLinha := ""

cQuery := " SELECT RA_FILIAL, RA_SITFOLH, RA_RESCRAI, RA_MAT, RA_NOME, RA_NOMECMP, RA_CC, RA_PIS, RA_CARGO, RA_CODFUNC, RA_SEXO, "
cQuery += " RA_TELEFON, RA_SALARIO, RA_ADMISSA, RA_NASC, RA_SINDICA, RA_VIEMRAI, RA_HRSMES, RA_TNOTRAB "
cQuery += " FROM  " + RetSqlname("SRA")
cQuery += " WHERE D_E_L_E_T_ = ' ' "
// 26/10/2011
If MV_PAR03 = 2
	//cQuery += " AND RA_FILIAL = '" + CFILANT  + "' "
	cQuery += " AND RA_FILIAL BETWEEN '" + MV_PAR07  + "' AND '"+ MV_PAR08 +"' "
Endif
cQuery += " AND RA_MAT >= '" + MV_PAR05 + "' "
cQuery += " AND RA_MAT <= '" + MV_PAR06 + "' "
//
//cQuery += " ORDER BY RA_FILIAL+RA_MAT " RICARDO
cQuery += " ORDER BY RA_FILIAL,RA_MAT "

//MemoWrite(" RDORAPDAT1.TXT", cQuery)

If Select("TRBAPD") > 0
	DbSelectArea("TRBAPD")
	DbCloseArea()
EndIf
  
DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery), "TRBAPD", .F., .T.)
DbSelectArea("TRBAPD")
ProcRegua(TRBAPD->(RecCount()))
TRBAPD->(DBGoTop())

if(TRBAPD->(Eof()))
	alert("Nใo foram encontrados dados para a gera็ใo do arquivo.")
endif

Do While TRBAPD->(!Eof())
	
	If TRBAPD->RA_SITFOLH = "D" // Demitidos
		//If ! TRBAPD->RA_RESCRAI $ "30|31" // Transferidos
			TRBAPD->(dbSkip())
			Loop
		//EndIf
	EndIf

	cEmpADP:=CEMPANT
	cFilADP:=TRBAPD->RA_FILIAL
	
	//c_IdEmp:=Alltrim(Posicione("SX5",1,xFilial("SX5")+"ZP"+(cEmpADP+cFilADP),"X5_DESCRI"))		
	//nPosFiltro := fPosTab("U001",cFilADP,"==", 4)
	//c_IdEmp = fTabela("U001", 1, 5)
	 //nPosLine := fPosTab( "U001", "005", "==", "13", "01", "==", 4 )
	c_IdEmp := AllTrim(Posicione("PZB", 1, cFilADP, "PZB_FILAPD"))	
	c_IdEmp2:= AllTrim(Posicione("PZB", 1, cFilADP, "PZB_FILMAP")) //Utilizar para concatenar matricula
	If Empty(c_IdEmp) .OR. Empty(c_IdEmp2)  // Empresa / Filial Nao Existe na SX5
		TRBAPD->(dbSkip())
		Loop
	EndIf
	
	c10430   := c_IdEmp2 + TRBAPD->RA_MAT         // 10430  - Id Contratado 		9 Bytes (num้rico)
	c10630   := TRBAPD->RA_MAT                   // 10630  - Numero da Ficha de Registro na DRT (C๓digo Microsiga)    9 Bytes (num้rico)
	c9360    := TRBAPD->RA_NOME                  // 9360   - Nome 			30 caracteres
	c10025   := TRBAPD->RA_NOMECMP               // 10025  - Nome Completo 		60 caracteres
	c9930    := AllTrim(TRBAPD->RA_PIS)          // 9930   - PIS/PASEP N๚mero            Deve ser informado com a mascara 000.0000.000.0
	If !Empty(c9930)
		c9930 := Substr(c9930,1,3)+"."+Substr(c9930,4,4)+"."+Substr(c9930,8,3)+"."+Substr(c9930,11,1)
	Endif
   
	//Por "DEFAULT" a Empresa/Filial ้ a Mesma Cadastrada na Tabela ZP
	cMVXAPDATA:=c_IdEmp

	//GetNewPar(cParam,[xDefault],[cFil]) --> xConteudo
	cMVXAPDATA:=AllTrim(GetNewPar("MV_XAPDATA",cMVXAPDATA,cFilADP))

	cEmpFil:=cMVXAPDATA

	//c10410   := CEMPANT+TRBAPD->RA_FILIAL        // 10410  - Id Folha 		             9 Bytes (num้rico) 
    c10410   := cEmpFil // 10410  - Id Folha 		             9 Bytes (num้rico)--// ALTERADO POR ROBERTO LIMA	
	c10640   := TRBAPD->RA_SINDICA               // 10640  - Id Sindicato                          5 Bytes (num้rico)
	c10710   := TRBAPD->RA_VIEMRAI               // 10710  - Id Vinculo 		             2 Bytes (num้rico)
	//c_IdCC   := Alltrim(Posicione("CTT",1,xFilial("CTT")+TRBAPD->RA_CC,"CTT_XAPDAT"))
	c_IdCC   := Alltrim(Posicione("SZY", 1, TRBAPD->RA_CC,"ZY_APDATA"))
	c10540   := c_IdCC                           // 10540  - Id Centro de Custo               9 Bytes (num้rico)
	c10840   := TRBAPD->RA_CODFUNC                       // 10840  - Id Cargo 		             9 Bytes (num้rico)
	c9420    := IIf(TRBAPD->RA_SEXO="M","1","2") // 9420   - Id Sexo 		             1- masculino / 2-feminino - 3 Bytes (num้rico)
	c10460   := TRBAPD->RA_ADMISSA               // 10460  - Data da Admissใo                 DateTime
	c10520   := "1"                              // 10520  - Id Marcador de Ponto           Levar Sempre 1 - 5 Bytes (num้rico)
	c10560   := TRBAPD->RA_TNOTRAB               // 10560  - Id Horแrio 		             9 Bytes (num้rico)
	c9900    := TRBAPD->RA_NASC                  // 9900   - Data do Nascimento             DateTime
	c9840    := "10"                             // 9840   - Id Nacionalidade	             (Fixo 10)  - 3 Bytes (num้rico)
	c10720   := STR(TRBAPD->RA_HRSMES)           // 10720  - Id Quantidade Horas Mes    4 Bytes (num้rico)
	c11220   := "2"                              // 11220  - Tipo de Emprego Para Caged   Levar sempre 2  -  3 Bytes (num้rico)
	c10954   := STR(TRBAPD->RA_SALARIO)          // 10954  - Valor do salario                    12 Bytes (num้rico fracionario 12 / 2) mascara 100.00
	c9510    := Space(4)                         // 9510   - Telefone DDD		4 caracteres
	c9520    := AllTrim(TRBAPD->RA_TELEFON)      // 9520   - Telefone Numero                 10 Caracteres (Mascara 0000.0000)
	If !Empty(c9520)
		c9520 := Substr(TRBAPD->RA_TELEFON,1,4)+"."+IIf(Substr(TRBAPD->RA_TELEFON,5,1)="-",Substr(TRBAPD->RA_TELEFON,6,4),Substr(TRBAPD->RA_TELEFON,5,4))
	Endif
	
	//
	// Montagem da Linha do Arquivo Texto
	//
	cLinha := "15952"
	cLinha += ";10430;"+"("+AllTrim(c10430)+")"
	cLinha += "10630;"+"("+AllTrim(c10630)+")"
	cLinha += "9360;"+"("+AllTrim(c9360)+")"
	cLinha += "10025;"+"("+AllTrim(c10025)+")"
	cLinha += "9930;"+"("+AllTrim(c9930)+")"
	cLinha += "10410;"+"("+AllTrim(c10410)+")"
	cLinha += "10640;"+"("+AllTrim(c10640)+")"
	cLinha += "10710;"+"("+AllTrim(c10710)+")"
	cLinha += "10540;"+"("+AllTrim(c10540)+")"
	cLinha += "10840;"+"("+AllTrim(c10840)+")"
	cLinha += "9420;"+"("+AllTrim(c9420)+")"
	cLinha += "10460;"+"("+AllTrim(c10460)+")"
	cLinha += "10520;"+"("+AllTrim(c10520)+")"
	cLinha += "10560;"+"("+AllTrim(c10560)+")"
	cLinha += "9900;"+"("+AllTrim(c9900)+")"
	cLinha += "9840;"+"("+AllTrim(c9840)+")"
	cLinha += "10720;"+"("+AllTrim(c10720)+")"
	cLinha += "11220;"+"("+AllTrim(c11220)+")"
	cLinha += "10954;"+"("+AllTrim(c10954)+")"
	cLinha += "9510;"+"("+AllTrim(c9510)+")"
	cLinha += "9520;"+"("+AllTrim(c9520)+")"
	cLinha += cEOL
	
	/*
	Via TXT
	
	15952;10430;(18000114)10630;(114)9360;(Almir Bastos S. Silva)10025;(Almir Bastos Santos Silva)9930;(122.3667.277.4)10410;(3111)10640;(1)10710;(10)10540;(1)10840;(1)9420;(1)10460;(20061231)10520;(1)10560;(1)9900;(19790815)9840;(10)10720;(220)11220;(2)10954;(100.34)9510;(21)9520;(4545.4545)
	
	*/
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Incrementa a regua                                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	IncProc()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Gravacao no arquivo texto. Testa por erros durante a gravacao da    ณ
	//ณ linha montada.                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	If fWrite(nHdl,cLinha,Len(cLinha)) != Len(cLinha)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			Exit
		Endif
	Endif
	
	dbselectarea("TRBAPD")
	
	dbSkip()
	
EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ O arquivo texto deve ser fechado, bem como o dialogo criado na fun- ณ
//ณ cao anterior.                                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

fClose(nHdl)
Close(oGeraTxt)

TRBAPD->(dbCloseArea())

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณMovFerias บ Autor ณ Jose Carlos Noronhaบ Data ณ  26/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function MovFerias

Local cQuery := ""
Local cLinha := ""

cQuery := " SELECT R8_FILIAL, R8_TIPO, R8_MAT, R8_DATAINI, R8_DATAFIM "
cQuery += " FROM  " + RetSqlname("SR8")
cQuery += " WHERE D_E_L_E_T_ = ' ' "
// 26/10/2011
If MV_PAR03 = 2
	//cQuery += " AND R8_FILIAL = '" + CFILANT  + "' "
	cQuery += " AND R8_FILIAL BETWEEN '" + MV_PAR07  + "' AND '"+ MV_PAR08 +"' "
Endif
cQuery += " AND R8_MAT >= '" + MV_PAR05 + "' "
cQuery += " AND R8_MAT <= '" + MV_PAR06 + "' "
//cQuery += " AND R8_TIPO = 'F' "
cQuery += " AND R8_TIPOAFA = '001'"
cQuery += " AND SUBSTR(R8_DATAINI,1,6) = '" + Substr(MV_PAR04,3,4)+Substr(MV_PAR04,1,2) + "' "
//
cQuery += " ORDER BY R8_FILIAL,R8_MAT "

//MemoWrite(" RDORAPDAT1.TXT", cQuery)

If Select("TRBAPD") > 0
	DbSelectArea("TRBAPD")
	DbCloseArea()
EndIf

DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery), "TRBAPD", .F., .T.)
DbSelectArea("TRBAPD")
ProcRegua(TRBAPD->(RecCount()))
TRBAPD->(DBGoTop())

if(TRBAPD->(Eof()))
	alert("Nใo foram encontrados dados para a gera็ใo do arquivo.")
endif

Do While TRBAPD->(!Eof())
	
	cEmpADP  := CEMPANT
	cFilADP 	:= TRBAPD->R8_FILIAL
	//c_IdEmp  := Alltrim(Posicion e("SX5",1,xFilial("SX5")+"ZP"+cEmpADP+cFilADP,"X5_DESCRI"))
	//nPosFiltro := fPosTab("U001",cFilADP,"==", 4)
	//c_IdEmp = fTabela("U001", 1, 5)
	c_idEmp := Posicione("PZB", 1, cFilADP, "PZB_FILAPD") 
	c_IdEmp2:= AllTrim(Posicione("PZB", 1, cFilADP, "PZB_FILMAP")) //Utilizar para concatenar matricula
	If Empty(c_IdEmp) .or. Empty(c_IdEmp2) // Empresa / Filial Nao Existe na SX5
		TRBAPD->(dbSkip())
		Loop
	EndIf
	
	c15005   := AllTrim(c_IdEmp2) + AllTrim(TRBAPD->R8_MAT)         // 15005  - Id Contratado 		9 Bytes (num้rico)
	c15020   := "9"                              // 15020  - Id da Situa็ใo. (Vide C๓digos abaixo) - 9 Bytes (num้rico)
	c15010   := TRBAPD->R8_DATAINI               // 15010  - Data Inicio da Situa็ใo  - DateTime
	c15010F  := DTOS(STOD(TRBAPD->R8_DATAFIM)+1) // Data Final do Afastamento E PRIMEIRO DIA APOS AFASTAMENTO (FERIAS)
	
	//
	// Montagem da Linha do Arquivo Texto
	//
	// Registro de Inicio das Ferias
	cLinha := "16142"
	cLinha += ";15005;"+"("+AllTrim(c15005)+")"
	cLinha += "15020;"+"("+AllTrim(c15020)+")"
	cLinha += "15010;"+"("+AllTrim(c15010)+")"
	cLinha += cEOL
	
	IncProc()
	
	If fWrite(nHdl,cLinha,Len(cLinha)) != Len(cLinha)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			Exit
		Endif
	Endif
	
	// Registro de Volta das Ferias
	cLinha := "16142"
	cLinha += ";15005;"+"("+AllTrim(c15005)+")"
	cLinha += "15020;"+"(1)"
	cLinha += "15010;"+"("+AllTrim(c15010F)+")"
	cLinha += cEOL
	
	/*
	15005  - Id do Contratado    - 9 Bytes (num้rico)
	15020  - Id da Situa็ใo. (Vide C๓digos abaixo) - 9 Bytes (num้rico)
	15010  - Data Inicio da Situa็ใo  - DateTime
	
	Tabela de Situa็๕es
	
	9 	Gozando f้rias
	
	Via TXT
	
	16142;15005;(1)15020;(9)15010;(20070401)  (Aqui seria a data inicio das ferias como exemplo)
	16142;15005;(1)15020;(1)15010;(20070431)  (Aqui seria a data inicio de trabalho ap๓s as ferias)
	*/
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Incrementa a regua                                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	IncProc()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Gravacao no arquivo texto. Testa por erros durante a gravacao da    ณ
	//ณ linha montada.                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	If fWrite(nHdl,cLinha,Len(cLinha)) != Len(cLinha)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			Exit
		Endif
	Endif
	
	dbselectarea("TRBAPD")
	
	dbSkip()
	
EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ O arquivo texto deve ser fechado, bem como o dialogo criado na fun- ณ
//ณ cao anterior.                                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

fClose(nHdl)
Close(oGeraTxt)
If Select("TRBAPD")  > 0
	TRBAPD->(dbCloseArea())
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณAltSalarioบ Autor ณ Jose Carlos Noronhaบ Data ณ  27/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function AltSalario

Local cQuery := ""
Local cLinha := ""

cQuery := " SELECT RA_FILIAL, RA_SITFOLH, RA_RESCRAI, RA_MAT, RA_NOME, RA_SALARIO "
cQuery += " FROM  " + RetSqlname("SRA")
cQuery += " WHERE D_E_L_E_T_ = ' ' "
// 26/10/2011
If MV_PAR03 = 2
//	cQuery += " AND RA_FILIAL = '" + CFILANT  + "' "
	cQuery += " AND RA_FILIAL BETWEEN '" + MV_PAR07  + "' AND '"+ MV_PAR08 +"' "
Endif
cQuery += " AND RA_MAT >= '" + MV_PAR05 + "' "
cQuery += " AND RA_MAT <= '" + MV_PAR06 + "' "
//
cQuery += " ORDER BY RA_FILIAL,RA_MAT "

//MemoWrite(" RDORAPDAT1.TXT", cQuery)

If Select("TRBAPD") > 0
	DbSelectArea("TRBAPD")
	DbCloseArea()
EndIf

DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery), "TRBAPD", .F., .T.)
DbSelectArea("TRBAPD")
ProcRegua(TRBAPD->(RecCount()))
TRBAPD->(DBGoTop())
if(TRBAPD->(Eof()))
	alert("Nใo foram encontrados dados para a gera็ใo do arquivo.")
endif
Do While TRBAPD->(!Eof())
	
	If TRBAPD->RA_SITFOLH = "D" // Demitidos
		//If ! TRBAPD->RA_RESCRAI $ "30|31" // Transferidos
			TRBAPD->(dbSkip())
			Loop
		//EndIf
	EndIf
	
	cEmpADP  := CEMPANT
	cFilADP  := TRBAPD->RA_FILIAL
	//c_IdEmp  := Alltrim(Posicione("SX5",1,xFilial("SX5")+"ZP"+cEmpADP+cFilADP,"X5_DESCRI"))
	c_idEmp := AllTrim(Posicione("PZB", 1, cFilADP, "PZB_FILAPD")) 
	c_IdEmp2:= AllTrim(Posicione("PZB", 1, cFilADP, "PZB_FILMAP")) //Utilizar para concatenar matricula
	
	If Empty(c_IdEmp) .or. Empty(c_IdEmp2) // Empresa / Filial Nao Existe na SX5
		TRBAPD->(dbSkip())
		Loop
	EndIf
	
	c29222   := c_IdEmp2 + TRBAPD->RA_MAT        // 29222  - Id Contratado 		9 Bytes (num้rico)
   c29240   := "1"                             // 29240  - Id ContratadoGrade (Para a tabela de grades usar sempre esse valor)
	c29380   := STR(TRBAPD->RA_SALARIO)        // 10954  - Valor do salario                    12 Bytes (num้rico fracionario 12 / 2) mascara 100.00
	c29250   := dtos(ctod("01/"+MV_PAR04))     // 29250  - Data Inicio da altera็ใo da grade   - DateTime
	c29260   := "1228"                          // 29260  - Motivo da Altera็ใo da Grade  (Fixo 1228)  - 5 Bytes (num้rico)

	//
	// Montagem da Linha do Arquivo Texto
	//

	cLinha := "19092"
	cLinha += ";29250;"+"("+AllTrim(c29250)+")"
	cLinha += "29260;"+"("+AllTrim(c29260)+")"
	cLinha += "29380;"+"("+AllTrim(c29380)+")"
	cLinha += "{29240;(29224;"+"("+AllTrim(c29240)+")"
	cLinha += "29222;"+"("+AllTrim(c29222)+"))}"
	cLinha += cEOL
	
	/*
	Onde:
	19092 -  transa็ใo de inser็ใo da tabela.
	
	InterfacesTransacoesCpsr :
	
	Insert into InterfacesTransacoesCpsr values (1,29240,'1',29222)
	Insert into InterfacesTransacoesCpsr values (1,29240,'1',29224)
	
	29240  - id ContratadoGrade (Para a tabela de grades usar sempre esse valor)
	29222  - Id do Contratado  - 9 Bytes (num้rico)
	29224  - Id do ConGradeCargoSalario (Fixo 1) - 3 Bytes (num้rico)

	InterfacesTransacoesCampos :
	
	insert into InterfacesTransacoesCampos values (1,29250,'20090731',null)
	insert into InterfacesTransacoesCampos values (1,29260,'1001',null)
	insert into InterfacesTransacoesCampos values (1,29280,'20',null)
	
	Onde :
	29250  - Data Inicio da altera็ใo da grade   - DateTime
	29260  - Motivo da Altera็ใo da Grade  (Fixo 1228)  - 5 Bytes (num้rico)
	29380  - Valor do Salario  - 12 Bytes (num้rico fracionario 12 / 2) mascara 11200.00
	
	Via TXT
	
	19092;29250;(20090731)29260;(1228)29380;(11200.00){29240;(29224;(1)29222;(1))}
		
	*/
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Incrementa a regua                                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	IncProc()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Gravacao no arquivo texto. Testa por erros durante a gravacao da    ณ
	//ณ linha montada.                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	If fWrite(nHdl,cLinha,Len(cLinha)) != Len(cLinha)
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			Exit
		Endif
	Endif
	
	dbselectarea("TRBAPD")
	
	dbSkip()
	
EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ O arquivo texto deve ser fechado, bem como o dialogo criado na fun- ณ
//ณ cao anterior.                                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

fClose(nHdl)
Close(oGeraTxt)
If Select("TRBAPD") > 0
	TRBAPD->(dbCloseArea())
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg บ Autor ณ Jose Carlos Noronhaบ Data ณ 26/10/11    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Parametros para geracao de arquivo TXT para o ApData       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ValidPerg()

Local aAreaAtu := GetArea()
Local aRegs    := {}
Local i,j
Local	lGrv     := .F.

DbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

aAdd(aRegs,{cPerg,"01","Selecione Origem  ?"        ,"","","mv_ch1","N",01,0,0,"C","","mv_par01","1-Funcionarios","","","","","2-Mov. Ferias","","","","","3-Salarios","","","","","","","","","","","","","","   " , "" , "" , "", "" })
aAdd(aRegs,{cPerg,"02","Informe o Arquivo ?"        ,"","","mv_ch2","C",60,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","   " , "" , "" , "", "" })
aAdd(aRegs,{cPerg,"03","Selecione Filiais ?"        ,"","","mv_ch3","N",01,0,0,"C","","mv_par03","1-Todas","","","","","2-Selecionada","","","","","","","","","","","","","","","","","","","   " , "" , "" , "", "" })
aAdd(aRegs,{cPerg,"04","Periodo MM/AAAA   ?"        ,"","","mv_ch4","C",07,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","   " , "" , "" , "", "" })
AAdd(aRegs,{cPerg,"05","Da Matricula      ?"        ,"","","mv_ch5","C",06,0,0,"G","","mv_par05",""              , "" , "" , "" , "" , ""               , "" , "" , "" , "" , ""              , "" , "" , "" , "" , ""              , "" , "" , "" , "" , ""              , "" , "" , "" , "SRA" , "", "", ".RHMATD." })
AAdd(aRegs,{cPerg,"06","Ate a Matricula   ?"        ,"","","mv_ch6","C",06,0,0,"G","","mv_par06",""              , "" , "" , "" , "" , ""               , "" , "" , "" , "" , ""              , "" , "" , "" , "" , ""              , "" , "" , "" , "" , ""              , "" , "" , "" , "SRA" , "", "", ".RHMATA." })
aAdd(aRegs,{cPerg,"07","Filial de		  ?"		,"","","mv_ch7","C",08,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","   " , "" , "" , "", "" })
aAdd(aRegs,{cPerg,"08","Filial At้ 		  ?"  		,"","","mv_ch8","C",08,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","   " , "" , "" , "", "" })

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		lGrv := .T.
	Else
		If i == 1
			RecLock("SX1",.F.)
			lGrv := .T.
		Else
			lGrv := .F.
		Endif
	Endif
	If	lGrv
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

RestArea( aAreaAtu )

Return(.T.)
