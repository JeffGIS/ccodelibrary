#ifndef dict_h
#define dict_h


Bool CreateSymConversionTable (HWND hWnd,LPSTR pTable ,short nbytes);
void SetSizePointsFromBounds (LPSYMBOL CurSymbol,LPMNMXCORD pBounds);
Bool OpenSymDict (int Mode);
void CloseSymDict (void);
void DisplayLinearSymbol (HANDLE hSymbol, HDC hDC, double width, int nPnts, LPPOINT Points);
void DisplayAreaSymbol (HANDLE hSymbol, HDC hDC, int nPnts, LPPOINT Points);
HANDLE DisplayPointSymbol (HANDLE hSymbol, HDC hDC, double Vsize,double HSize, double rotation, LPPOINT Point,
						 LPRECT Bounds, Bool Highlight,short nElementsToDisplay, HANDLE hElementToDisplay, Bool SaveCurrentScreen,Bool UseHalftoneVis,LPSTR txt,LPPOINT TextPoly);
int GetDictSymbolNumber (LPSTR SymName); 
HANDLE GetDictSymDesc (int idesc,short opt);
void ConvertSymbol_V1_to_V2 (LPSYMBOL pSym,LPSYMBOL_V1 pSym1);
int GetLineElementWidthAndColor (LPSYMBOL lpSym,LPELEMENT pElement,LPCOLORREF pColor,LPDOUBLE pSymFactor);
short GetDictSymParent (int idesc);
Bool PointIsVisible (int idesc);
Bool SymbolIsVisible (int idesc); 
Bool SymbolIsSolidLine (int idesc);   
int SymbolDisplayPos (int idesc);
Bool SymbolIsLayered (int idesc);  
Bool SymbolIsReversed (int idesc);
COLORREF GetSymbolColor (int idesc); 
double GetSymbolWidth (int idesc); 
short GetDictSymbolType (int idesc); 
Bool GetDictSymName (int idesc,LPSTR Name);
Bool GetDictSymDescription (int idesc,LPSTR Description);
int SaveSymbol (HANDLE hSym,int SymNum);
Bool ReplaceSymbol (int SymNum,HANDLE hCurSymbol);
Bool DeleteSymbol (int SymNum,Bool Close);
int GetSymbol (int SymNum,LPDPOINT pDPoint,HANDLE *hnPnts, HANDLE *hElements);
void DestroySymbol (HANDLE hSymbol);
short SelectSymbol (HWND hWnd,short Type,LPSTR StartSym,short DialogOpt);
short SelectPointSymbol (HWND hWnd,short DialogOpt,LPSTR SymName, LPSTR ParName,LPSTR SymSize, LPSTR SymRot, LPSTR SymColor,Bool AllowAdd);
short SelectFontSymbol (HWND hWnd,LPSTR FontSizeC, COLORREF *Color);
short SelectAreaSymbol (HWND hWnd,short DialogOpt,LPSTR SymName, LPSTR SymColor,Bool AllowAdd);
short SelectLineSymbol (HWND hWnd,short DialogOpt,LPSTR SymName, LPSTR SymSize, LPSTR SymColor,Bool AllowAdd);
short SelectParentSymbol (HWND hWnd,short DialogOpt,LPSTR SymName);
HANDLE AllocateNewElement (void);
HANDLE AllocateNewSymbol (void);
Bool SetPointSize (LPDOUBLE pSize, LPSTR NewPointSize);
Bool SetPointRot (LPDOUBLE pRot, LPSTR NewPointRot);
Bool SetPointColor (long *pColor,LPSTR NewPointColor);
Bool SetLineWidth (LPFLOAT pWidth, LPSTR NewLineWidth);
Bool SetAreaColor (long *pColor,LPSTR NewAreaColor);
Bool SetLineColor (long *pColor,LPSTR NewLineColor);   
Bool SetLineSymbol (LPSHORT	pSym,LPSTR cSym);
Bool SetAreaSymbol (LPSHORT	pSym,LPSTR cSym);
Bool SetPointSymbol (LPSHORT	pSym,LPSTR cSym);
short FillParentList (HWND hWndDlg,UINT Control,short Type);
short AddToParentList (int Parent,HWND hWndDlg,short ControlType,UINT ControlID,LPSTR Tab, LPSTR str, LPSHORT SymLevel);
void GetSymDictChildren (int Parent,LPSHORT pnChildren,LPHANDLE phChildren,int SymType,Bool SearchSubPar);  
void BuildChildList (void);
Bool SetMaxSymNum (short MaxSym);
long SymbolToBuffer (LPSYMBOL CurSymbol, LPHANDLE phBuf,short nDeleteElement,LPINT pDeleteElement); 
HANDLE	BufferToSymbol (HANDLE hBuf);
HPEN DrawSymbolBetweenPoints (HDC hDC,LPFPOINT Point1, LPFPOINT Point2, LPSYMBOL lpSym,LPDOUBLE pCurSymDist, LPSHORT pCurElem,LPDOUBLE pSymFactor,LPSHORT pWantType,
							  short nElementsToDisplay, HANDLE hElementToDisplay,Bool IsLastPoint); 
RECT	GetSymRect (int idesc);
Bool CompressSymDict (void);
int CopySymbolFromDict (LPSTR FromDict,LPSTR SymName,LPSTR NewParent,LPSTR NewName,int FromSymNum,int ToSymNum);
int CopyParentFromDict (LPSTR FromDict,LPSTR ParName,LPSTR NewParent,LPSTR NewParName);
int CopySymbolParents (LPSTR SymbolName,LPSTR FromDict);

#endif
