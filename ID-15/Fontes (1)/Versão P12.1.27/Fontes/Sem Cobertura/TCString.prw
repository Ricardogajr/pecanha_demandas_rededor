#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECTS.CH"
#INCLUDE "FILEIO.CH"

#DEFINE 1MB 1048575
#DEFINE TAMMAX 10

// Dummy function
User Function TCString() 
Return

//-------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TCString
Classe que deve ser utilizada quando houver a necessidade de se utilizar strings maiores do que 1MB a fim de evitar o erro String Size Overflow
@attrib aString Array com o string a ser trabalhado pelo desenvolvedor
@attrib nBuffer Tamanho do buffer da ultima posicao do array
@attrib nQtdItem Quantidade de itens no array aString

@owner Alex Sandro
@author Rafael Mota Previdi
@since 05/12/2013
/*/
//------------------------------------------------------------------------------------------------------------------------------------------
 

CLASS TCString

DATA aString
DATA nBuffer
DATA nQtdItem
DATA cPath
DATA cArq
DATA lGerArq

METHOD New() CONSTRUCTOR
METHOD SetString(cString)
METHOD Str2File()
METHOD Clear()

ENDCLASS

//----------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe

@owner Alex Sandro
@author Rafael Mota Previdi
@since 05/12/2013
/*/
//----------------------------------------------------------------------------------------------------------------------------
METHOD New() CLASS TCString

::aString	:= {""}
::nBuffer	:= 0
::nQtdItem	:= 1
::cPath	:= ""
::cArq		:= ""
::lGerArq   := .T. 
Return SELF

//----------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetString
Metodo que preencher o string
@param cString String a ser armazenado no atributo a String

@owner Alex Sandro
@author Rafael Mota Previdi
@since 05/12/2013
/*/
//----------------------------------------------------------------------------------------------------------------------------
METHOD SetString(cString) CLASS TCString

Local nTamStr	:= 0		// tamanho do string a ser setado em aString
Local nPosQbr	:= 0		// Posicao da quebra do cString para evitar o string size overflow
Local nQtdExt	:= 0		// Qtd de caracteres extra temos em cString que irao arrebentar o 1MB  

DEFAULT cString := ""

nTamStr := LEN(cString)

// Buffer vai estourar o limite
If (::nBuffer+nTamStr) >= 1MB
	
	If TAMMAX == ::nQtdItem
		//Conout(	"O string não pode extrapolar o tamanho de " + ALLTRIM(STR(TAMMAX)) + "MB." + CRLF +;
		//			"Portanto, o objeto será resetado.")
		SELF:Clear() 
		::lGerArq := .F.
		Return 
	Endif
	
	// Adiciona parte do string na ultima posicao atual de ::aString
	nQtdExt := (::nBuffer+nTamStr) - 1MB
	nPosQbr := nTamStr - nQtdExt	
	If nPosQbr > 0
		::aString[::nQtdItem] += Substr(cString, 1, nPosQbr)
	Endif
	
	// Adiciona o restante na nova utlima posicao atual de ::aString
	aAdd(::aString, "")
	::nQtdItem := LEN(::aString)
	If nPosQbr > 0
		::aString[::nQtdItem] += Substr(cString, nPosQbr+1)
	Else
		::aString[::nQtdItem] += cString
	Endif
	
	::nBuffer := LEN(::aString[::nQtdItem])
	
	Return 
Endif

// Buffer ainda nao vai estourar
::aString[::nQtdItem] += cString
::nBuffer := LEN(::aString[::nQtdItem])

Return 

//----------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Str2File
Descarrega o atributo aString em um arquivo

@owner Alex Sandro
@author Rafael Mota Previdi
@since 05/12/2013
/*/
//----------------------------------------------------------------------------------------------------------------------------
METHOD Str2File() Class TCString

Local nCnt		:= 0	// Variavel para loop For
Local nHandle	:= 0	// Handle para abrir o arquivo

nHandle := FCREATE(::cPath + "\" + ::cArq, FC_NORMAL)

IF nHandle == -1
	//Conout("O Arquivo não foi criado:" + STR(FERROR()))
ELSE
	// Escrever o arquivo
	For nCnt := 1 To LEN(::aString)
		FWRITE(nHandle, ::aString[nCnt])
	Next nCnt
	FCLOSE(nHandle)
ENDIF

Return

//----------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Clear
Limpa o atributo aString e os outros atributos relacionados

@owner Alex Sandro
@author Rafael Mota Previdi
@since 05/12/2013
/*/
//----------------------------------------------------------------------------------------------------------------------------
METHOD Clear() Class TCString

Local nCnt		:= 0	// Variavel para loop For

For nCnt := 1 To LEN(::aString)
	aDel(::aString, nCnt)
Next nCnt

aSize(::aString, 0)

::aString	:= {""}
::nBuffer	:= 0
::nQtdItem	:= 1

Return