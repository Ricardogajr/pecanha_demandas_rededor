#Include 'Protheus.ch'
#include "rwmake.ch"
#include "topconn.ch"

/*
{Protheus.doc} AMS00009()
Funcao por JOB/Rotina para integrar alteração cadastral : Troca de Função
@Author     Rogerio Carvalho
@Since      09/07/2018
@Version    P12.1.07
@Project    
*/

User Function AMS00009()

Local aAreaAnt := getarea()
Local cDtIntFu := " "
Local cPA6ID   := " " 
Local cEmpInt  := " "
Local cFilInt  := " "
Local cQuery   := " "
Local lIntRot  := .t. 
Local cQueryUpd:= " "
Local nExecSql := 0
Local nIntFer  := 0

If empty(alltrim(cDtIntFu))
	cDtIntFu := DTOS(date())
Endif

If Isblind()
   lIntRot := .f.
	cEmpInt:="01"
	cFilInt:="01010001"

	If !RpcSetEnv(cEmpInt,cFilInt,,,"FAT",,)
		Conout("Integração Alteração Cadastral/Contratual - Atual. Salarial/Troca Função (INC) - Inicialização de Ambiente Não Realizada")
		restarea(aAreaAnt)
		Return
		
	Endif

		cDtIntFu := Supergetmv("ES_DTINTFU",.T.," ") // variavel para ser utilizada com data retroativa para integracao

		If empty(alltrim(cDtIntFu))
			cDtIntFu := DTOS(date())
		Endif

	 cQuery  := " SELECT R7_FILIAL,R7_MAT,R7_DATA,R7_TIPO, SR7.R_E_C_N_O_ SR7REC "
     cQuery  += " FROM "+ RetSqlName("SR7") + " SR7 " 
     cQuery  += " WHERE SR7.D_E_L_E_T_=' ' "
     cQuery  += " AND R7_XDTOPER||R7_XHROPER > R7_XDTTRAN||R7_XHRTRAN "
	 cQuery  += " AND R7_XINTINC = ' ' "
	 cQuery  += " AND R7_XIDINC = '                                ' "
     cQuery  += " ORDER BY R7_DATA "
	
Else

    nIntFer := MessageBox ( "Deseja realmente [INTEGRAR] ALTERAÇÃO CADASTRAL/CONTRATUAL - Troca Função para esta Filial ["+cFilant+"] agora???",'INTEGRACAO ALTERAÇÃO CADASTRAL/CONTRATUAL - CADASTRO DE FUNCIONARIOS', 4 )
    
    If nIntFer <> 6
       restarea(aAreaAnt)
		Return
	Endif

	 cQuery  := " SELECT R7_FILIAL,R7_MAT,R7_DATA,R7_TIPO, SR7.R_E_C_N_O_ SR7REC "
     cQuery  += " FROM "+ RetSqlName("SR7") + " SR7 " 
     cQuery  += " WHERE SR7.D_E_L_E_T_=' ' "
	 cQuery  += " AND R7_FILIAL ='" + cFilant + "' "     
     cQuery  += " AND R7_XDTOPER||R7_XHROPER > R7_XDTTRAN||R7_XHRTRAN "
	 cQuery  += " AND R7_XINTINC = ' ' "
	 cQuery  += " AND R7_XIDINC = '                                ' "
     cQuery  += " ORDER BY R7_DATA "

	 ProcRegua(0)
	                        
Endif


// inclusao
	If Select("TR7") > 0
		TR7->(DbCloseArea())
	EndIf
	
	TCQUERY cQuery NEW ALIAS "TR7"
	
	TR7->( dbGoTop() )
	
 	While TR7->(!Eof())	
    
       If lIntRot 
          ProcRegua(TR7->(RecCount()))
    
	      IncProc("[INTEGRACAO ALTERAÇÃO CADASTRAL/CONTRATUAL - Troca Função] -->  Emp.: " + cEmpAnt + "  Fil.: " + cFilant + "  Matricula.: " + TR7->R7_MAT)
	   Endif

   	  	cPA6ID := U_F0600901("F0600301",TR7->SR7REC,"SR7",TR7->R7_FILIAL + TR7->R7_MAT + TR7->R7_DATA + TR7->R7_TIPO,"",CTOD(""),"UPSERT",TR7->R7_FILIAL)
	   		   	  	
		cQueryUpd := " UPDATE "+ RetSqlName("SR7")   
		cQueryUpd += " SET R7_XINTINC = 'S' , "
		cQueryUpd += " R7_XIDINC = '" + cPA6ID + "' , "
		cQueryUpd += " R7_XHRTRAN = '" +TIME()+"' , "
		cQueryUpd += " R7_XDTTRAN = '" +dtos(date())+"' "
		cQueryUpd += " WHERE D_E_L_E_T_= ' ' "
		cQueryUpd += " AND R7_FILIAL = '"+ TR7->R7_FILIAL + "' "
		cQueryUpd += " AND R7_MAT = '"+ TR7->R7_MAT + "' "
		cQueryUpd += " AND R7_XINTINC = ' ' "
		cQueryUpd += " AND R7_XIDINC = '                                ' "
		
		nExecSql := TCSQLEXEC(cQueryUpd) 

		If nExecSql > 0
		   If !lIntRot
				Conout ( "[INTEGRACAO ALTERAÇÃO CADASTRAL/CONTRATUAL - Atual. Salarial/Troca Função] - Erro na atualização de integração da tabela SPF." )
		   Endif
		Endif
	    cQueryUpd := " "

	   TR7->(dbskip())
	   
    Enddo

	TR7->(DbCloseArea())
    cQueryUpd := " "
    
		
Return .T.  