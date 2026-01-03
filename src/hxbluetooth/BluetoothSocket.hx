package hxbluetooth;

import cpp.StdString;
import haxe.io.Bytes;
import hxbluetooth.BthAddr;
import hxbluetooth.NativeBluetoothSocket;
import hxbluetooth.UUID;

private class BluetoothSocketInput extends haxe.io.Input
{
    public var socketHandle:Int;

    public function new(socket:Int)
    {
        socketHandle = socket;
    }

    // public override function readByte()
    // {}

    // public override function readBytes()
    // {}

    // public override function close()
    // {
    //     // super.close();
    //     NativeBluetoothSocket.socket_close(socketHandle);
    // }
}

// TODO write bluetooth out????

// @:headerCode('
//     #include <guiddef.h>
// ')
class BluetoothSocket
{
    private var input:BluetoothSocketInput;
    // private var output:BluetoothSocketOutput;

    /**
		Creates a new unconnected bluetooth socket.
	**/
    public function new():Void
    {
        NativeBluetoothSocket.socket_init();
        var socket = NativeBluetoothSocket.socket_new();
        input = new BluetoothSocketInput(socket);
        // output = new BluetoothSocketOutput(socket)
    }

    public function close():Void
    {
        input.close();
        // output.close;
    }

    /**
		Read whole data available on the socket.
    **/
    public function read():String 
    {
        // TODO this should be like native; block until connection closes
        var buffer = Bytes.alloc(1024);
        var res = NativeBluetoothSocket.socket_recv(input.socketHandle, buffer.getData(), 0 , 1024);
        // var arr:Array<cpp.Char> = cast buffer;
        // var temp = NativeString.fromPointer(Pointer.ofArray(arr));
        if (res > 0)
            return buffer.toString();
        return "";
    }

    // TODO write function...
    // public function write(content:String):Void
    

    /**
        Bind the socket to the first available bluetooth port
        Advertise the bluetooth server to the OS.
        Can only connect to clients searching for the same uuid.
    **/
    public function bind(uuid:UUID, name:String, comment:String = ""):Void
    {
        NativeBluetoothSocket.socket_bind(input.socketHandle);

        NativeBluetoothSocket.socket_advertise(input.socketHandle, 
            uuid.toGuid(),
            StdString.ofString(name), 
            StdString.ofString(comment));
    }

    /**
        Allow socket to listen for clients. Follow up with "accept() to connect to the clients."
    **/
    public function listen(connections:Int = 1)
    {
        NativeBluetoothSocket.socket_listen(input.socketHandle, connections);
    }

    public function accept():BluetoothSocket
    {
        var client = NativeBluetoothSocket.socket_accept(input.socketHandle);
        //avoid constructor to avoid brand new init.
        var clientSocket = Type.createEmptyInstance(BluetoothSocket);
        clientSocket.input = new BluetoothSocketInput(client);
        //cleintSOcket.output.socketHandle = new BluetoothSocketOutput(socket)
        return clientSocket;
    }

    public function connect(uuid:UUID, address:BthAddr):Void
    {
        // TODO WRITE CONNECT THEN WRITE THEN TEST 
        NativeBluetoothSocket.socket_connect(
            input.socketHandle, uuid.toGuid(),
            UUID.parseLongHex(address.addr));
        //TODO ugly looking call above
    }

    /**
        Provides the bluetooth address of the host.
    **/
    public function host():String
    {
        var answer = NativeBluetoothSocket.socket_host(input.socketHandle);
        return answer.toString();
    }

    /**
        Provides the bluetooth address of the client.
    **/
    public function peer():String
    {
        var answer = NativeBluetoothSocket.socket_peer(input.socketHandle);
        return answer.toString();
    }
}