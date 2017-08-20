LPSTR GetTIGERFileExtension(char FileType);  
Bool LoadCFCCTable (void);
//Bool LoadCitiesTable (void);
//void ConvertClass (LPSTR str);
//void MIFToTIGER (short nPoly,LPSHORT lpnPntsIn,LPHANDLE phDPoints,LPLONG pTLID); 
Bool GetMIFCharacteristics (HFILE FidMIF,LPSTR str,LPLONG lineno);
//DPOINT  OrthoToGround(DPOINT Ortho,LPTRN lptr);
void GetTLIDShapePoints (long TLID,LPSHORT NumShapes,HPDPOINT lpShapes,HFILE FidTIGER2);
Bool WantThisTLID (long TLID,LPTIGER1 Tiger1,LPBool WantAreas, short Pass,HANDLE hCFCC);
Bool GetMIDData(HFILE FidMID,LPSTR lpMIDstr,HANDLE hDLT); 
short StreetNameType (LPSTR STName);
short GetIntersectStuff (long TLID, HANDLE hIntersect,LPTIGER1 Tiger1,LPSHORT Stuff);
Bool GetNextStreet (long TLID, long Snum, HANDLE hIntersect,LPLONG Long, LPLONG Lat, LPLONG NextSNum);
//void CreateStateLev (short State,HWND hWndDlg,int StatusCntl,int MessCntl);
DWORD MIFColorToWinColor (COLORREF MIFColor);
Bool GetDOQCoord (LPSTR File,LPMNMXCORD pBounds, LPDOUBLE pResolution,LPRECT32 ClipRect,HFILE *Fid, LPHANDLE phDibInfo, LPLONG ImageOffset);
short AddPNExtraData (LPTIGER1 Tiger1,LPSHORT pStuff); 

                                   
                                   
