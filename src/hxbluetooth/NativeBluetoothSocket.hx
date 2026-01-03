package hxbluetooth;

import cpp.Int64;
import cpp.StdString;
import haxe.io.BytesData;
import hxbluetooth.GUIDStruct;
// TODO copy of this file from std: 
// https://github.com/HaxeFoundation/haxe/blob/4.3.7/std/cpp/NativeSocket.hx

//TODO may need to add more for linux...
// https://github.com/HaxeFoundation/hxcpp/blob/master/src/hx/libs/std/Build.xml
@:buildXml("
    <target id='haxe'>
        <lib name='Ws2_32.lib' if='windows'/>
        <lib name='Bthprops.lib' if='windows'/>
    </target>
")
@:include("./BluetoothSocket.cpp")
extern class NativeBluetoothSocket
{
    @:native("_hx_bluetooth_socket_init")
	static function socket_init():Void;

    @:native("_hx_bluetooth_socket_new")
    static function socket_new():Int;

    @:native("hx_bluetooth_socket_bind")
    static function socket_bind(socket:Int):Void;

    @:native("hx_bluetooth_socket_advertise")
    static function socket_advertise(socket:Int, uuid:GUIDStruct, name:StdString, comment:StdString):Void;

    @:native("hx_bluetooth_socket_listen")
    static function socket_listen(socket:Int, connectionsCount:Int):Void;

    @:native("hx_bluetooth_socket_accept")
    static function socket_accept(socket:Int):Int;

    @:native("hx_bluetooth_socket_recv")
    static function socket_recv(socket:Int, buffer:haxe.io.BytesData, pos:Int, length:Int):Int;

    @:native("hx_bluetooth_socket_read")
    static function socket_read(socket:Int):StdString;

    @:native("hx_bluetooth_socket_close")
    static function socket_close(socket:Int):Int;

    @:native("hx_bluetooth_socket_host")
    static function socket_host(socket:Int):StdString;

    @:native("hx_bluetooth_socket_peer")
    static function socket_peer(socket:Int):StdString;

    @:native("hx_bluetooth_socket_connect")
    static function socket_connect(socket:Int, uuid:GUIDStruct, addr:Int64):Void;
}
