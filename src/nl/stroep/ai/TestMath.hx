package nl.stroep.ai;

import js.Browser;
import nl.stroep.ai.BackPropagationNet;
import nl.stroep.ai.training.Exercise;

/**
 * @author Mark Knol
 */
class TestMath
{
	public var net:BackPropagationNet;
	
	var data:Array<Array<Float>> = [
		[1, 0.5, 0, 0, 0.5], [.1, .5],
		[0.5, 1, 0.5, 0, 0], [.2, .4],
		[0, 0.5, 1, 0.5, 0], [.3, .3],
		[0, 0, 0.5, 1, 0.5], [.4, .2],
		[0.5, 0, 0, 0.5, 1], [.5, .1],
	];
	
	static function main() 
	{
		new TestMath();
	}
	
	public function new()
	{
		#if ((debug || consolelogviewer) && js)
		var script = js.Browser.document.createScriptElement();
		script.type = "text/javascript";
		script.src = "http://markknol.github.io/console-log-viewer/console-log-viewer.js";
		js.Browser.document.body.appendChild(script);
		#end
		
		trace("start exercise");
		
		
		var exercise = new Exercise(0, 0.000005);
		
		var index = 0;
		while (index < data.length)
		{
			var input = data[index + 0];
			var output = data[index + 1];
			exercise.addPatterns(input, output);
			index += 2;
		}
		trace("data: "+ data);
		net = new BackPropagationNet();
		net.create(data[0].length, data[1].length, 2, 5);
		
		net.startTraining(exercise);
		
		net.onTrainingComplete = function(result)
		{
			trace("training complete: "+ result);
			
			var testResult = net.run([0, 1, 1, 1, 0]);
			trace("test result: "+ testResult);
			
			reverseTest(testResult);
		}
	}
	
	function reverseTest(testResult:Array<Float>) 
	{
		trace("\n\nstart reversed");
		var exercise = new Exercise(0, 0.000005);
		var index = 0;
		while (index < data.length)
		{
			var input = data[index + 1];
			var output = data[index + 0];
			exercise.addPatterns(input, output);
			index += 2;
		}
		trace("data: "+ data);
		
		var netReversed = new BackPropagationNet();
		netReversed.create(data[1].length, data[0].length, 2, 5);
		netReversed.run(testResult);
		netReversed.startTraining(exercise);
		netReversed.onTrainingComplete = function(result)
		{
			trace("training reversed complete: "+ result);
			
			var testResultReversed = netReversed.run(testResult);
			trace("reversed test result: "+ testResultReversed);
		}
	}
}