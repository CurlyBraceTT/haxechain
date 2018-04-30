# haxechain - naivechain haxe port

Haxe port of the https://github.com/lhartikk/naivechain

### Installation
```
haxelib install haxechain
```

### Quick start
Navigate to the installation directory (You can get it by `haxelib path haxechain` command). Than run `run [url] [port]` command, that will compile and launch node, for example `run localhost 5000`.

Node commands:
* `mine [something]` - for example `mine First Mined!`
* `connect [url] [port]` - for example `connect localhost 5001`
* `exit`

### Example in code usage
```
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
```
