package hxbluetooth;

class BthAddr
{
    public var addr:String;

    public function new(str:String)
    {
        var seperator = ~/(:)/g;
        addr = seperator.replace(str, "").toUpperCase();
    }
}