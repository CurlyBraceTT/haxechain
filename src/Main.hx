import haxechain.NodeRunner;

class Main {
    static function main() {
        var address = { url : "localhost", port: 5000 };
        var arguments = Sys.args();

        if(arguments.length > 0) {
            address.url = arguments[0];
        }
        if(arguments.length > 1) {
            address.port = Std.parseInt(arguments[1]);
        }

        trace('Start node at $address');
        NodeRunner.run(address);
    }
}