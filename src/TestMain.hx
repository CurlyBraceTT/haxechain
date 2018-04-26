import tests.ItWorksTestCase;
import haxe.unit.TestRunner;

class TestMain
{
	public static function main()
	{
		var runner = new TestRunner();

		runner.add(new ItWorksTestCase());

		runner.run();
	}
}