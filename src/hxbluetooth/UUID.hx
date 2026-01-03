package hxbluetooth;

import cpp.Int64;
import hxbluetooth.GUIDStruct;

@:headerCode('
    #include <guiddef.h>
')
class UUID
{
    public var uuid:String;

    public function new(id:String)
    {
        var seperator = ~/(-)/g;
        uuid = seperator.replace(id, "").toUpperCase();
    }

    public function toGuid():GUIDStruct
    {
        var guid = new GUIDStruct();

        guid.Data1 = parseLongHex('0x${uuid.substr(0,8)}');
        guid.Data2 = Std.parseInt('0x${uuid.substr(8,4)}');
        guid.Data3 = Std.parseInt('0x${uuid.substr(12,4)}');
        guid.Data4[0] = Std.parseInt('0x${uuid.substr(16,2)}');
        guid.Data4[1] = Std.parseInt('0x${uuid.substr(18,2)}');
        guid.Data4[2] = Std.parseInt('0x${uuid.substr(20,2)}');
        guid.Data4[3] = Std.parseInt('0x${uuid.substr(22,2)}');
        guid.Data4[4] = Std.parseInt('0x${uuid.substr(24,2)}');
        guid.Data4[5] = Std.parseInt('0x${uuid.substr(26,2)}');
        guid.Data4[6] = Std.parseInt('0x${uuid.substr(28,2)}');
        guid.Data4[7] = Std.parseInt('0x${uuid.substr(30,2)}');

        return guid;
    }

    //hxcpp Str.parseInt() casts to 32bit, but GUID Data1 needs 64bit
    @:functionCode('
        hx::strbuf buf;
        const char *str = inString.utf8_str(&buf);

        long result;
        result = strtoul(str,0,16);

        return result;
    ')
    public static function parseLongHex(inString:String):Int64
    {return 0x0;}
}
