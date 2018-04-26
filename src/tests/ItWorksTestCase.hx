package tests;

import haxe.unit.TestCase;
import haxechain.ChainNode;

class ItWorksTestCase extends TestCase {
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
    }
}