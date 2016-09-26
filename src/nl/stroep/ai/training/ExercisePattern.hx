package nl.stroep.ai.training;

/**
 * From: https://code.google.com/p/imotionproductions/source/browse/trunk/nl/imotion/neuralnetwork/training/Exercise.as
 * @author Mark Knol
 */
class ExercisePattern
{
	public var inputPattern:Array<Float>;
	public var targetPattern:Array<Float>;

	public inline function new(inputPattern:Array<Float>, targetPattern:Array<Float>) 
	{
		this.inputPattern = inputPattern;
		this.targetPattern = targetPattern;
	}
	
#if debug
	public function toString() return 'inputPattern=$inputPattern targetPattern=$targetPattern';
#end
}