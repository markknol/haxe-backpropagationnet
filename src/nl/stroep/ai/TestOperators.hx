package nl.stroep.ai;

import nl.stroep.ai.BackPropagationNet;
import nl.stroep.ai.training.Exercise;

/**
 * @author Mark Knol
 */
class TestOperators 
{
	public var net:BackPropagationNet;
	
	static function main() 
	{
		new TestOperators();
	}
	
	public function new()
	{
		#if ((debug || consolelogviewer) && js)
		var script = js.Browser.document.createScriptElement();
		script.type = "text/javascript";
		script.src = "http://markknol.github.io/console-log-viewer/console-log-viewer.js";
		js.Browser.document.body.appendChild(script);
		#end
		
		var exercise = new Exercise(0, 0.005);
		exercise.addPatterns([0, 0], [0]);
		exercise.addPatterns([0, 1], [0]);
		exercise.addPatterns([1, 0], [0]);
		exercise.addPatterns([1, 1], [1]);
		
		trace("starting exercise. " + outputs);
		
		net = new BackPropagationNet();
		net.create(2, 1, 2, 5);
		
		net.startTraining(exercise);
		
		net.onTrainingComplete = function(result)
		{
			trace("training complete: " + result);
			trace(net.run([1, 1]));
		}
		net.onEpochComplete = function(result)
		{
			trace("epoch complete: " + result);
		}
	}
}
