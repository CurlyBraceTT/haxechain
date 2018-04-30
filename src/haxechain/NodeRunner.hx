package haxechain;

import neko.vm.Thread;
import haxechain.ChainNode;

class NodeRunner {
    public static function run(address : NodeAddress) {
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