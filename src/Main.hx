import neko.vm.Thread;
import haxechain.ChainNode;

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

        var node = new ChainNode(address, [
             { url: "localhost", port : 5000 },
             { url: "localhost", port : 5001 }
        ]);

        var commandsThread = Thread.create(consoleRead);
        commandsThread.sendMessage(node);
        
        node.start();
        while( true ) {
            node.tic(1);
        }
    }

    static function consoleRead() {
        var node : ChainNode = Thread.readMessage(true);

        while( true ) {
            var line = Sys.stdin().readLine();
            
            var words = line.split(' ');

            if(words.length == 0) { 
                continue;
            }

            var command = words[0];
            if(command == "mine") {
                var data = words[1];
                node.mineBlock(data);
            }
        }
    }
}