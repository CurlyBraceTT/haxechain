package tests;

import haxe.unit.TestCase;
import haxechain.ChainNode;

class ItWorksTestCase extends TestCase {
    public var output : Bool;

    public function new (output : Bool = true) {
        super();
        this.output = output;
    }

    public function testLookup() {
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

        for(node in nodes) {
            node.lookup();
        }

        for(node in nodes) {
            node.accept();
        }

        for(node in nodes) {
            node.stop();
        }

        for(node in nodes) {
            assertEquals(list.length - 1, node.connectedNodeCount);
        }
    }

    public function testSimpleMineBlock() {
        var list = [
            { url: "localhost", port : 5000 },
            { url: "localhost", port : 5001 }
        ];

        var nodes : Array<ChainNode> = new Array<ChainNode>();
        for(address in list) {
            var node = new ChainNode(address, list, output);
            nodes.push(node);
            node.start();
        }

        for(node in nodes) {
            node.lookup();
        }

        for(node in nodes) {
            node.accept();
        }

        for(i in 0...3) {
            for(node in nodes) {
                node.tic();
            }
        }

        nodes[0].mineBlock("Mined by Node1");

        for(i in 0...3) {
            for(node in nodes) {
                node.tic();
            }
        }

        nodes[1].mineBlock("Mined by Node2");

        for(i in 0...3) {
            for(node in nodes) {
                node.tic();
            }
        }

        for(node in nodes) {
            node.stop();
        }

        assertEquals(3, nodes[0].chain.length);
        assertEquals(3, nodes[1].chain.length);

        assertEquals(1, nodes[0].connectedNodeCount);
        assertEquals(1, nodes[1].connectedToNodeCount);

        assertTrue(ChainNode.compareBlocks(nodes[0].lastBlock, nodes[1].lastBlock));
    }
}