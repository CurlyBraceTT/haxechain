package tests;

import haxe.unit.TestCase;
import haxechain.ChainNode;

class ItWorksTestCase extends TestCase {
    public function testLookup() {
        var list = [
            { url: "localhost", port : 5000 },
            { url: "localhost", port : 5001 },
            { url: "localhost", port : 5002 }
        ];

        var nodes : Array<ChainNode> = new Array<ChainNode>();
        for(address in list) {
            var node = new ChainNode(address, list);
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
            assertEquals(list.length - 1, node.connectedNodeCount);
        }

        for(node in nodes) {
            node.stop();
        }
    }

    public function testSimpleMineBlock() {
        var node1 = new ChainNode( { url: "localhost", port : 5000 }, []);
        var node2 = new ChainNode( { url: "localhost", port : 5001 }, []);
        node1.start();
        node2.start();

        node1.connectTo(node2.address);
        node2.connectTo(node1.address);

        node1.tic();
        node2.tic();

        node1.mineBlock("Mined by Node1");
        
        node1.tic();
        node2.tic();

        assertEquals(2, node1.chain.length);
        assertEquals(2, node2.chain.length);

        assertTrue(ChainNode.compareBlocks(node1.lastBlock, node2.lastBlock));

        node2.mineBlock("Mined by Node2");

        node1.tic();
        node2.tic();

        assertEquals(3, node1.chain.length);
        assertEquals(3, node2.chain.length);

        assertTrue(ChainNode.compareBlocks(node1.lastBlock, node2.lastBlock));

        node1.stop();
        node2.stop();
    }
}