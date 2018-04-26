package haxechain;

import sys.net.Socket;
import sys.net.Host;
import haxe.crypto.Sha256;
import haxe.Json;

typedef NodeAddress = { url : String, port : Int };
typedef Block = { index : Int, previousHash : String, timestamp : Float, data : String, hash : String };

class ChainNode {
    public var logsEnabled(default, default) : Bool;
    public var chain (default, null) : Array<Block>;

    public var lastBlock (get, null) : Block;
    public function get_lastBlock() {
        return this.chain[chain.length - 1];
    }

    public var connectedNodeCount (get, null) : Int;
    public function get_connectedNodeCount() {
        return this._acceptedConnections.length;
    }

    public var address (default, null) : NodeAddress;
    public var nodesList (default, null) : Array<NodeAddress>;

    private var _host : Host;
    public var _socket : Socket;

    private var _connections : Array<Socket>;
    private var _acceptedConnections : Array<Socket>;

    public function new(address : NodeAddress, nodesList : Array<NodeAddress>, logsEnabled : Bool = false) {
        this.address = address;
        this.nodesList = nodesList;
        this._connections = new Array<Socket>();
        this._acceptedConnections = new Array<Socket>();
        this.logsEnabled = logsEnabled;

        this.chain = [ this.getGenesisBlock() ];
    }

    function getGenesisBlock() : Block {
        return createBlock(0, "0", 1465154705, "my genesis block!!", "816534932c2b7154836da6afc367695e6337db8a921823784c14378abed4f7d7");
    }

    public function start() : Void {
        this._host = new Host(this.address.url);
        this._socket = new Socket();
        this._socket.bind(this._host, this.address.port);
        this._socket.listen(10);
        this._socket.setBlocking(false);
    }

    public function stop() : Void {
        this._socket.close();
        for(c in this._connections) {
            c.close();
        }
        for(c in this._acceptedConnections) {
            c.close();
        }
    }

    public function lookup() {
        for(address in this.nodesList) {
            if(address.url == this.address.url && address.port == this.address.port) { 
                continue; //same node;
            }

            var alreadyConnected = false;
            for(c in this._connections) {
                if(c.custom.url == address.url && c.custom.port == address.port) {
                    alreadyConnected = true;
                }
            }

            if(alreadyConnected) {
                continue;
            }

            this.connectTo(address);
        }
    }

    public function connectTo(address : NodeAddress) {
        var c = new Socket();

        try {
            c.connect(new Host(address.url), address.port);
            c.setBlocking(false);
            c.custom = address;
            this._connections.push(c);
            this.log('Successfully connected to $address');
        }
        catch(e : Dynamic) {
            this.log('Can not connect to $address [$e]');
        }

        return c;
    }

    public function mineBlock(data : String) {
        var block : Block = this.generateNewBlock(data);
        this.chain.push(block);

        var message = {
            type: "block",
            block: block
        };
        var serialized = Json.stringify(message) + "\n";
        this.log('new block mined [${message.block.data}]');

        this.broadcast(serialized);
    }

    function generateNewBlock(data : String) {
        var previousBlock = this.lastBlock;
        var nextIndex = previousBlock.index + 1;
        var nextTimestamp = Date.now().getTime();
        var nextHash = this.calculateHash([nextIndex, previousBlock.hash, nextTimestamp, data]);
        return createBlock(nextIndex, previousBlock.hash, nextTimestamp, data, nextHash);
    }

    function isValidNewBlock(newBlock : Block, previousBlock : Block) : Bool {
        if (previousBlock.index + 1 != newBlock.index) {
            this.log('invalid block index');
            return false;
        } else if (previousBlock.hash != newBlock.previousHash) {
            this.log('invalid previous hash');
            return false;
        } else if (this.calculateHashForBlock(newBlock) != newBlock.hash) {
            this.log('invalid hash');
            return false;
        }
        
        return true;
    }

    function calculateHashForBlock(block : Block) : String {
        return this.calculateHash([block.index, block.previousHash, block.timestamp, block.data]);
    }

    function calculateHash(args : Array<Dynamic>) {
        var str = '';

        for(arg in args) {
            str += Std.string(arg);
        }

        return Sha256.encode(str);
    }

    function broadcast(message : String) {
        for(c in this._connections) {
            this.log('Sending message...');
            c.write(message);
        }
    }

    public function readAll() : Void {
        try {
            var selected = Socket.select(this._acceptedConnections, null, null, 0);

            for(c in selected.read) {
                var str = c.input.readLine();
                this.log('Got message: $str');

                var message = Json.parse(str);

                if(message.type == "block") {
                    var isValid = this.isValidNewBlock(message.block, this.lastBlock);
                    if(isValid) {
                        this.chain.push(message.block);
                        this.log('new block added [${message.block.data}]');
                    }
                }
            }
        }
        catch(e : Dynamic) { }
    }

    public function accept() : Void {
        var connectionsEnded = false;
        while(!connectionsEnded) {
            try {
                var newConnection = this._socket.accept();
                this.log('Client connected...');
                newConnection.setBlocking(false);
                this._acceptedConnections.push(newConnection);
            }
            catch(e : Dynamic) { 
                connectionsEnded = true;
            }
        }
    }

    public function tic(wait : Float = 0.1) : Void {
        try {
            this.lookup();
            this.accept();
            this.readAll();
        }
        catch(e : Dynamic) { }

        Sys.sleep(wait);
    }

    function log(message : String): Void {
        if(this.logsEnabled) {
            Sys.println('Node [${this.address.url} : ${this.address.port} ] - $message');
        }
    }

    public static function createBlock(index : Int, previousHash : String, timestamp : Float, data : String, hash : String) {
        return {
            index : index,
            previousHash: previousHash,
            timestamp: timestamp,
            data: data,
            hash: hash
        };
    }

    public static function compareBlocks(first : Block, second : Block) : Bool {
        return first.data == second.data && first.hash == second.hash && first.index == second.index 
            && first.previousHash == second.previousHash && first.timestamp == second.timestamp;
    }
}