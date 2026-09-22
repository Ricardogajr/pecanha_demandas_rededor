#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GP010VALPEºAutor  ³Jorge Paiva         º Data ³  07/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida dados                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
////////////////////////
User Function FSPE0026()
//////////////////////// 
Local _lRet := .T.
Local _cQuery := ""
Local _aArea := getArea()
Local _cArq := ""
Local _nRecno := 0
Local _aCpoX3 := {} //Thais Paiva - Compatibilização P27

//Local lXPERINS  := SRA->( FieldPos( "RA_XPERINS" ) # 0 )                   
//Local lXTPINSA  := SRA->( FieldPos( "RA_XTPINSA" ) # 0 ) 
//Local lXINSALU  := SRA->( FieldPos( "RA_XINSALU" ) # 0 )                 

 
// Validacao Menor Aprendiz

If _lRet 
   
	   IF M->RA_TIPOADM $ "3A-3B-3C" .AND. M->RA_PERFGTS <> 2
	      _lRet := .F.  
	      ALERT("Para menor aprendiz e necessario o preenchimento do campo % Dep.FGTS = 2")
	   ENDIF    
   
	   IF !(M->RA_TIPOADM $ "3A-3B-3C") .AND. M->RA_PERFGTS = 2
	      _lRet := .F.  
	      ALERT("Para menor aprendiz e necessario o preenchimento do campo Tipo de Admissao")
	      
	   ENDIF
Endif   


//If _lRet 
//    
// Valida a existencia de campos customizados para criticas abaixo
//   IF lXPERINS = .F.  
//      _lRet := .F.  
//      ALERT("Favor criar o campo RA_XPERINS")
//   ENDIF
//   IF lXTPINSA = .F.  
//      _lRet := .F.  
//      ALERT("Favor criar o campo RA_XTPINSA")
//   ENDIF
//   IF lXINSALU = .F.  
//      _lRet := .F.  
//      ALERT("Favor criar o campo RA_XINSALU")
//   ENDIF
//
//ENDIF

If valtype(M->RA_INSMIN)<>"N" 
    M->RA_INSMIN := 0
//   _lRet := .F.  
//   Alert("Verificar Hrs. Insulubridade Minima")
Endif      
If valtype(M->RA_INSMED)<>"N" 
   M->RA_INSMED := 0
//   _lRet := .F.  
//   Alert("Verificar Hrs. Insulubridade Media")
Endif      
If valtype(M->RA_INSMAX)<>"N" 
   M->RA_INSMAX := 0
//   _lRet := .F.  
//   Alert("Verificar Hrs. Insulubridade")
Endif      
If valtype(M->RA_PERICUL)<>"N" 
   M->RA_PERICUL := 0
//   _lRet := .F.  
//   Alert("Verificar Hrs. Periculosidade")
Endif      

IF _lRet
   
   l_InsaP := l_InsaC := l_PeriP := l_ErroIns := l_TotInsa := l_Insalu :=  .F. 
   
   //Verifica de Insalubridade Customizada esta preenchida
   //IF !EMPTY(M->RA_XPERINS) .OR. !EMPTY(M->RA_XTPINSA)
   //   l_InsaC := .T. 
   //ENDIF            
   
   //Verifica de Insalubridade Padrao esta preenchida
      
   IF (M->RA_INSMIN > 0) .OR. (M->RA_INSMED > 0) .OR. (M->RA_INSMAX > 0)
      l_InsaP := .T.
   ENDIF            
   
   //Verifica de Periculosidade Padrao esta preenchida
   IF (M->RA_PERICUL > 0) 
      l_PeriP := .T.
   ENDIF 
   
   //Verifica de Insalubridade Customizada esta preenchida
   ///IF (!EMPTY(M->RA_XPERINS) .AND. EMPTY(M->RA_XTPINSA))  .OR.   (EMPTY(M->RA_XPERINS) .AND. !EMPTY(M->RA_XTPINSA))
   //   l_ErroIns := .T. 
   //ENDIF       
   
   //Verifica se Insalubridade customizada Sim ou Nao Aba outras.
   //IF M->RA_XINSALU = "S"  
   //   l_Insalu :=  .T.
   //ENDIF    
   
   //Verifica de Insalubridade Padrao esta preenchida
   IF (M->RA_INSMIN > 0) .AND. (M->RA_INSMED > 0) .AND. (M->RA_INSMAX > 0) 
      l_TotInsa := .T.
   ENDIF 
   
   IF (M->RA_INSMIN > 0) .AND. (M->RA_INSMED = 0) .AND. (M->RA_INSMAX > 0)
      l_TotInsa := .T.
   ENDIF
   
   IF (M->RA_INSMIN > 0) .AND. (M->RA_INSMED > 0) .AND. (M->RA_INSMAX = 0)
      l_TotInsa := .T.
   ENDIF 
   
   IF (M->RA_INSMIN = 0) .AND. (M->RA_INSMED > 0) .AND. (M->RA_INSMAX > 0) 
      l_TotInsa := .T.
   ENDIF  
   
   // Nao pode estar tudo preenchido
   IF (l_InsaC = .T.)  .AND. (l_InsaP = .T.) .AND. (l_PeriP = .T.)  .AND. (l_Insalu = .T.)
      _lRet := .F. 
      Alert("Voce preecnheu os campos de Insabridade e Periculosidade, o funcionario so pode ter Isalubridade ou Periculosidade")
   ENDIF 
   
   // Nao pode estar preenchido as duas formas de Insalubridade
   IF (l_InsaC = .T.)  .AND. (l_InsaP = .T.) .AND. (l_Insalu = .T.) .AND. (l_PeriP = .F.) 
      _lRet := .F. 
      Alert("Voce preecnheu os dois tipos de Insabridade, favor revisar os campos relativos a Insalubridade")
   ENDIF 
   
   // Nao pode estar preenchido as duas formas de Insalubridade
   IF (l_InsaC = .F.)  .AND. (l_InsaP = .T.) .AND. (l_Insalu = .T.) .AND. (l_PeriP = .F.) 
      _lRet := .F. 
      Alert("Voce preecnheu os dois tipos de Insabridade, favor revisar os campos relativos a Insalubridade")
   ENDIF 
   
   // Nao pode estar preenchido as duas formas de Insalubridade
   IF (l_InsaC = .T.)  .AND. (l_InsaP = .F.) .AND. (l_Insalu = .T.) .AND. (l_PeriP = .F.) 
      _lRet := .F. 
      Alert("Voce preecnheu os dois tipos de Insabridade, favor revisar os campos relativos a Insalubridade")
   ENDIF  
   
   // Nao pode estar preenchido as duas formas de Insalubridade
   IF (l_InsaC = .T.)  .AND. (l_InsaP = .T.) .AND. (l_Insalu = .F.) .AND. (l_PeriP = .F.) 
      _lRet := .F. 
      Alert("Voce preecnheu os dois tipos de Insabridade, favor revisar os campos relativos a Insalubridade")
   ENDIF  
   
   // Nao pode estar preechido Insalubridade e Periculosidade
   IF (l_InsaC = .T.)  .AND. (l_InsaP = .F.) .AND. (l_Insalu = .T.) .AND. (l_PeriP = .T.)
      _lRet := .F.     
      Alert("Voce preecnheu os campos de Insabridade e Periculosidade, o funcionario so pode ter Isalubridade ou Periculosidade")
   ENDIF                

   // Nao pode estar preechido Insalubridade e Periculosidade
   IF (l_InsaC = .F.)  .AND. (l_InsaP = .T.) .AND. (l_Insalu = .T.) .AND. (l_PeriP = .T.)
      _lRet := .F.    
      Alert("Voce preecnheu os campos de Insabridade e Periculosidade, o funcionario so pode ter Isalubridade ou Periculosidade")
   ENDIF  
   
   // Nao pode estar preechido Insalubridade e Periculosidade
   IF (l_InsaC = .F.)  .AND. (l_InsaP = .F.) .AND. (l_Insalu = .T.) .AND. (l_PeriP = .T.)
      _lRet := .F.    
      Alert("Voce preecnheu os campos de Insabridade e Periculosidade, o funcionario so pode ter Isalubridade ou Periculosidade")
   ENDIF          
   
   // Nao pode estar tudo preenchido
   IF (l_InsaC = .F.)  .AND. (l_InsaP = .F.) .AND. (l_Insalu = .T.) .AND. (l_PeriP = .T.)  
      _lRet := .F. 
      Alert("Voce preecnheu os campos de Insabridade e Periculosidade, o funcionario so pode ter Isalubridade ou Periculosidade")
   ENDIF 
   
   // Nao pode estar tudo preenchido
   IF (l_InsaC = .F.)  .AND. (l_InsaP = .T.) .AND. (l_Insalu = .F.) .AND. (l_PeriP = .T.)  
      _lRet := .F. 
      Alert("Voce preecnheu os campos de Insabridade e Periculosidade, o funcionario so pode ter Isalubridade ou Periculosidade")
   ENDIF
   
   // Nao pode estar tudo preenchido
   IF (l_InsaC = .T.)  .AND. (l_InsaP = .F.) .AND. (l_Insalu = .F.) .AND. (l_PeriP = .T.)  
      _lRet := .F. 
      Alert("Voce preecnheu os campos de Insabridade e Periculosidade, o funcionario so pode ter Isalubridade ou Periculosidade")
   ENDIF                        
     
   IF l_ErroIns
      _lRet := .F.    
      Alert("Para calcular a Insalubridade especifica devemos preencher dois campos: Base de Isabridade e Percentual")
   ENDIF          
   
   IF l_TotInsa
      _lRet := .F.    
      Alert("O funcionario so podera estar enquadrado em apenas uma Insalubridade (Minima, Media ou Maxima")
   ENDIF

Endif


If _lRet

   IF M->RA_NACIONA != "10" .And. M->RA_NACIONA != "20"                                      
      IF EMPTY(M->RA_RNE) .OR. EMPTY(M->RA_RNEORG) .OR. EMPTY(M->RA_RNEDEXP)
         MsgStop("Favor preencher Informações Sobre a RNE Pasta Estrangeiro")
         _lRet := .F.
      Endif
   Endif

   IF !M->RA_CATFUNC = "E"
      If Empty(M->RA_TPPREVI)
         MsgStop("Favor Preencher Tipo Regime Previdenciario")
         _lRet := .F.
      Endif 
	//================================ RETIRADO EM 23/10/2018 ==============
	//  If M->RA_SALARIO = 0
    //     MsgStop("Favor Preencher Salario")
    //     _lRet := .F.
	//  Endif
    //===> TRECHO INCLUIDO DEVIDO A SOLICITAÇÃO DO PERFIL SANEADOR =========
	// VARIAVEL CNIVEL É UMA VARIAVEL QUE O SISTEMA ALIMENTA COM O NIVEL DO USUARIO LOGADO.
	//======================================================================================
 	  lCriticasal := .T.
	  //Início - Thais Paiva - Compatibilização P27
      //dbSelectArea("SX3")
      //dbSetOrder(1)
      //dbSeek("SRA")
     // Do While !EOF() .AND. SX3->X3_ARQUIVO == "SRA"
	 _aCpoX3 := FWSX3Util():GetAllFields( "SRA" , .F. ) 
	 For _nX3 := 1 to Len(_aCpoX3)
         CNADA1 := GetSx3Cache(_aCpoX3[_nx3], 'X3_CAMPO')//SX3->X3_CAMPO
         IF ALLTRIM(CNADA1) = "RA_SALARIO"
            //IF SX3->X3_NIVEL > CNIVEL   
			IF GetSx3Cache(_aCpoX3[_nx3], 'X3_NIVEL') > CNIVEL   
               lCriticasal := .F.
            ENDIF
         ENDIF
         //dbSkip()
      //End
	  Next _nX3
	  //Fim - Thais Paiva - Compatibilização P27
      If lCriticasal
	     If M->RA_SALARIO = 0
            MsgStop("Favor Preencher Salario")
            lRet := .F.
         Endif
	  Endif
    //=======================================================================
	  If Empty(M->RA_PIS)
         MsgStop("Favor Preencher Numero do PIS")
         _lRet := .F.
	  Endif
   ENDIF

   IF M->RA_TPCONTR = "2"
      IF EMPTY(M->RA_DTFIMCT)
         MsgStop("Data Termino Contrato")
         lRet := .F.
      ENDIF 
   ENDIF

   /////////// CRITICA PARA ATENDER ESOCIAL LAYOUT 2.4.02 //////////////
   IF M->RA_CLASEST != " " .OR. !EMPTY(M->RA_DATCHEG) 
      IF M->RA_CLASEST != "06"
         IF EMPTY(M->RA_DATCHEG)
            MsgStop("Favor preencher Data Chegada Pasta Estrangeiro")
            lRet := .F.
         Endif
      ENDIF

      IF M->RA_CLASEST = "06" .AND. !EMPTY(M->RA_DATCHEG)
            MsgStop("Favor Limpar Data Chegada Pasta Estrangeiro")
            lRet := .F.
      Endif
   ENDIF
   /////////////////////////////////////////////////////////////////////

Endif

Return(_lRet) 

///////////////////
User Function MSG()
///////////////////
Local l_ret := .F.
Alert("Valor deste campo não pode ser maior que o valor do campo Hrs. Mensais")
Return(l_ret)
