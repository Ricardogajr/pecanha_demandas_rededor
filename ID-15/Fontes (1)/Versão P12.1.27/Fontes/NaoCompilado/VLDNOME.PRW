#INCLUDE "PROTHEUS.CH"                                

//////////////////////////////////////////////////////////////////
// Validacao do Nome do Emitente de Atestado Medico PROTHEUS 12 //
//////////////////////////////////////////////////////////////////

****************************
User Function VldNome(cNome)
****************************

Local cNome1 := cNome
Local lOk    := .T. 
Local aLetraErr := {}   
Local aVogal   := {}    
Local aConsoante := {}

Local nSoma1 := 0
Local nGrupo1 := 0
Local nGrupo2 := 0
Local nGrupo3 := 0 
Local nGrupo4 := 0 
Local nGrupo5 := 0 
Local nGrupo6 := 0 
Local nGrupo7 := 0 
Local nGrupo8 := 0 
Local nGrupo9 := 0 
Local nGrupo10 := 0 
Local nQtabrev := 0
Local nBrancos := 0
Local N1       := 0 
//                

AADD(aVogal,{"a",0})
AADD(aVogal,{"e",0})
AADD(aVogal,{"i",0})
AADD(aVogal,{"o",0})
AADD(aVogal,{"u",0})
AADD(aVogal,{"A",0})
AADD(aVogal,{"E",0})
AADD(aVogal,{"I",0})
AADD(aVogal,{"O",0})
AADD(aVogal,{"U",0})

AADD(aConsoante,{"q",0})
AADD(aConsoante,{"w",0})
AADD(aConsoante,{"y",0})
AADD(aConsoante,{"p",0})
AADD(aConsoante,{"d",0})
AADD(aConsoante,{"f",0})
AADD(aConsoante,{"g",0})
AADD(aConsoante,{"h",0})    
AADD(aConsoante,{"j",0})
AADD(aConsoante,{"k",0})
AADD(aConsoante,{"ç",0})
AADD(aConsoante,{"z",0})
AADD(aConsoante,{"x",0})
AADD(aConsoante,{"c",0})
AADD(aConsoante,{"v",0})
AADD(aConsoante,{"b",0})
AADD(aConsoante,{"n",0})
AADD(aConsoante,{"m",0})
AADD(aConsoante,{"Q",0})
AADD(aConsoante,{"W",0})
AADD(aConsoante,{"R",0})
AADD(aConsoante,{"T",0})
AADD(aConsoante,{"Y",0})
AADD(aConsoante,{"P",0})
AADD(aConsoante,{"S",0})
AADD(aConsoante,{"D",0})
AADD(aConsoante,{"F",0})
AADD(aConsoante,{"G",0})
AADD(aConsoante,{"H",0})
AADD(aConsoante,{"J",0})
AADD(aConsoante,{"K",0})
AADD(aConsoante,{"L",0})
AADD(aConsoante,{"Ç",0})
AADD(aConsoante,{"Z",0})
AADD(aConsoante,{"X",0})
AADD(aConsoante,{"C",0})
AADD(aConsoante,{"V",0})
AADD(aConsoante,{"N",0})
AADD(aConsoante,{"M",0})

AADD(aLetraErr,"^") 
AADD(aLetraErr,"´")
AADD(aLetraErr,"`")
AADD(aLetraErr,"~")
AADD(aLetraErr,"¨")
AADD(aLetraErr,"á")
AADD(aLetraErr,"é")
AADD(aLetraErr,"í")
AADD(aLetraErr,"ó")
AADD(aLetraErr,"ú")
AADD(aLetraErr,"à")
AADD(aLetraErr,"â")
AADD(aLetraErr,"ê")
AADD(aLetraErr,"ô")
AADD(aLetraErr,"ã")
AADD(aLetraErr,"õ")
AADD(aLetraErr,"ü")
AADD(aLetraErr,"ç")
AADD(aLetraErr,"Á")
AADD(aLetraErr,"É")
AADD(aLetraErr,"Í")
AADD(aLetraErr,"Ó")
AADD(aLetraErr,"Ú")
AADD(aLetraErr,"À")
AADD(aLetraErr,"Â")
AADD(aLetraErr,"Ê")
AADD(aLetraErr,"Ô")
AADD(aLetraErr,"Ã")
AADD(aLetraErr,"Õ")
AADD(aLetraErr,"Ü")
AADD(aLetraErr,"Ç") 
AADD(aLetraErr,'"')
AADD(aLetraErr,"'")
AADD(aLetraErr,"!")
AADD(aLetraErr,"@")
AADD(aLetraErr,"#")
AADD(aLetraErr,"$")
AADD(aLetraErr,"%")
AADD(aLetraErr,"&")
AADD(aLetraErr,"*")
AADD(aLetraErr,"(")
AADD(aLetraErr,")")
AADD(aLetraErr,"-")
AADD(aLetraErr,"_")
AADD(aLetraErr,"+")
AADD(aLetraErr,"=")
AADD(aLetraErr,"§")
AADD(aLetraErr,"{")
AADD(aLetraErr,"]")
AADD(aLetraErr,"ª")
AADD(aLetraErr,"}")
AADD(aLetraErr,"]")
AADD(aLetraErr,"º")
AADD(aLetraErr,",")
AADD(aLetraErr,";")
AADD(aLetraErr,":")
AADD(aLetraErr,"?")
AADD(aLetraErr,"/")
AADD(aLetraErr,"°")
AADD(aLetraErr,"<")
AADD(aLetraErr,">")
AADD(aLetraErr,".")

AADD(aLetraErr,"1")
AADD(aLetraErr,"2")
AADD(aLetraErr,"3")
AADD(aLetraErr,"4")
AADD(aLetraErr,"5")
AADD(aLetraErr,"6")
AADD(aLetraErr,"7")
AADD(aLetraErr,"8")
AADD(aLetraErr,"9")
AADD(aLetraErr,"0")

AADD(aLetraErr,"qqq")
AADD(aLetraErr,"www")
AADD(aLetraErr,"eee")
AADD(aLetraErr,"rrr")
AADD(aLetraErr,"ttt")
AADD(aLetraErr,"yyy")
AADD(aLetraErr,"uuu")
AADD(aLetraErr,"iii")
AADD(aLetraErr,"ooo")
AADD(aLetraErr,"ppp")
AADD(aLetraErr,"aaa")
AADD(aLetraErr,"sss")
AADD(aLetraErr,"ddd")
AADD(aLetraErr,"fff")
AADD(aLetraErr,"ggg")
AADD(aLetraErr,"hhh")
AADD(aLetraErr,"jjj")
AADD(aLetraErr,"kkk")
AADD(aLetraErr,"lll")
AADD(aLetraErr,"ççç")
AADD(aLetraErr,"zzz")
AADD(aLetraErr,"xxx")
AADD(aLetraErr,"ccc")
AADD(aLetraErr,"vvv")
AADD(aLetraErr,"bbb")
AADD(aLetraErr,"nnn")
AADD(aLetraErr,"mmm")
AADD(aLetraErr,"   ")
AADD(aLetraErr,"  ")

AADD(aLetraErr,"QQQ")
AADD(aLetraErr,"WWW")
AADD(aLetraErr,"EEE")
AADD(aLetraErr,"RRR")
AADD(aLetraErr,"TTT")
AADD(aLetraErr,"YYY")
AADD(aLetraErr,"UUU")
AADD(aLetraErr,"III")
AADD(aLetraErr,"OOO")
AADD(aLetraErr,"PPP")
AADD(aLetraErr,"AAA")
AADD(aLetraErr,"SSS")
AADD(aLetraErr,"DDD")
AADD(aLetraErr,"FFF")
AADD(aLetraErr,"GGG")
AADD(aLetraErr,"HHH")
AADD(aLetraErr,"JJJ")
AADD(aLetraErr,"KKK")
AADD(aLetraErr,"LLL")
AADD(aLetraErr,"ÇÇÇ")
AADD(aLetraErr,"ZZZ")
AADD(aLetraErr,"XXX")
AADD(aLetraErr,"CCC")
AADD(aLetraErr,"VVV")
AADD(aLetraErr,"BBB")
AADD(aLetraErr,"NNN")
AADD(aLetraErr,"MMM")

If Left(cNome1,1) = " "
   lOk := .F.
Endif    

If Empty(cNome1)                            
   lOk := .F.
Endif    
         
IF LOK                   
   N1 := 0
   FOR N1 := 1 TO LEN(ALETRAERR)
       N2 := AT(ALETRAERR[N1],RTRIM(CNOME1))
       IF N2 > 0
          lOk := .F.
       ENDIF
   NEXT 
ENDIF           

IF LOK
   N1 := 0                      
   FOR N1 := 1 TO LEN(RTRIM(CNOME1))
       IF SUBSTR(CNOME1,N1,1) = " " 
          IF nGrupo1 = 0
             nGrupo1 := nSoma1
             nSOMA1  := 0
          ELSE
          IF nGrupo2 = 0
             nGrupo2 := nSoma1
             nSOMA1  := 0
          ELSE      
          IF nGrupo3 = 0
             nGrupo3 := nSOMA1
             nSoma1  := 0
          ELSE
          IF nGrupo4 = 0
             nGrupo4 := nSoma1
             nSoma1  := 0
          ELSE
          IF nGrupo5 = 0
             nGrupo5 := nSoma1
             nSoma1  := 0
          ELSE
          IF nGrupo6 = 0
             nGrupo6 := nSoma1
             nSoma1  := 0
          ELSE
          IF nGrupo7 = 0
             nGrupo7 := nSoma1
             nSoma1  := 0
          ELSE
          IF nGrupo8 = 0
             nGrupo8 := nSoma1
             nSoma1  := 0
          ELSE
          IF nGrupo9 = 0
             nGrupo9 := nSoma1
             nSoma1  := 0
          ELSE
          IF nGrupo10 = 0
             nGrupo10 := nSoma1
             nSoma1   := 0
          ENDIF
          ENDIF
          ENDIF
          ENDIF
          ENDIF
          ENDIF
          ENDIF
          ENDIF
          ENDIF
          ENDIF
       ELSE
          nSoma1 += 1 
       ENDIF
   NEXT              
   IF nGrupo1 = 1
      lOk := .F.
   ELSE
     IF nGrupo2 = 1 
        nQtabrev += 1
     ENDIF
     IF nGrupo3 = 1 
        nQtabrev += 1
     ENDIF
     IF nGrupo4 = 1 
        nQtabrev += 1
     ENDIF
     IF nGrupo5 = 1 
        nQtabrev += 1
     ENDIF
     IF nGrupo6 = 1 
        nQtabrev += 1
     ENDIF
     IF nGrupo7 = 1 
        nQtabrev += 1
     ENDIF
     IF nGrupo8 = 1 
        nQtabrev += 1
     ENDIF
     IF nGrupo9 = 1 
        nQtabrev += 1
     ENDIF
     IF nGrupo10 = 1     
        nQtabrev += 1
     ENDIF      
     IF nQtabrev > 2
        lOk := .F.
     ENDIF
   ENDIF  
ENDIF

// QUANTAS PALAVRAS TEM NO NOME
IF LOK
   PALAVRA1 := ALLTRIM(CNOME1)
   QTDPALAVRA := 1
   FOR N1 := 1 TO LEN(PALAVRA1)
       IF SUBSTR(PALAVRA1,N1,1) = " "
          QTDPALAVRA ++
       ENDIF 
   NEXT
   IF QTDPALAVRA = 1
      lOk := .F.
   ENDIF
ENDIF       

// Qtd de Vogais e Consoantes
IF LOK
   N1 := 0     
   nBrancos := 0                 
   FOR N1 := 1 TO LEN(RTRIM(CNOME1))
       If lOk
       IF SUBSTR(CNOME1,N1,1) != " " 
          N2 := 0
          FOR N2 := 1 TO LEN(aVogal)
              IF SUBSTR(CNOME1,N1,1) = aVogal[N2][1]  
                 aVogal[N2][2] += 1
              ENDIF
          NEXT
          N2 := 0
          FOR N2 := 1 TO LEN(aConsoante)
              IF SUBSTR(CNOME1,N1,1) = aConsoante[N2][1]  
                 aConsoante[N2][2] += 1
              ENDIF
          NEXT
       ELSE
 // analisando a palavra
          nBrancos += 1
          nQtdVogais := 0   
          nUsaVogais := 0
          N2 := 0
          FOR N2 := 1 TO LEN(aVogal)
              IF aVogal[N2][2] > 0
                 nQtdVogais += aVogal[N2][2]   
                 nUsaVogais += 1
              ENDIF
          NEXT
          nQtdConsoante := 0   
          nUsaConsoante := 0
          N2 := 0
          FOR N2 := 1 TO LEN(aConsoante)
              IF aConsoante[N2][2] > 0
                 nQtdConsoante += aConsoante[N2][2]   
                 nUsaConsoante += 1
              ENDIF
          NEXT                
          IF nUsaVogais > 0 .and. nUsaConsoante = 0 .and. nbrancos = 1    
             lOk := .F.
          ENDIF
          IF nUsaVogais = 0 .and. nUsaConsoante > 0 .and. nbrancos = 1   
             lOk := .F.
          ENDIF
          N2 := 0
          FOR N2 := 1 TO LEN(aVogal)
              aVogal[N2][2] := 0
          NEXT
          N2 := 0
          FOR N2 := 1 TO LEN(aConsoante)
              aConsoante[N2][2] := 0
          NEXT                
       Endif
       ENDIF
   NEXT     
ENDIF


////


Return lOk
