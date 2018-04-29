package tests;

import haxe.unit.TestCase;
import haxechain.ChainNode;

class SyncTestCase extends TestCase {
    public var output : Bool;

    public function new (output : Bool = true) {
        super();
        this.output = output;
    }

    public function testSimpleSync() {
        var list = [
            { url: "localhost", port : 5000 },
            { url: "localhost", port : 5001 },
            { url: "localhost", port : 5002 }
        ];

        var nodes : Array<ChainNode> = new Array<ChainNode>();
        for(address in list) {
            var node = new ChainNode(address, list, output);
            nodes.push(node);
            node.start();
        }

        // Fill one the chaines with data before connections
        for(i in 0...3) {
            nodes[0].mineBlock('Test mine');
        }

        for(node in nodes) {
            node.lookup();
        }

        for(node in nodes) {
            node.accept();
        }

        for(i in 0...10) {
            for(node in nodes) {
                node.tic();
            }
        }

        for(node in nodes) {
            node.stop();
        }

        for(node in nodes) {
            // 3 mined + genesis
            assertEquals(4, node.chain.length);
        }
    }
}