# Move Update for AIR #

## Overview ##

The Move Update for AIR is a library that allows to improve the gaming results by activities in real life.

## Installation ##

1. Register your application with [RunKeeper Partner Portal](http://runkeeper.com/partner) to get the credentials.

2. Add a [SWC file](https://github.com/moveupdate/AIR/blob/master/libs/assets.swc) to the library path.

3. Update an instance of the [RunKeeperHelper](https://github.com/moveupdate/AIR/blob/master/src/moveupdate/helpers/RunKeeperHelper.as) class with the API credentials you obtained when you registered your app and redirect the user to the authorization URL so that they can log in and approve your request.
```
private static const REDIRECT_URL : String = "REDIRECT_URL";
	
private static const CLIENT_ID : String = "CLIENT_ID";
	
private static const SECRET_ID : String = "SECRET_ID";
````

## Usage and demos ##
Checking is RunKeeper connected:
```
DataManager.getInstance().isRunKeeperConnected()  // boolean
````

Checking how many powers up are available:
```
DataManager.getInstance().powersUp // int
```

Open login popup:
```
var runkeeper : RunKeeperHelper = new RunKeeperHelper(
	stage,
	function( newCalories : int ) : void
	{
		// success
	},
	function() : void
	{
		// error
	}
);
```

To track activity in the background:
```
if( DataManager.getInstance().isRunKeeperConnected() )
{
	new RunKeeperHelper(
		stage,
		function( calories : uint ) : void
		{
			// success
		},
		function() : void
		{
			// error
		},
		false
	);
}
```

## Changelog

To see what has changed in recent versions of Move Update, see the [CHANGELOG](https://github.com/moveupdate/AIR/blob/master/CHANGELOG.md).