#ifndef client_h
#define client_h



/* Maximum sizes */

#define APP_MAX_SIZE		 32
#define TOPIC_MAX_SIZE		 500
#define ITEM_MAX_SIZE		 200
#define VALUE_MAX_SIZE           32
#define EXECUTE_STRING_MAX_SIZE  100
#define CONV_MAX_COUNT		 32
#define ITEMS_PER_CONV_MAX_COUNT 5
#define CONVINFO_MAX_SIZE (APP_MAX_SIZE+TOPIC_MAX_SIZE+ITEM_MAX_SIZE+22)

/* Global data */

/* Typdef's shared across modules */

enum PENDINGACK
{
    NONE,
    ADVISE,
    UNADVISE,
    POKE,
    REQUEST,
    EXECUTE,
};

/* External procedures in CLIENT.C */

Bool IsInRequestDlg(void);
void RequestSatisfied(LPSTR);

/* External procedures in CLIDATA.C */
int GetNumConv(void);
void LdaReceiveData(LPSTR lpDDEData);
Bool AddItemToConv(HWND, char*);
Bool AddConv(HWND, HWND, char*, char*);
Bool AtLeastOneConvActive(void);
Bool DoesAdviseAlreadyExist(HWND, char*);
HWND FindConvGivenAppTopic(char *, char*);
void GetAppAndTopic(HWND, char*, char*);
HWND GetHwndServerDDE(HWND);
HWND GetNextConv(HWND);
enum PENDINGACK GetConvPendingAck(HWND);
int  HexToInt(char *);
void InitDataTextMetrics(void);
Bool IsConvInTerminateState(HWND, HWND);
Bool IsHwndClientDDEUsed(HWND);
Bool LetUserPickConversation(HWND);
void PaintConvData(HWND);
Bool RemoveItemFromConv(HWND, char*);
Bool RemoveConv(HWND, HWND);
void SetConvInTerminateState(HWND, HWND);
Bool SetConvItemValue(HWND, char*, LPSTR);
void SetConvPendingAck(HWND, enum PENDINGACK);


/* External Procedures in CLIDDE.C */

void ClientAcknowledge(HWND, HWND, LONG, Bool);
void ClientReceiveData(HWND, HWND, LONG);
void ClientTerminate(HWND, HWND);
long FAR PASCAL DDEWndProc(HWND, UINT, WPARAM, LPARAM);
void DoPasteLink(void);
void InitAckTimeOut(void);
void SendAdvise(HWND, HWND, char*);
void SendExecute(HWND, HWND, char*);
HWND SendInitiate(char *, char*);
HWND SendSQL(HWND, char *, char*);
void SendPoke(HWND, HWND, char*, char*);
void SendRequest(HWND, HWND, char*);
void SendTerminate(HWND, HWND);
void SendUnadvise(HWND, HWND, char*);
void TerminateConversations(HWND hWndClient);
static int nAckTimeOut;

#endif
