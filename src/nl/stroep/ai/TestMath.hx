package nl.stroep.ai;

import nl.stroep.ai.BackPropagationNet;
import nl.stroep.ai.training.Exercise;

/**
 * @author Mark Knol
 */
class TestMath 
{
	public var net:BackPropagationNet;
	
	static function main() 
	{
		new TestMath();
	}
	
	public function new()
	{
		/*#if ((debug || consolelogviewer) && js)
		var script = js.Browser.document.createScriptElement();
		script.type = "text/javascript";
		script.src = "http://markknol.github.io/console-log-viewer/console-log-viewer.js";
		js.Browser.document.body.appendChild(script);
		#end*/
		
		function getInts(s:String) return [for (v in s.split("")) Std.parseFloat(v)/10];
		
		
		
		//var exercise = new Exercise(0, 0.0005);
		var exercise = new Exercise(0, 0.018);
		exercise.addPatterns(getInts("1"), getInts("10"));
		exercise.addPatterns(getInts("2"), getInts("20"));
		exercise.addPatterns(getInts("3"), getInts("30"));
		exercise.addPatterns(getInts("4"), getInts("40"));
		exercise.addPatterns(getInts("5"), getInts("40"));
		exercise.addPatterns(getInts("6"), getInts("40"));
		exercise.addPatterns(getInts("7"), getInts("40"));
		exercise.addPatterns(getInts("8"), getInts("40"));

		net = new BackPropagationNet();
		net.create(1, 2, 4, 5);
		//net.run([1, 1]);
		
		net.startTraining(exercise);
		
		net.onTrainingComplete = function(result)
		{
			trace("training complete: " + result);
			var test = net.run(getInts("20"));
			trace(test);
			var result = [for (v in test) Std.int(v * 1000)/100];
			trace(result);
			
		}
		net.onEpochComplete = function(result)
		{
			//trace("epoch complete: " + result);
		}
	}
	
	static function resetNet(net:BackPropagationNet)
	{
		for (layer in net.layers)
		{
			for (neuron in layer.neurons)
			{
				for (synapse in neuron.synapses)
				{
					synapse.resetWeight();
				}
			}
		}
	}
	
	
}