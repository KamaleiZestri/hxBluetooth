#include <hxcpp.h>

#include <string>
#include <iostream>
#include <sstream>


#include <winsock2.h>
#include <ws2bth.h>
#include <BluetoothAPIs.h>


#pragma comment(lib, "Bthprops.lib")
#pragma comment(lib, "Ws2_32.lib")

//TODO https://github.com/HaxeFoundation/hxcpp/blob/master/src/hx/libs/std/Socket.cpp
// TODO void _hx_std_socket_send_char( Dynamic o, int c )
// TODO int _hx_std_socket_send( Dynamic o, Array<unsigned char> buf, int p, int l )
// TODO int _hx_std_socket_recv_char( Dynamic o )
// TODO void _hx_std_socket_write( Dynamic o, Array<unsigned char> buf )

// bth_addr is just a 48 bit integer...
std::string btaddrToString(BTH_ADDR blueAddr)
{
    std::stringstream tempstream;
    std::string tempstr = "";
    std::string result ="";

    tempstream << std::hex << blueAddr;
    tempstream >> tempstr;

    while(tempstr.length()>1)
    {
        result += toupper(tempstr[0]); 
        result += toupper(tempstr[1]);
        tempstr = tempstr.substr(2,tempstr.length()-2);

        if (tempstr.length()>1)
            result += ":";
    }
    
    return result;
}


/**
    https://learn.microsoft.com/en-us/windows/win32/api/winsock/nf-winsock-wsastartup
*/
void _hx_bluetooth_socket_init()
{
    WSADATA wsd;
    if (0 != WSAStartup(MAKEWORD(2, 2), &wsd))
    {
        hx::Throw(HX_CSTRING("Unable to load WinSock version 2.2!"));
    }
}

/**
    https://learn.microsoft.com/en-us/windows/win32/api/winsock2/nf-winsock2-socket
**/
int _hx_bluetooth_socket_new()
{
    SOCKET blueSocket = socket(AF_BTH, SOCK_STREAM, BTHPROTO_RFCOMM);
        
    if (INVALID_SOCKET == blueSocket)
    {
        hx::Throw(HX_CSTRING("Socket is invalid. WSA Error No: ") + WSAGetLastError());
    }

    // TODO hxcpp uses a socket wrapper?
    return (INT) blueSocket;
}

void hx_bluetooth_socket_bind(int socket)
{
    SOCKET blueSocket = (SOCKET) socket;

    SOCKADDR_BTH blueInfo = SOCKADDR_BTH();
    blueInfo.addressFamily = AF_BTH;
    blueInfo.port = BT_PORT_ANY; //dynamic

    if (SOCKET_ERROR == bind(blueSocket, (struct sockaddr *) &blueInfo, sizeof(SOCKADDR_BTH)))
    {
        hx::Throw(HX_CSTRING("Error binding socket. WSA Error No: ") + WSAGetLastError());
    }
}

/**
    https://learn.microsoft.com/en-us/windows/win32/api/winsock/nf-winsock-getsockname
    https://learn.microsoft.com/en-us/windows/win32/api/winsock2/nf-winsock2-wsasetservicea
**/
void hx_bluetooth_socket_advertise(int socket, GUID uuid, std::string name, std::string comment)
{
    SOCKET blueSocket = (SOCKET) socket;

    SOCKADDR_BTH blueInfo = SOCKADDR_BTH();
    int addrlen = sizeof(SOCKADDR_BTH);

    getsockname(blueSocket, (struct sockaddr *) &blueInfo, &addrlen);

    CSADDR_INFO sockInfo;
    sockInfo.iProtocol = BTHPROTO_RFCOMM;
    sockInfo.iSocketType = SOCK_STREAM;
    sockInfo.LocalAddr.iSockaddrLength = sizeof(SOCKADDR_BTH);
    sockInfo.LocalAddr.lpSockaddr = (LPSOCKADDR) &blueInfo;
    sockInfo.RemoteAddr.iSockaddrLength = sizeof(SOCKADDR_BTH);
    sockInfo.RemoteAddr.lpSockaddr = (LPSOCKADDR) &blueInfo;

    WSAQUERYSET wsaq = {0};
    wsaq.lpszServiceInstanceName = (LPSTR) &name;
    wsaq.lpszComment = (LPSTR) &comment;
    wsaq.lpServiceClassId = (LPGUID) &uuid;
    wsaq.dwNameSpace = NS_BTH;
    wsaq.dwNumberOfCsAddrs = 1;
    wsaq.dwSize = sizeof(WSAQUERYSET);
    wsaq.lpcsaBuffer = &sockInfo;
    
    if (SOCKET_ERROR ==  WSASetService(&wsaq, RNRSERVICE_REGISTER, 0))
    {
        hx::Throw(HX_CSTRING("Error advertising service. WSA Error No: ") + WSAGetLastError());
    }
}

/**
    https://learn.microsoft.com/en-us/windows/win32/api/winsock2/nf-winsock2-listen
**/
void hx_bluetooth_socket_listen(int socket, int connectionsCount)
{
    SOCKET blueSocket = (SOCKET) socket;

    if (SOCKET_ERROR == listen(blueSocket, connectionsCount))
    {
        hx::Throw(HX_CSTRING("Error listening on socket. WSA Error No: ") + WSAGetLastError());
    }
}

int hx_bluetooth_socket_accept(int socket)
{
    SOCKET blueSocket = (SOCKET) socket;

    SOCKADDR_BTH clientInfo;
    int clientInfoSize = sizeof(SOCKADDR_BTH) * 2;
    SOCKET client = accept(blueSocket, (struct sockaddr *) &clientInfo, &clientInfoSize);
   
    if (INVALID_SOCKET == client)
    {
        hx::Throw(HX_CSTRING("Error creating server-client socket. WSA Error No: ") + WSAGetLastError());
    }

    return (INT) client;
}


std::string hx_bluetooth_socket_host(int socket)
{
    SOCKET blueSocket = (SOCKET) socket;
    SOCKADDR_BTH blueInfo = SOCKADDR_BTH();
    int addrlen = sizeof(SOCKADDR_BTH);

    if (SOCKET_ERROR == getsockname(blueSocket, (struct sockaddr *) &blueInfo, &addrlen))
    {
        hx::Throw(HX_CSTRING("Error getting host socket name. WSA Error No: ") + WSAGetLastError());
    }

    return btaddrToString(blueInfo.btAddr);
}

std::string hx_bluetooth_socket_peer(int socket)
{
    SOCKET blueSocket = (SOCKET) socket;
    SOCKADDR_BTH clientInfo = SOCKADDR_BTH();
    int addrlen = sizeof(SOCKADDR_BTH);

    if (SOCKET_ERROR == getpeername(blueSocket, (struct sockaddr *) &clientInfo, &addrlen))
    {
        hx::Throw(HX_CSTRING("Error getting client socket name. WSA Error No: ") + WSAGetLastError());
    }

    return btaddrToString(clientInfo.btAddr);
}

/**
    <doc>Read up to [length] bytes into [buffer] starting at [position] from a connected [socket].
    Return the number of bytes read.</doc>
**/
int hx_bluetooth_socket_recv(int socket, Array<unsigned char> buffer, int position, int length)
{
    SOCKET clientSocket = (SOCKET) socket;

    // TODO safety?
    // int dlen = buf->length;
    // if( p < 0 || l < 0 || p > dlen || p + l > dlen )
    //   return 0;

    char *textBuffer = (char *)&buffer[0];
    //is 0 on disconnect of bluetooth client.
    int readBytes = recv(clientSocket , textBuffer + position, length, 0);
    return readBytes;
}


std::string hx_bluetooth_socket_read(int client)
{
    SOCKET clientSocket = (SOCKET) client;
    char* textBuffer = new char[1024];
    std::string text = "";
    
    while (true)
    {
        int length = recv(clientSocket, textBuffer, 1024, 0);
        if (length <= 0) //occurs on disconnect of bluetooth client. needed for clean break instead of error.
            break;
        // std::string text (textBuffer, length);
        std::string text = textBuffer;
    }
    return text;
}

void hx_bluetooth_socket_connect(int socket, GUID uuid,unsigned long addr)
{
    SOCKET blueSocket = (SOCKET) socket;
    BTH_ADDR btaddr = (BTH_ADDR) addr;

    SOCKADDR_BTH blueInfo;
    blueInfo.addressFamily = AF_BTH;
    blueInfo.serviceClassId = uuid;
    //TODO need tht btAddr of the server. uhhhh how get? 64byte int
    blueInfo.btAddr = btaddr;

    int addrlen = sizeof(SOCKADDR_BTH);

    if (INVALID_SOCKET == connect(blueSocket, (struct sockaddr *) &blueInfo, addrlen))
    {
        hx::Throw(HX_CSTRING("Error connecting to server. WSA Error No: ") + WSAGetLastError());
    }
}

/**
   socket_close : 'socket -> void
   <doc>Close a socket. Any subsequent operation on this socket will fail</doc>
**/
void hx_bluetooth_socket_close(int socket)
{
    // https://learn.microsoft.com/en-us/windows/win32/api/winsock/nf-winsock-closesocket
    SOCKET blueSocket = (SOCKET) socket;
    closesocket(blueSocket);
    WSACleanup();
}
