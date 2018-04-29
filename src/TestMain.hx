import tests.ItWorksTestCase;
import tests.SyncTestCase;
import haxe.unit.TestRunner;

class TestMain
{
	public static function main()
	{
		var logsEnabled = true;
        for (arg in Sys.args()) {
			if(arg == '--no-log') {
				logsEnabled = false;
			}
		}

		var runner = new TestRunner();

		runner.add(new ItWorksTestCase(logsEnabled));
		runner.add(new SyncTestCase(logsEnabled));

		runner.run();
	}
}