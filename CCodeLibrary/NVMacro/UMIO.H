
Bool	OpenUM (void);
void	CloseUM (Bool Error);
int		GetList (HWND hWndDlg,int dialogItem,LPSTR listid);
int		GetListCB (HWND hWndDlg,int dialogItem,LPSTR listid);
int 	GetListSub (HWND hWndDlg,int dialogItem, int RESET, int ADD, LPSTR listid);
void	SendUMMessage (LPSTR message);
int		GetUMMessage (LPSTR message);
void CBInitIO (UserInfo UI2);
int OpenTCPIPSocket (HWND hWnd,LPSTR TCPAddress,USHORT Port,SOCKET *pSock,LPSTR InputTerminator,LPSTR InputProcessString,LPSTR CloseProcessString,LPSTR RestartProcessString,Bool Notify);
short SendTCPIPString (SOCKET socket,LPSTR string,Bool SendNullTerm,UINT WaitSeconds); 
Bool SetupSocketTimer (SOCKET socket,long Seconds,LPSTR TimerString);
Bool SetupSocketTerminator (SOCKET socket,LPSTR Term);
void ProcessSocketTimer (int TimerID);
void ProcessSocketError (SOCKET sock,int err,LPSTR Info);
Bool OpenWinSock (void);
void CloseWinSock (Bool ProcessCloseString);
Bool ProcessTCPData (SOCKET sock);
Bool ProcessTCPCmd (SOCKET sock,LPSTR Cmd);
Bool AcceptTCPConnection (HWND hWnd,SOCKET sock);
Bool CloseTCPIPSocket (SOCKET socket,Bool ProcessCloseString);
Bool RestartSocket (SOCKET sock); 
Bool OpenTCPIPServer (LPSTR IPAddress,USHORT Port); 
Bool OpenTCPIPServer2 (HWND hWnd);
short CheckForRegistrationServer (HWND hWnd,LPSTR SerialNum);
Bool FAR PASCAL REGCONNECTMsgProc(HWND hWndDlg, int Message, WPARAM wParam, LPARAM lParam);
Bool BlockSocketProcessing (Bool Block);
void SetLogSocketIO (Bool set);
Bool OpenTCPReplay (LPSTR ReplayFile);
void ProcessReplayTCPTimer (void);
void DisplayLenSocketBuffer (int i);
int GetSocketID (SOCKET sock);
Bool GetMyIPNetAddress (LPSTR inetAddr);
Bool PaintServerInfo (HDC hDC,LPRECT pRect); 
SOCKET connectToServer ( char *serverName, u_short port,Bool UpdateServerOpen, LPINT perr );
Bool ReadNTBlock (SOCKET sock,LPSTR pBuf,long lBuf);
Bool SendNTBlock (SOCKET sock,LPSTR pBuf,long lBuf);
void ResetSocketLog(void);
void LogServerActivity(LPSTR Mess);



