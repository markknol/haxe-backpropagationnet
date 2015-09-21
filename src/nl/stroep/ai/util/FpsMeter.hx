package nl.stroep.ai.util;
import haxe.Timer;

/**
 * @author Mark Knol
 */
class FpsMeter
{
	public var onMeasureComplete(null, default):Int->Void;
	
	public var fps(default, null):Int;
	public var timePerFrame(get, null):Int;
	public var numMeasurements(default, null):Int;
	public var autoStop(default, set):Bool;
	public var isStarted(default, null):Bool;
	
	private var _timeList:Array<Float> = [];
	private var _fpsList:Array<Float> = [];
	private var _lastTime:Float = 0;
	private var _timer:Timer;
	
	public function new(numMeasurements:Int) 
	{
		this.numMeasurements = numMeasurements;
	}
	
	public function startMeasure(autoStop:Bool = true)
	{
		this.autoStop = autoStop;
		
		if (!isStarted)
		{
			isStarted = true;
			
			_lastTime = Timer.stamp();	
			
			if (_timer == null)
			{
				_timer = new Timer(1);
			}
			_timer.run = calcFPS;
		}
	}
	
	public function stopMeasure()
	{
		if (isStarted)
		{
			isStarted = false;
			
			_timeList = [];
			_fpsList  = [];
			_lastTime = 0;
			
			_timer.stop();
		}
	}
	
	private function calcFPS()
	{
		var newTime = Timer.stamp();	
		
		_timeList.push(newTime - _lastTime);
		
		var diff = _timeList.length - numMeasurements;
		if (diff > 0)
		{
			_timeList.splice(0, diff);
		}
		
		var totalTime = 0.0;
		for (time in _timeList) 
		{
			totalTime += time;
		}
		
		fps = Math.round(1000 / (totalTime / _timeList.length));
		_lastTime = newTime;
		
		if (autoStop)
		{
			checkStableFPS();
		}
	}
	
	
	private function checkStableFPS()
	{
		_fpsList.push(fps);
		
		var fpsDiff = _fpsList.length - numMeasurements;
		if (fpsDiff > 0)
		{
			_fpsList.splice(0, fpsDiff);
		}
		
		if (_fpsList.length == numMeasurements)
		{
			var fpsCheck = _fpsList[0];
			var fpsIsStable = true;
			
			for (fpsValue in _fpsList) 
			{
				if (fpsValue != fpsCheck)
				{
					fpsIsStable = false;
					break;
				}
			}
			if (fpsIsStable)
			{
				stopMeasure();

				if (onMeasureComplete != null) onMeasureComplete(fps);
			}
		}
	}
	
	inline private function set_autoStop(value:Bool):Bool
	{
		if (autoStop != value)
		{
			autoStop = value;
			_fpsList = [];
		}
		return value;
	}
	
	inline private function get_timePerFrame():Int
	{
		if (fps != 0) return Std.int(1000 / fps);
		
		return 0;
	}
}