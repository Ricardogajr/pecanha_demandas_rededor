#Include 'Protheus.ch'
#include "rwmake.ch"
#include "topconn.ch"

/*
{Protheus.doc} AMS00002()
Funcao por JOB/Rotina para integrar ferias
@Author     Rogerio Carvalho
@Since      11/05/2017
@Version    P12.1.07
@Project    
*/
User Function AMS00002()

Local aAreaAnt := getarea()
Local cPA6ID   := " " 
Local cEmpInt  := " "
Local cFilInt  := " "
Local cQuery   := " "
Local lIntRot  := .t. 
Local cQueryUpd:= " "
Local nExecSql := 0
Local nIntFer  := 0

If Isblind()
   lIntRot := .f.
	cEmpInt:="01"
	cFilInt:="01010001"

	If !RpcSetEnv(cEmpInt,cFilInt,,,"FAT",,)

		Conout("Integra Ferias (INC) - Inicialização de Ambiente Não Realizada")
		restarea(aAreaAnt)
		Return
		
	Endif
	
	 cQuery  := " SELECT RH_FILIAL, RH_MAT, RH_DATAINI , R_E_C_N_O_ "
	 cQuery  += " FROM "+ RetSqlName("SRH") + " SRH "
	 cQuery  += " WHERE D_E_L_E_T_ = ' ' "
	 cQuery  += " AND RH_XINTINC = ' ' " 
	 cQuery  += " AND RH_XIDINC = '                                ' "
	 cQuery  += " ORDER BY R_E_C_N_O_  "

	 cQueryD  := " SELECT RH_FILIAL, RH_MAT, RH_DATAINI , R_E_C_N_O_ "
	 cQueryD  += " FROM "+ RetSqlName("SRH") + " SRH "
	 cQueryD  += " WHERE D_E_L_E_T_ = '*' "
	 cQueryD  += " AND RH_XINTINC = 'S' " 
	 cQueryD  += " AND RH_XIDINC <> '                                ' "
	 cQueryD  += " AND RH_XINTEXC = ' ' 
	 cQueryD  += " AND RH_XIDEXC = '                                ' "
	 cQueryD  += " ORDER BY R_E_C_N_O_  "

	 
Else

    nIntFer := MessageBox ( "Deseja realmente [INTEGRAR] as FERIAS para esta Filial ["+cFilant+"] agora???",'INTEGRACAO DE FERIAS', 4 )
    
    If nIntFer <> 6
       restarea(aAreaAnt)
		Return
	Endif
	
	 cQuery  := " SELECT RH_FILIAL, RH_MAT, RH_DATAINI , R_E_C_N_O_ "
	 cQuery  += " FROM "+ RetSqlName("SRH") + " SRH "
	 cQuery  += " WHERE D_E_L_E_T_ = ' ' "
	 cQuery  += " AND RH_FILIAL ='" + cFilant + "' "
	 cQuery  += " AND RH_XINTINC = ' ' " 
	 cQuery  += " AND RH_XIDINC = '                                ' "
	 cQuery  += " ORDER BY R_E_C_N_O_ "

	 cQueryD  := " SELECT RH_FILIAL, RH_MAT, RH_DATAINI , R_E_C_N_O_ "
	 cQueryD  += " FROM "+ RetSqlName("SRH") + " SRH "
	 cQueryD  += " WHERE D_E_L_E_T_ = '*' "
	 cQueryD  += " AND RH_FILIAL ='" + cFilant + "' "
	 cQueryD  += " AND RH_XINTINC = 'S' " 
	 cQueryD  += " AND RH_XIDINC <> '                                ' "
	 cQueryD  += " AND RH_XINTEXC = ' ' 
	 cQueryD  += " AND RH_XIDEXC = '                                ' "
	 cQueryD  += " ORDER BY R_E_C_N_O_ "
	 
	            
	 ProcRegua(0)
	                        
Endif

	If Select("TSRH") > 0
		TSRH->(DbCloseArea())
	EndIf
	
	TCQUERY cQuery NEW ALIAS "TSRH"
	
	TSRH->( dbGoTop() )
	
 	While TSRH->(!Eof())	
    
       If lIntRot 
          ProcRegua(TSRH->(RecCount()))
    
	      IncProc("[INTEGRACAO - GERACAO DE FERIAS] -->  Emp.: " + cEmpAnt + "  Fil.: " + cFilant + "  Matricula.: " + TSRH->RH_MAT)
	   Endif
	   
   	  	cPA6ID := U_F0600901("F0600501",TSRH->R_E_C_N_O_,"SRH",TSRH->RH_FILIAL + TSRH->RH_MAT + TSRH->RH_DATAINI,"",CTOD(""),"UPSERT",TSRH->RH_FILIAL)
	   		   	  	
		cQueryUpd := " UPDATE "+ RetSqlName("SRH")   
		cQueryUpd += " SET RH_XINTINC= 'S' , "
		cQueryUpd += " RH_XIDINC = '" + cPA6ID + "' "
		cQueryUpd += " WHERE D_E_L_E_T_= ' ' "
		cQueryUpd += " AND RH_FILIAL = '"+ TSRH->RH_FILIAL + "' "
		cQueryUpd += " AND RH_MAT = '"+ TSRH->RH_MAT + "' "
		cQueryUpd += " AND RH_DATAINI = '"+ TSRH->RH_DATAINI + "' "		

		nExecSql := TCSQLEXEC(cQueryUpd) 

		If nExecSql > 0
		   If !lIntRot
				Conout ( "Geracao de Ferias - Erro na atualização de integração da tabela SRH." )
		   Endif
		Endif
	   
	   TSRH->(dbskip())
	   
    Enddo

	TSRH->(DbCloseArea())
    cQueryUpd := " "

    
	If Select("DSRH") > 0
		DSRH->(DbCloseArea())
	EndIf
	
	TCQUERY cQueryD NEW ALIAS "DSRH"
	
	DSRH->( dbGoTop() )
	
	ProcRegua(0)
	
 	While DSRH->(!Eof())	
    
       If lIntRot 
          ProcRegua(DSRH->(RecCount()))
    
	      IncProc("[INTEGRACAO - EXCLUSÃO DE FERIAS] -->  Emp.: " + cEmpAnt + "  Fil.: " + cFilant + "  Matricula.: " + DSRH->RH_MAT)
	   Endif
	   
   	  	cPA6ID := U_F0600901("F0600501",DSRH->R_E_C_N_O_,"SRH",DSRH->RH_FILIAL + DSRH->RH_MAT + DSRH->RH_DATAINI,"",CTOD(""),"DELETE",DSRH->RH_FILIAL)
	   		   	  	
		cQueryUpd := " UPDATE "+ RetSqlName("SRH")   
		cQueryUpd += " SET RH_XINTEXC= 'S' , "
		cQueryUpd += " RH_XIDEXC = '" + cPA6ID + "' "
		cQueryUpd += " WHERE D_E_L_E_T_= '*' "
		cQueryUpd += " AND RH_XINTINC= 'S' "
		cQueryUpd += " AND RH_XIDINC <> '                                ' "				
		cQueryUpd += " AND RH_FILIAL = '"+ DSRH->RH_FILIAL + "' "
		cQueryUpd += " AND RH_MAT = '"+ DSRH->RH_MAT + "' "
		cQueryUpd += " AND RH_DATAINI = '"+ DSRH->RH_DATAINI + "' "		

		nExecSql := TCSQLEXEC(cQueryUpd) 

		If nExecSql > 0
		   If !lIntRot
		      Conout ( "Exclusão de Ferias - Erro na atualização de integração da tabela SRH " )
		   Endif
		Endif
	   
	   
	   DSRH->(dbskip())
	   
    Enddo

	DSRH->(DbCloseArea())

	restarea(aAreaAnt)
		
Return .T.  