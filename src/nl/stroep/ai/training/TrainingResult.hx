package nl.stroep.ai.training;

/**
 * From: https://code.google.com/p/imotionproductions/source/browse/trunk/nl/imotion/neuralnetwork/training/TrainingResult.as
 * 
 * @author Mark Knol
 */
class TrainingResult
{
	public var startError:Float;
	public var endError:Float;
	public var epochs:Int;
	public var trainingTime:Float;

	public inline function new(startError:Float, endError:Float, epochs:Int = 0, trainingTime:Float = 0) 
	{
		this.startError = startError;
		this.endError = endError;
		this.epochs = epochs;
		this.trainingTime = trainingTime;
	}
	
#if debug
	public function toString() return 'startError=$startError endError=$endError epochs=$epochs trainingTime=${Std.int(trainingTime * 1000)/1000}';
#end
}