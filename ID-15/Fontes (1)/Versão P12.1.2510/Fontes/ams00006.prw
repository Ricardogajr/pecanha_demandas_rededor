#Include 'Protheus.ch'
#include "rwmake.ch"
#include "topconn.ch"

/*
{Protheus.doc} AMS00006()
Funcao por JOB/Rotina para integrar alteração cadastral : Troca de Turno
@Author     Rogerio Carvalho
@Since      04/07/2018
@Version    P12.1.07
@Project    
*/

User Function AMS00006()

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

If empty(alltrim(cDtIntTurn))
	cDtIntTurn := DTOS(date())
Endif

If Isblind()
   lIntRot := .f.
	cEmpInt:="01"
	cFilInt:="01010001"

	If !RpcSetEnv(cEmpInt,cFilInt,,,"FAT",,)
		Conout("Integração Alteração Cadastral/Contratual - Cadastro de Funcionarios (INC) - Inicialização de Ambiente Não Realizada")
		restarea(aAreaAnt)
		Return
		
	Endif

		cDtIntTurn := Supergetmv("ES_DTINTTU",.T.," ") // variavel para ser utilizada com data retroativa para integracao

		If empty(alltrim(cDtIntTurn))
			cDtIntTurn := DTOS(date())
		Endif

	 cQuery  := " SELECT PF_FILIAL,PF_MAT,PF_DATA,PF_XDTOPER,PF_XHROPER,SPF.R_E_C_N_O_ SPFREC,R9_FILIAL,R9_MAT,R9_DATA,R9_XDTOPER,R9_XHROPER,R9_CAMPO,SR9.R_E_C_N_O_ SR9REC "
     cQuery  += " FROM "+ RetSqlName("SPF") + " SPF ," + RetSqlName("SR9") + " SR9 " 
     cQuery  += " WHERE SPF.D_E_L_E_T_=' ' "
     cQuery  += " AND SR9.D_E_L_E_T_=' ' "
     cQuery  += " AND R9_CAMPO='RA_TNOTRAB' "     
     cQuery  += " AND PF_FILIAL=R9_FILIAL "
     cQuery  += " AND PF_MAT=R9_MAT "
     cQuery  += " AND PF_XDTOPER=R9_XDTOPER "
     cQuery  += " AND PF_XHROPER=R9_XHROPER "
	 cQuery  += " AND PF_XDTOPER||PF_XHROPER > PF_XDTTRAN||PF_XHRTRAN "     
     cQuery  += " AND R9_XDTOPER||R9_XHROPER > R9_XDTTRAN||R9_XHRTRAN "
     cQuery  += " ORDER BY PF_DATA "

	//Em 12/12/2018 - Marcos Furtado - A FSW recebeu um e-mail do Sr. Rodrigo e Annie dizendo que o cliente não vai tratar a exclusão da rescisão, 
	//pedindo para comentar esta parte da integração.

  /*	 cQueryD  := " SELECT PF_FILIAL,PF_MAT,PF_DATA,PF_XDTOPER,PF_XHROPER,SPF.R_E_C_N_O_ SPFREC,R9_FILIAL,R9_MAT,R9_DATA,R9_XDTOPER,R9_XHROPER,R9_CAMPO,SR9.R_E_C_N_O_ SR9REC "
     cQueryD  += " FROM "+ RetSqlName("SPF") + " SPF ," + RetSqlName("SR9") + " SR9 " 
     cQueryD  += " WHERE SPF.D_E_L_E_T_='*' "
     cQueryD  += " AND SR9.D_E_L_E_T_='*' "
     cQueryD  += " AND R9_CAMPO='RA_TNOTRAB' "     
     cQueryD  += " AND PF_FILIAL=R9_FILIAL "
     cQueryD  += " AND PF_MAT=R9_MAT "
	 cQueryD  += " AND PF_XINTINC = 'S' " 
	 cQueryD  += " AND PF_XIDINC <> '                                ' "
	 cQueryD  += " AND PF_XINTEXC = ' ' " 
	 cQueryD  += " AND PF_XIDEXC = '                                ' "
	 cQueryD  += " AND PF_XDTOPER = '"+cDtIntTurn+"' "	 
	 cQueryD  += " AND R9_XINTINC = 'S' " 
	 cQueryD  += " AND R9_XIDINC <> '                                ' "
	 cQueryD  += " AND R9_XINTEXC = ' ' " 
	 cQueryD  += " AND R9_XIDEXC = '                                ' "
	 cQueryD  += " AND R9_XDTOPER = '"+cDtIntTurn+"' "	 
     cQueryD  += " ORDER BY SPF.R_E_C_N_O_ "   */
     
Else

    nIntFer := MessageBox ( "Deseja realmente [INTEGRAR] ALTERAÇÃO CADASTRAL/CONTRATUAL - CADASTRO DE FUNCIONARIOS para esta Filial ["+cFilant+"] agora???",'INTEGRACAO ALTERAÇÃO CADASTRAL/CONTRATUAL - CADASTRO DE FUNCIONARIOS', 4 )
    
    If nIntFer <> 6
       restarea(aAreaAnt)
		Return
	Endif

	 cQuery  := " SELECT PF_FILIAL,PF_MAT,PF_DATA,PF_XDTOPER,PF_XHROPER,SPF.R_E_C_N_O_ SPFREC,PF_XINTINC,PF_XIDINC,R9_FILIAL,R9_MAT,R9_DATA,R9_XDTOPER,R9_XHROPER,R9_CAMPO,SR9.R_E_C_N_O_ SR9REC, R9_XINTINC,R9_XIDINC "
     cQuery  += " FROM "+ RetSqlName("SPF") + " SPF ," + RetSqlName("SR9") + " SR9 " 
     cQuery  += " WHERE SPF.D_E_L_E_T_=' ' "
     cQuery  += " AND SR9.D_E_L_E_T_=' ' "
     cQuery  += " AND R9_CAMPO='RA_TNOTRAB' "     
	 cQuery  += " AND PF_FILIAL ='" + cFilant + "' "     
     cQuery  += " AND PF_FILIAL=R9_FILIAL "
     cQuery  += " AND PF_MAT=R9_MAT "
     cQuery  += " AND PF_XDTOPER=R9_XDTOPER "
     cQuery  += " AND PF_XHROPER=R9_XHROPER "
	 cQuery  += " AND PF_XDTOPER||PF_XHROPER > PF_XDTTRAN||PF_XHRTRAN "     
     cQuery  += " AND R9_XDTOPER||R9_XHROPER > R9_XDTTRAN||R9_XHRTRAN "
     cQuery  += " ORDER BY PF_DATA "
             
	//Em 12/12/2018 - Marcos Furtado - A FSW recebeu um e-mail do Sr. Rodrigo e Annie dizendo que o cliente não vai tratar a exclusão da rescisão, 
	//pedindo para comentar esta parte da integração.
	
/*	 cQueryD  := " SELECT PF_FILIAL,PF_MAT,PF_DATA,PF_XDTOPER,PF_XHROPER,SPF.R_E_C_N_O_ SPFREC,R9_FILIAL,R9_MAT,R9_DATA,R9_XDTOPER,R9_XHROPER,R9_CAMPO,SR9.R_E_C_N_O_ SR9REC "
     cQueryD  += " FROM "+ RetSqlName("SPF") + " SPF ," + RetSqlName("SR9") + " SR9 " 
     cQueryD  += " WHERE SPF.D_E_L_E_T_='*' "
     cQueryD  += " AND SR9.D_E_L_E_T_='*' "
     cQueryD  += " AND R9_CAMPO='RA_TNOTRAB' "     
	 cQueryD  += " AND PF_FILIAL ='" + cFilant + "' "
     cQueryD  += " AND PF_FILIAL=R9_FILIAL "
     cQueryD  += " AND PF_MAT=R9_MAT "
	 cQueryD  += " AND PF_XINTINC = 'S' " 
	 cQueryD  += " AND PF_XIDINC <> '                                ' "
	 cQueryD  += " AND PF_XINTEXC = ' ' " 
	 cQueryD  += " AND PF_XIDEXC = '                                ' "
	 cQueryD  += " AND PF_XDTOPER = '"+cDtIntTurn+"' "
	 cQueryD  += " AND R9_FILIAL ='" + cFilant + "' "
	 cQueryD  += " AND R9_XINTINC = 'S' " 
	 cQueryD  += " AND R9_XIDINC <> '                                ' "
	 cQueryD  += " AND R9_XINTEXC = ' ' " 
	 cQueryD  += " AND R9_XIDEXC = '                                ' "
	 cQueryD  += " AND R9_XDTOPER = '"+cDtIntTurn+"' "	 
     cQueryD  += " ORDER BY SPF.R_E_C_N_O_ "  */

	 ProcRegua(0)
	                        
Endif

// inclusao
	If Select("TSPF") > 0
		TSPF->(DbCloseArea())
	EndIf
	
	TCQUERY cQuery NEW ALIAS "TSPF"
	
	TSPF->( dbGoTop() )
	
 	While TSPF->(!Eof())	
    
       If lIntRot 
          ProcRegua(TSPF->(RecCount()))
    
	      IncProc("[INTEGRACAO ALTERAÇÃO CADASTRAL/CONTRATUAL - CADASTRO DE FUNCIONARIOS] -->  Emp.: " + cEmpAnt + "  Fil.: " + cFilant + "  Matricula.: " + TSPF->PF_MAT)
	   Endif

   	  	cPA6ID := U_F0600901("F0600301",TSPF->SPFREC,"SPF",TSPF->PF_FILIAL + TSPF->PF_MAT + TSPF->PF_DATA,"",CTOD(""),"UPSERT",TSPF->PF_FILIAL)
	   		   	  	
		cQueryUpd := " UPDATE "+ RetSqlName("SPF")   
		cQueryUpd += " SET PF_XINTINC = 'S' , "
		cQueryUpd += " PF_XIDINC = '" + cPA6ID + "' , "
		cQueryUpd += " PF_XHRTRAN = '" +TIME()+"' , "
		cQueryUpd += " PF_XDTTRAN = '" +dtos(date())+"' "
		cQueryUpd += " WHERE D_E_L_E_T_= ' ' "
		cQueryUpd += " AND PF_FILIAL = '"+ TSPF->PF_FILIAL + "' "
		cQueryUpd += " AND PF_MAT = '"+ TSPF->PF_MAT + "' "
		
		nExecSql := TCSQLEXEC(cQueryUpd) 

		If nExecSql > 0
		   If !lIntRot
				Conout ( "[INTEGRACAO ALTERAÇÃO CADASTRAL/CONTRATUAL - CADASTRO DE FUNCIONARIOS] - Erro na atualização de integração da tabela SPF." )
		   Endif
		Endif
	    cQueryUpd := " "

   	  	cPA6ID := U_F0600901("F0600301",TSPF->SR9REC,"SR9",TSPF->R9_FILIAL + TSPF->R9_MAT + TSPF->R9_CAMPO + TSPF->R9_DATA,"",CTOD(""),"UPSERT",TSPF->R9_FILIAL)
	   		   	  	
		cQueryUpd := " UPDATE "+ RetSqlName("SR9")   
		cQueryUpd += " SET R9_XINTINC = 'S' , "
		cQueryUpd += " R9_XIDINC = '" + cPA6ID + "' , "
		cQueryUpd += " R9_XHRTRAN = '" +TIME()+"' , "
		cQueryUpd += " R9_XDTTRAN = '" +dtos(date())+"' "
		cQueryUpd += " WHERE D_E_L_E_T_= ' ' "
        cQueryUpd += " AND R9_CAMPO='RA_TNOTRAB' "		
		cQueryUpd += " AND R9_FILIAL = '"+ TSPF->R9_FILIAL + "' "
		cQueryUpd += " AND R9_MAT = '"+ TSPF->R9_MAT + "' "
		cQueryUpd += " AND R9_XDTOPER = '"+ TSPF->R9_XDTOPER + "' "
		cQueryUpd += " AND R9_XHROPER = '"+ TSPF->R9_XHROPER + "' "

		nExecSql := TCSQLEXEC(cQueryUpd) 

		If nExecSql > 0
		   If !lIntRot
				Conout ( "[INTEGRACAO ALTERAÇÃO CADASTRAL/CONTRATUAL - CADASTRO DE FUNCIONARIOS] - Erro na atualização de integração da tabela SPF." )
		   Endif
		Endif
	   cQueryUpd := " "

	   TSPF->(dbskip())
	   
    Enddo

	TSPF->(DbCloseArea())
    cQueryUpd := " "
    

// exclusao

	//Em 12/12/2018 - Marcos Furtado - A FSW recebeu um e-mail do Sr. Rodrigo e Annie dizendo que o cliente não vai tratar a exclusão da rescisão, 
	//pedindo para comentar esta parte da integração.

/*	If Select("DSPF") > 0
		DSPF->(DbCloseArea())
	EndIf
	
	TCQUERY cQueryD NEW ALIAS "DSPF"
	
	DSPF->( dbGoTop() )
	
 	While DSPF->(!Eof())	
    
       If lIntRot 
          ProcRegua(DSPF->(RecCount()))
    
	      IncProc("[INTEGRACAO ADMISSÃO - CADASTROS DE FUNCIONÁRIOS] -->  Emp.: " + cEmpAnt + "  Fil.: " + cFilant + "  Matricula.: " + DSPF->RA_MAT)
	   Endif

	            //U_F0600901("F0600101",SRA->(RECNO()),"SRA",SRA->RA_FILIAL + SRA->RA_MAT,"",CTOD(""),cOper)	   
   	  	cPA6ID := U_F0600901("F0600301",TSPF->SPFREC,"SPF",TSPF->PF_FILIAL + TSPF->PF_MAT + TSPF->PF_DATA,"",CTOD(""),"DELETE",TSPF->PF_FILIAL)
	   		   	  	
		cQueryUpd := " UPDATE "+ RetSqlName("SPF")   
		cQueryUpd += " SET PF_XINTEXC = 'S' , "
		cQueryUpd += " PF_XIDEXC = '" + cPA6ID + "' , "
		cQueryUpd += " PF_XHRTRAN = '" +TIME()+"' , "
		cQueryUpd += " PF_XDTTRAN = '" +dtos(date())+"' "
		cQueryUpd += " WHERE D_E_L_E_T_= ' ' "
		cQueryUpd += " AND PF_XINTINC= 'S' "
		cQueryUpd += " AND PF_XIDINC <> '                                ' "
		cQueryUpd += " AND PF_XINTEXC = ' ' "
		cQueryUpd += " AND PF_XIDEXC = '                                ' "			
		cQueryUpd += " AND PF_FILIAL = '"+ TSPF->PF_FILIAL + "' "
		cQueryUpd += " AND PF_MAT = '"+ TSPF->PF_MAT + "' "
		
		nExecSql := TCSQLEXEC(cQueryUpd) 

		If nExecSql > 0
		   If !lIntRot
				Conout ( "[INTEGRACAO ALTERAÇÃO CADASTRAL/CONTRATUAL - CADASTRO DE FUNCIONARIOS] - Erro na atualização de integração da tabela SPF." )
		   Endif
		Endif
	    cQueryUpd := " "

   	  	cPA6ID := U_F0600901("F0600301",TSPF->SR9REC,"SR9",TSPF->R9_FILIAL + TSPF->R9_MAT + TSPF->R9_CAMPO + TSPF->R9_DATA,"",CTOD(""),"DELETE",TSPF->R9_FILIAL)

		cQueryUpd := " UPDATE "+ RetSqlName("SR9")   
		cQueryUpd += " SET R9_XINTEXC = 'S' , "
		cQueryUpd += " R9_XIDEXC = '" + cPA6ID + "' , "
		cQueryUpd += " R9_XHRTRAN = '" +TIME()+"' , "
		cQueryUpd += " R9_XDTTRAN = '" +dtos(date())+"' "
		cQueryUpd += " WHERE D_E_L_E_T_= ' ' "
        cQueryUpd += " AND R9_CAMPO='RA_TNOTRAB' "		
		cQueryUpd += " AND R9_XINTINC= 'S' "
		cQueryUpd += " AND R9_XIDINC <> '                                ' "
		cQueryUpd += " AND R9_XINTEXC = ' ' "
		cQueryUpd += " AND R9_XIDEXC = '                                ' "			
		cQueryUpd += " AND R9_FILIAL = '"+ TSPF->R9_FILIAL + "' "
		cQueryUpd += " AND R9_MAT = '"+ TSPF->R9_MAT + "' "
		
		nExecSql := TCSQLEXEC(cQueryUpd) 

		If nExecSql > 0
		   If !lIntRot
				Conout ( "[INTEGRACAO ALTERAÇÃO CADASTRAL/CONTRATUAL - CADASTRO DE FUNCIONARIOS] - Erro na atualização de integração da tabela SPF." )
		   Endif
		Endif
	    cQueryUpd := " "

	   DSPF->(dbskip())
	   
    Enddo

	DSPF->(DbCloseArea())*/
    cQueryUpd := " "

Return .T.  