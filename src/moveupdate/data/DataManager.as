//AS3///////////////////////////////////////////////////////////////////////////
// 
// Copyright (c) 2015 Move Update
// Please read this carefully before using the source code.
// 
////////////////////////////////////////////////////////////////////////////////

package moveupdate.data
{

import flash.net.SharedObject;

/**
 * DataManager
 * 
 * @langversion ActionScript 3.0
 * 
 * @author Robert Grabowski <robert.grabowski@happyendians.pl>
 */
public final class DataManager
{
	private static const SO : String = "moveupdateSO";
	private static var sInstance : DataManager;
	
	/**
	 * Singleton instance of DataManager
	 */
	public static function getInstance() : DataManager
	{
		if( sInstance == null )
		{
			sInstance = new DataManager();
			sInstance.fetchRunKeeper();
			sInstance.fetchPowersUp();
		}
		return sInstance;
	}
	
	/**
	 * RunKeeer
	 */
	public const runkeeper : RunKeeper = new RunKeeper();
	
	/**
	 * PowersUp
	 */
	private var _powersUp:int = 0;
	
	public function fetchRunKeeper() : RunKeeper
	{
		var sharedObject : SharedObject = SharedObject.getLocal( SO );
		runkeeper.token = sharedObject.data[ "runkeeper_token" ];
		runkeeper.calories = sharedObject.data[ "runkeeper_calories" ] ? sharedObject.data[ "runkeeper_calories" ] : -1;
		sharedObject.close();
		return runkeeper;
	}
	
	public function saveRunKeeper() : void
	{
		var sharedObject : SharedObject = SharedObject.getLocal( SO );
		sharedObject.data[ "runkeeper_token" ] = runkeeper.token;
		sharedObject.data[ "runkeeper_calories" ] = runkeeper.calories;
		sharedObject.flush();
		sharedObject.close();
	}
	
	public function removeRunKeeper() : void
	{
		var sharedObject : SharedObject = SharedObject.getLocal( SO );
		sharedObject.data[ "runkeeper_token" ]    = runkeeper.token = null;
		sharedObject.data[ "runkeeper_calories" ] = null;
		runkeeper.calories = -1;
		sharedObject.flush();
		sharedObject.close();
		powersUp = 0;
	}
	
	public function isRunKeeperConnected() : Boolean
	{
		return runkeeper.token != null;
	}
	
	public function get powersUp() : int
	{
		return _powersUp;
	}
	
	public function set powersUp( value : int ) : void
	{
		_powersUp = value;
		var sharedObject:SharedObject = SharedObject.getLocal( SO );
		sharedObject.data["powersUp"] = value;
		sharedObject.flush();
		sharedObject.close();
	}

	public function fetchPowersUp() : void
	{
		var sharedObject : SharedObject = SharedObject.getLocal( SO );
		_powersUp = int( sharedObject.data[ "powersUp" ] );
		sharedObject.close();
	}
}
}
