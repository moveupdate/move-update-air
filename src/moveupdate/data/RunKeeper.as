//AS3///////////////////////////////////////////////////////////////////////////
// 
// Copyright (c) 2015 Move Update
// Please read this carefully before using the source code.
// 
////////////////////////////////////////////////////////////////////////////////

package moveupdate.data
{

/**
 * RunKeeper
 * 
 * @langversion ActionScript 3.0
 * 
 * @author Robert Grabowski <robert.grabowski@happyendians.pl>
 */
public final class RunKeeper
{
	public var token : String = null;
	public var calories : int = 0;
	
	public function toString() : String
	{
		return "[RunKeeper(token=" + token + ", calories=" + calories + ")]";
	}
}
}
