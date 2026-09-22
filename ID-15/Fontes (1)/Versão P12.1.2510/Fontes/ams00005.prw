#Include 'Protheus.ch'
#include "rwmake.ch"
#include "topconn.ch"

/*
{Protheus.doc} AMS00005()
Funcao por JOB/Rotina para integrar Cadastro de Funcionários 
@Author     Rogerio Carvalho
@Since      28/06/2017
@Version    P12.1.07
@Project    
*/

User Function AMS00005()

Local aAreaAnt := getarea()
Local cDtIntCI := " "
Local cPA6ID   := " " 
Local cEmpInt  := " "
Local cFilInt  := " "
Local cQuery   := " "
Local lIntRot  := .t. 
Local cQueryUpd:= " "
Local nExecSql := 0
Local nIntFer  := 0

If empty(alltrim(cDtIntCI))
	cDtIntCI := DTOS(date())
Endif

If Isblind()
   lIntRot := .f.
	cEmpInt:="01"
	cFilInt:="01010001"

	If !RpcSetEnv(cEmpInt,cFilInt,,,"FAT",,)
		Conout("Integração Admissão - Cadastro de Funcionarios (INC) - Inicialização de Ambiente Não Realizada")
		restarea(aAreaAnt)
		Return
		
	Endif

		cDtIntCI := Supergetmv("ES_DTINTCI",.T.," ") // variavel para ser utilizada com data retroativa para integracao

		If empty(alltrim(cDtIntCI))
			cDtIntCI := DTOS(date())
		Endif
	
	 cQuery  := " SELECT RA_FILIAL, RA_MAT, R_E_C_N_O_ "
	 cQuery  += " FROM "+ RetSqlName("SRA") + " SRA " 
	 cQuery  += " WHERE SRA.D_E_L_E_T_ = ' ' "
	 cQuery  += " AND RA_XINTINC = ' ' " 
	 cQuery  += " AND RA_XIDINC = '                                ' "
	 cQuery  += " AND RA_XDTOPER = '"+cDtIntCI+"' "	 
	 cQuery  += " ORDER BY SRA.R_E_C_N_O_  "

	 cQueryD  := " SELECT RA_FILIAL, RA_MAT, R_E_C_N_O_ "
	 cQueryD  += " FROM "+ RetSqlName("SRA") + " SRA " 
	 cQueryD  += " WHERE SRA.D_E_L_E_T_ = '*' "
	 cQueryD  += " AND RA_XINTINC = 'S' " 
	 cQueryD  += " AND RA_XIDINC <> '                                ' "
	 cQueryD  += " AND RA_XINTEXC = ' ' " 
	 cQueryD  += " AND RA_XIDEXC = '                                ' "
	 cQueryD  += " AND RA_XDTOPER = '"+cDtIntCI+"' "	 
	 cQueryD  += " ORDER BY SRA.R_E_C_N_O_  "

	 
Else

    nIntFer := MessageBox ( "Deseja realmente [INTEGRAR] ADMISSÃO - CADASTRO DE FUNCIONARIOS para esta Filial ["+cFilant+"] agora???",'INTEGRACAO ADMISSÃO - CADASTRO DE FUNCIONARIOS', 4 )
    
    If nIntFer <> 6
       restarea(aAreaAnt)
		Return
	Endif

	 cQuery  := " SELECT RA_FILIAL, RA_MAT, R_E_C_N_O_ "
	 cQuery  += " FROM "+ RetSqlName("SRA") + " SRA " 
	 cQuery  += " WHERE SRA.D_E_L_E_T_ = ' ' "
	 cQuery  += " AND RA_FILIAL ='" + cFilant + "' "	 
	 cQuery  += " AND RA_XINTINC = ' ' " 
	 cQuery  += " AND RA_XIDINC = '                                ' "
	 cQuery  += " AND RA_XDTOPER = '"+cDtIntCI+"' "	 
	 cQuery  += " ORDER BY SRA.R_E_C_N_O_  "

	 ProcRegua(0)
	                        
Endif


// inclusao
	If Select("TSRA") > 0
		TSRA->(DbCloseArea())
	EndIf
	
	TCQUERY cQuery NEW ALIAS "TSRA"
	
	TSRA->( dbGoTop() )
	
 	While TSRA->(!Eof())	
    
       If lIntRot 
          ProcRegua(TSRA->(RecCount()))
    
	      IncProc("[INTEGRACAO ADMISSÃO - CADASTROS DE FUNCIONÁRIOS] -->  Emp.: " + cEmpAnt + "  Fil.: " + cFilant + "  Matricula.: " + TSRA->RA_MAT)
	   Endif

	            //U_F0600901("F0600101",SRA->(RECNO()),"SRA",SRA->RA_FILIAL + SRA->RA_MAT,"",CTOD(""),cOper)	   
   	  	cPA6ID := U_F0600901("F0600101",TSRA->R_E_C_N_O_,"SRA",TSRA->RA_FILIAL + TSRA->RA_MAT ,"",CTOD(""),"INSERT",TSRA->RA_FILIAL)
	   		   	  	
		cQueryUpd := " UPDATE "+ RetSqlName("SRA")   
		cQueryUpd += " SET RA_XINTINC = 'S' , "
		cQueryUpd += " RA_XIDINC = '" + cPA6ID + "' , "
		cQueryUpd += " RA_XHRTRAN = '" +TIME()+"' , "
		cQueryUpd += " RA_XDTTRAN = '" +dtos(date())+"' "
		cQueryUpd += " WHERE D_E_L_E_T_= ' ' "
		cQueryUpd += " AND RA_XINTINC = ' ' "		
		cQueryUpd += " AND RA_XIDINC = '                                ' "
		cQueryUpd += " AND RA_FILIAL = '"+ TSRA->RA_FILIAL + "' "
		cQueryUpd += " AND RA_MAT = '"+ TSRA->RA_MAT + "' "
		//cQueryUpd += " AND RA_XDTOPER = '"+ TSRA->RA_DATA + "' "

		nExecSql := TCSQLEXEC(cQueryUpd) 

		If nExecSql > 0
		   If !lIntRot
				Conout ( "INTEGRACAO ADMISSÃO - CADASTRO DE FUNCIONARIOS - Erro na atualização de integração da tabela SRA." )
		   Endif
		Endif
	   cQueryUpd := " "
	   TSRA->(dbskip())
	   
    Enddo

	TSRA->(DbCloseArea())
    cQueryUpd := " "

// exclusao
	If Select("DSRA") > 0
		DSRA->(DbCloseArea())
	EndIf
	
	TCQUERY cQueryD NEW ALIAS "DSRA"
	
	DSRA->( dbGoTop() )
	
 	While DSRA->(!Eof())	
    
       If lIntRot 
          ProcRegua(DSRA->(RecCount()))
    
	      IncProc("[INTEGRACAO ADMISSÃO - CADASTROS DE FUNCIONÁRIOS] -->  Emp.: " + cEmpAnt + "  Fil.: " + cFilant + "  Matricula.: " + DSRA->RA_MAT)
	   Endif

	            //U_F0600901("F0600101",SRA->(RECNO()),"SRA",SRA->RA_FILIAL + SRA->RA_MAT,"",CTOD(""),cOper)	   
   	  	cPA6ID := U_F0600901("F0600101",DSRA->R_E_C_N_O_,"SRA",DSRA->RA_FILIAL + DSRA->RA_MAT ,"",CTOD(""),"DELETE",DSRA->RA_FILIAL)
	   		   	  	
		cQueryUpd := " UPDATE "+ RetSqlName("SRA")   
		cQueryUpd += " SET RA_XINTEXC = 'S' , "
		cQueryUpd += " RA_XIDEXC = '" + cPA6ID + "' , "
		cQueryUpd += " RA_XHRTRAN = '" +TIME()+"' , "
		cQueryUpd += " RA_XDTTRAN = '" +dtos(date())+"' "
		cQueryUpd += " WHERE D_E_L_E_T_= '*' "
		cQueryUpd += " AND RA_XINTINC = 'S' "		
		cQueryUpd += " AND RA_XIDINC <> '                                ' "
		cQueryUpd += " AND RA_XINTEXC = ' ' "
		cQueryUpd += " AND RA_XIDEXC = '                                ' "				
		cQueryUpd += " AND RA_FILIAL = '"+ DSRA->RA_FILIAL + "' "
		cQueryUpd += " AND RA_MAT = '"+ DSRA->RA_MAT + "' "
		//cQueryUpd += " AND RA_XDTOPER = '"+ TSRA->RA_DATA + "' "

		nExecSql := TCSQLEXEC(cQueryUpd) 

		If nExecSql > 0
		   If !lIntRot
				Conout ( "INTEGRACAO ADMISSÃO - CADASTROS DE FUNCIONARIO - Erro na atualização de integração da tabela SRA." )
		   Endif
		Endif
	   cQueryUpd := " "
	   DSRA->(dbskip())
	   
    Enddo

	DSRA->(DbCloseArea())
    cQueryUpd := " "
		
Return .T.  