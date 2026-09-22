#Include 'Protheus.ch'
#include "rwmake.ch"
#include "topconn.ch"

/*
{Protheus.doc} AMS00007()
Funcao por JOB/Rotina para integrar alteração cadastral : Atualização Salarial 
@Author     Rogerio Carvalho
@Since      09/07/2018
@Version    P12.1.07
@Project    
*/

User Function AMS00007()

Local aAreaAnt := getarea()
Local cDtIntTurn := " "
Local cPA6ID   := " " 
Local cEmpInt  := " "
Local cFilInt  := " "
Local cQuery   := " "
Local lIntRot  := .t. 
Local cQueryUpd:= " "
Local nExecSql := 0
Local nIntFer  := 0
Local _cHoraTran := "" //Thais Paiva - 10037508
Local _cDataTran := "" //Thais Paiva - 10037508

If empty(alltrim(cDtIntTurn))
	cDtIntTurn := DTOS(date())
Endif

If Isblind()
   lIntRot := .f.
	cEmpInt:="01"
	cFilInt:="01010001"

	If !RpcSetEnv(cEmpInt,cFilInt,,,"FAT",,)
		Conout("Integração Alteração Cadastral/Contratual - Atual. Salarial (INC) - Inicialização de Ambiente Não Realizada")
		restarea(aAreaAnt)
		Return
		
	Endif

		cDtIntTurn := Supergetmv("ES_DTINTSF",.T.," ") // variavel para ser utilizada com data retroativa para integracao

		If empty(alltrim(cDtIntTurn))
			cDtIntTurn := DTOS(date())
		Endif

	 cQuery  := "SELECT R3_FILIAL,R3_MAT,R3_DATA,R3_TIPO,SR3.R_E_C_N_O_ SR3REC,R7_FILIAL,R7_MAT,R7_DATA,R7_TIPO, SR7.R_E_C_N_O_ SR7REC, "
	 cQuery  += "R3_XDTOPER, R3_XHROPER, R7_XHROPER, R7_XDTOPER " //Thais Paiva - 10037508
     cQuery  += "FROM "+ RetSqlName("SR3") + " SR3 ," + RetSqlName("SR7") + " SR7 " 
     cQuery  += "WHERE SR3.D_E_L_E_T_=' ' "
     cQuery  += "AND SR7.D_E_L_E_T_=' ' "
     cQuery  += "AND R3_FILIAL=R7_FILIAL "
     cQuery  += "AND R3_MAT=R7_MAT "
     cQuery  += "AND R3_XDTOPER=R7_XDTOPER "
     cQuery  += "AND R3_XHROPER=R7_XHROPER "
	 cQuery  += "AND R3_XDTOPER||R3_XHROPER > R3_XDTTRAN||R3_XHRTRAN "     
     cQuery  += "AND R7_XDTOPER||R7_XHROPER > R7_XDTTRAN||R7_XHRTRAN "
	 cQuery  += "AND R3_XDTOPER <> '    ' " //Thais Paiva - 10037508
     cQuery  += "AND R3_XHROPER <> '    ' " //Thais Paiva - 10037508
     cQuery  += "ORDER BY R3_DATA "
	
Else

    nIntFer := MessageBox ( "Deseja realmente [INTEGRAR] ALTERAÇÃO CADASTRAL/CONTRATUAL - Atual. Salarial para esta Filial ["+cFilant+"] agora???",'INTEGRACAO ALTERAÇÃO CADASTRAL/CONTRATUAL - CADASTRO DE FUNCIONARIOS', 4 )
    
    If nIntFer <> 6
       restarea(aAreaAnt)
		Return
	Endif

	 cQuery  := "SELECT R3_FILIAL,R3_MAT,R3_DATA,R3_TIPO,SR3.R_E_C_N_O_ SR3REC,R7_FILIAL,R7_MAT,R7_DATA,R7_TIPO, SR7.R_E_C_N_O_ SR7REC, "
	 cQuery  += "R3_XDTOPER, R3_XHROPER, R7_XHROPER, R7_XDTOPER " //Thais Paiva - 10037508
     cQuery  += "FROM "+ RetSqlName("SR3") + " SR3 ," + RetSqlName("SR7") + " SR7 " 
     cQuery  += "WHERE SR3.D_E_L_E_T_=' ' "
     cQuery  += "AND SR7.D_E_L_E_T_=' ' "
     cQuery  += "AND R3_FILIAL=R7_FILIAL "
	 cQuery  += "AND R3_FILIAL ='" + cFilant + "' "     
     cQuery  += "AND R3_MAT=R7_MAT "
     cQuery  += "AND R3_XDTOPER=R7_XDTOPER "
     cQuery  += "AND R3_XHROPER=R7_XHROPER "
	 cQuery  += "AND R3_XDTOPER||R3_XHROPER > R3_XDTTRAN||R3_XHRTRAN "     
     cQuery  += "AND R7_XDTOPER||R7_XHROPER > R7_XDTTRAN||R7_XHRTRAN "
	 cQuery  += "AND R3_XDTOPER <> '    ' " //Thais Paiva - 10037508
     cQuery  += "AND R3_XHROPER <> '    ' " //Thais Paiva - 10037508
     cQuery  += "ORDER BY R3_DATA "

	 ProcRegua(0)
	                        
Endif


// inclusao
	If Select("TR3R7") > 0
		TR3R7->(DbCloseArea())
	EndIf
	
	TCQUERY cQuery NEW ALIAS "TR3R7"
	
	TR3R7->( dbGoTop() )
	
 	While TR3R7->(!Eof())

	 	_cHoraTran := TIME()
		_cDataTran := dtos(date()) 
    
       If lIntRot 
          ProcRegua(TR3R7->(RecCount()))
    
	      IncProc("[INTEGRACAO ALTERAÇÃO CADASTRAL/CONTRATUAL - Atual. Salarial] -->  Emp.: " + cEmpAnt + "  Fil.: " + cFilant + "  Matricula.: " + TR3R7->R3_MAT)
	   Endif

   	  	cPA6ID := U_F0600901("F0600301",TR3R7->SR3REC,"SR3",TR3R7->R3_FILIAL + TR3R7->R3_MAT + TR3R7->R3_DATA,"",CTOD(""),"UPSERT",TR3R7->R3_FILIAL)
	   		   	  	
		cQueryUpd := "UPDATE "+ RetSqlName("SR3")   
		cQueryUpd += " SET R3_XINTINC = 'S' , "
		cQueryUpd += "R3_XIDINC = '" + cPA6ID + "' , "
		//cQueryUpd += "R3_XHRTRAN = '" +TIME()+"' , " Thais Paiva - 10037508
		//cQueryUpd += "R3_XDTTRAN = '" +dtos(date())+"' " Thais Paiva - 10037508
		cQueryUpd += "R3_XHRTRAN = '" +_cHoraTran+"' , "
		cQueryUpd += "R3_XDTTRAN = '" +_cDataTran+"' "
		cQueryUpd += "WHERE D_E_L_E_T_= ' ' "
		cQueryUpd += "AND R3_FILIAL = '"+ TR3R7->R3_FILIAL + "' "
		cQueryUpd += "AND R3_MAT = '"+ TR3R7->R3_MAT + "' "
		//cQueryUpd += " AND R3_XINTINC = ' ' " Thais Paiva - 10037508
		//cQueryUpd += " AND R3_XIDINC = '                                ' " Thais Paiva - 10037508
		cQueryUpd += "AND R3_XDTOPER = '"+ TR3R7->R3_XDTOPER+ "' " //Thais Paiva - 10037508
        cQueryUpd += "AND R3_XHROPER = '"+ TR3R7->R3_XHROPER+ "' " //Thais Paiva - 10037508
        cQueryUpd += "AND R_E_C_N_O_ = '"+ AllTrim(Str(TR3R7->SR3REC)) +"' " //Thais Paiva - 10037508

		
		nExecSql := TCSQLEXEC(cQueryUpd) 

		If nExecSql > 0
		   If !lIntRot
				Conout ( "[INTEGRACAO ALTERAÇÃO CADASTRAL/CONTRATUAL - Atual. Salarial/Troca Função] - Erro na atualização de integração da tabela SPF." )
		   Endif
		Endif
	    cQueryUpd := " "

   	  	//cPA6ID := U_F0600901("F0600301",TR3R7->SR7REC,"SR7",TR3R7->R7_FILIAL + TR3R7->R7_MAT + TR3R7->R7_CAMPO + TR3R7->R7_DATA,"",CTOD(""),"UPSERT",TR3R7->R7_FILIAL) Thais Paiva - 10037508
		cPA6ID := U_F0600901("F0600301",TR3R7->SR7REC,"SR7",TR3R7->R7_FILIAL + TR3R7->R7_MAT + TR3R7->R7_DATA + TR3R7->R7_TIPO ,"",CTOD(""),"UPSERT",TR3R7->R7_FILIAL)
	   		   	  	
		cQueryUpd := "UPDATE "+ RetSqlName("SR7")   
		cQueryUpd += " SET R7_XINTINC = 'S' , "
		cQueryUpd += "R7_XIDINC = '" + cPA6ID + "' , "
		//cQueryUpd += "R7_XHRTRAN = '" +TIME()+"' , "
		//cQueryUpd += "R7_XDTTRAN = '" +dtos(date())+"' "
		cQueryUpd += "R7_XHRTRAN = '" +_cHoraTran+"' , "
		cQueryUpd += "R7_XDTTRAN = '" +_cDataTran+"' "
		cQueryUpd += "WHERE D_E_L_E_T_= ' ' "
		cQueryUpd += "AND R7_FILIAL = '"+ TR3R7->R7_FILIAL + "' "
		cQueryUpd += "AND R7_MAT = '"+ TR3R7->R7_MAT + "' "
		cQueryUpd += "AND R7_XDTOPER = '"+ TR3R7->R7_XDTOPER + "' "
		cQueryUpd += "AND R7_XHROPER = '"+ TR3R7->R7_XHROPER + "' "
		//cQueryUpd += " AND SR7.R_E_C_N_O_ = '"+ TR3R7->SR7REC +"' " Thais Paiva - 10037508
		cQueryUpd += "AND R_E_C_N_O_ = '"+ AllTrim(Str(TR3R7->SR7REC)) +"' " 
		
		nExecSql := TCSQLEXEC(cQueryUpd) 

		If nExecSql > 0
		   If !lIntRot
				Conout ( "[INTEGRACAO ALTERAÇÃO CADASTRAL/CONTRATUAL - Atual. Salarial/Troca Função] - Erro na atualização de integração da tabela SPF." )
		   Endif
		Endif
	   cQueryUpd := " "

	   TR3R7->(dbskip())
	   
    Enddo

	TR3R7->(DbCloseArea())
    cQueryUpd := " "
    
Return .T.  
