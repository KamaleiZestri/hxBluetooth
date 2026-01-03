package hxbluetooth;

import cpp.Char;
import cpp.Int32;
import cpp.Int64;

// https://learn.microsoft.com/en-us/windows/win32/api/guiddef/ns-guiddef-guid
@:keep
@:unreflective
@:structAccess
@:native("GUID")
extern class GUIDStruct 
{
    public var Data1:Int64;
    public var Data2:Int32;
    public var Data3:Int32;
    public var Data4:Array<Char>;

    public function new()
    {
        Data1=0;
        Data2=0;
        Data3=0;
        Data4=[0,0,0,0,0,0,0];
    }

}

