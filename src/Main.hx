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

        trace('Start node at $address');
        var node = new ChainNode(address, [ address ]);

        var commandsThread = Thread.create(consoleRead);
        commandsThread.sendMessage(Thread.current());

        node.start();
        while( true ) {
            node.tic();

            try {
                var message : String = Thread.readMessage(false);

                if(message == "") {
                    continue;
                }

                var index = message.indexOf(' ');

                if(index == -1) { 
                    index = message.length;
                }

                var command = message.substring(0, index);
                var commandArgs = message.substring(index + 1);

                if(command == "mine") {
                    node.mineBlock(commandArgs);
                } else if (command == "connect") {
                    var words = commandArgs.split(' ');
                    trace('$words');
                    node.connectTo( { url : words[0], port: Std.parseInt(words[1]) } );
                } else if (command == "exit") {
                    node.stop();
                    break;
                }
            }
            catch(e : Dynamic) { }
        }
    }

    static function consoleRead() {
        var mainThread : Thread = Thread.readMessage(true);
        while( true ) {
            var line = Sys.stdin().readLine();
            mainThread.sendMessage(line);
        }
    }
}