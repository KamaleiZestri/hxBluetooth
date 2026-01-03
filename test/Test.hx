package ;

import hxbluetooth.BluetoothSocket;
import hxbluetooth.BthAddr;
import hxbluetooth.UUID;

class Test
{
    public static function main ():Void 
    {
        //TODO testClient();
        testServer();
    }

    public static function testClient()
    {
        var guid = new UUID("8a8478c9-2ca8-404b-a0de-101f34ab71ae");
        var addr = new BthAddr("34:88:5D:AE:41:FD");
        var clientSocket = new BluetoothSocket();

        clientSocket.connect(guid,addr);
        Sys.println('Now connected to ${clientSocket.peer()}');
        //TODO clientSocket.write("Testing! You Pass!");
        clientSocket.close();
    }
    
    public static function testServer()
    {
        var guid = new UUID("8a8478c9-2ca8-404b-a0de-101f34ab71ae");
        var name = "hxBluetooth";
        var comment = "Test bluetooth server for hxBluetooth";

        // Init server socket
        var blueServer = new BluetoothSocket();
        blueServer.bind(guid,name,comment);
        blueServer.listen();
        Sys.println("Waiting for connection...");

        // Wait for connecting client
        var client = blueServer.accept();
        Sys.println('Now connected to ${client.peer()}');

        // Read one message from connected client.
        trace(client.read());
        
        // Close server socket.
        client.close();
        Sys.println("Disconnected.");
        blueServer.close();
    }
}
