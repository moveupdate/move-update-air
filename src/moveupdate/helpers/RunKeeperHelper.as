//AS3///////////////////////////////////////////////////////////////////////////
// 
// Copyright (c) 2015 Move Update
// Please read this carefully before using the source code.
// 
////////////////////////////////////////////////////////////////////////////////

package moveupdate.helpers
{

import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.LocationChangeEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.media.StageWebView;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;

import moveupdate.data.DataManager;

/**
 * RunKeeperHelper
 * 
 * @langversion ActionScript 3.0
 * 
 * @author Robert Grabowski <robert.grabowski@happyendians.pl>
 */
public final class RunKeeperHelper
{
	private static const API : String		= "https://api.runkeeper.com/";
	private static const AUTH_URL : String	= "https://runkeeper.com/apps/authorize/";
	private static const TOKEN_URL : String	= "https://runkeeper.com/apps/token/";
	
	/*
	 * The page on your site where the Health Graph API should redirect the user after accepting or denying the access request
	 */
	private static const REDIRECT_URL : String	= "REDIRECT_URL";
	
	/**
	 * The unique identifier that your application received upon registration
	 */
	private static const CLIENT_ID : String		= "CLIENT_ID";
	
	/**
	 * The secret that your application received upon registration
	 */
	private static const SECRET_ID : String		= "SECRET_ID";
	
	private var _stage : Stage;
	private var _webView : StageWebView;
	private var _backButton : Sprite;
	
	public function RunKeeperHelper( stage : Stage, success : Function, error : Function, showButton : Boolean = true )
	{
		_stage = stage;
		init( stage, success, error, showButton );
	}
	
	private function init( stage : Stage, success : Function, error : Function, showButton : Boolean = true ) : void
	{
		if( !_backButton && showButton )
		{
			_backButton = new Sprite();
			_backButton.addEventListener( MouseEvent.CLICK, onBackButton );
			var icon : Sprite = new webview_back();
			icon.height = 40;
			icon.scaleX = icon.scaleY;
			_backButton.addChild( icon );
			_backButton.graphics.beginFill( 0xffe700 );
			_backButton.graphics.drawRect( 0, 0, stage.fullScreenWidth, _backButton.height );
			_backButton.graphics.endFill();
			_backButton.y = stage.fullScreenHeight - _backButton.height;
			stage.addChild( _backButton );
		}
		
		if( !DataManager.getInstance().isRunKeeperConnected() )
		{
			_webView = new StageWebView();
			_webView.viewPort = new Rectangle( 0, 0, stage.fullScreenWidth, stage.fullScreenHeight-_backButton.height );
			_webView.stage = stage;
			_webView.addEventListener( LocationChangeEvent.LOCATION_CHANGING, function( e : LocationChangeEvent ) : void {
				if( e.location.indexOf( REDIRECT_URL + "?error=access_denied" ) == 0 )
				{
					dispose();
				}
				else if( e.location.indexOf( REDIRECT_URL + "?code=" ) == 0 )
				{
					var code : String = e.location.replace( REDIRECT_URL + "?code=", "" );
					if( code.length > 0 ) getToken( code, success, error );
					dispose();
				}
			})
			_webView.loadURL( AUTH_URL + "?client_id=" + CLIENT_ID + "&response_type=code&redirect_uri=" + REDIRECT_URL );
		}
		else
		{
			geActivitiesHistory( DataManager.getInstance().runkeeper.token, success, error );
		}
	}
	
	private function getToken( code : String, success : Function, error : Function ) : void
	{
		var urlLoader : URLLoader = new URLLoader();
		urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
		urlLoader.addEventListener( Event.COMPLETE, function( e : Event ) : void
		{
			var json : Object = JSON.parse( urlLoader.data );
			var token : String = json[ "access_token" ];
			if( token )
			{
				DataManager.getInstance().runkeeper.token = token;
				DataManager.getInstance().saveRunKeeper();
				geActivitiesHistory( token, success, error );
			}
		});
		urlLoader.addEventListener( IOErrorEvent.IO_ERROR, function( e : IOErrorEvent ) : void
		{
			error();
		});
		var request : URLRequest = new URLRequest(
			TOKEN_URL
			+ "?grant_type=authorization_code"
			+ "&code=" + code
			+ "&client_id=" + CLIENT_ID
			+ "&client_secret=" + SECRET_ID
			+ "&redirect_uri=" + REDIRECT_URL
		);
		request.method = URLRequestMethod.POST;
		urlLoader.load( request );
	}
	
	private function geActivitiesHistory( token : String, success : Function, error : Function ) : void
	{
		var urlLoader : URLLoader = new URLLoader();
		urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
		urlLoader.addEventListener( Event.COMPLETE, function( e : Event ) : void
		{
			try
			{
				var json : Object = JSON.parse( urlLoader.data );
				var l : int = int( json[ "size" ] );
				var list : Array = json[ "items" ];
				var calories : int = 0;
				for each( var activity : Object in list )
					calories += int( activity[ "total_calories" ] );
				var newCalories : int = 0;
				if( DataManager.getInstance().runkeeper.calories > 0 )
				{
					newCalories = calories - DataManager.getInstance().runkeeper.calories;
				}
				DataManager.getInstance().runkeeper.calories = calories;
				DataManager.getInstance().saveRunKeeper();
				DataManager.getInstance().powersUp += int( newCalories / 100 );
				success( newCalories );
			}
			catch( e : * )
			{
				init( _stage, success, error );
			}
		});
		urlLoader.addEventListener( IOErrorEvent.IO_ERROR, function( e : IOErrorEvent ) : void
		{
			error();
		});
		var request : URLRequest = new URLRequest( API + "fitnessActivities/?access_token=" + token + "&pageSize=100000" );
		request.method = URLRequestMethod.GET;
		urlLoader.load( request );
	}
	
	private function onBackButton( e : MouseEvent ) : void
	{
		dispose();
	}
	
	public function dispose() : void
	{
		if( _webView )
		{
			_webView.stop();
			_webView.stage = null;
			_webView = null;
		}
		if( _backButton )
		{
			_backButton.removeEventListener( MouseEvent.CLICK, onBackButton );
			_backButton.parent.removeChild( _backButton );
			_backButton = null;
		}
		_stage = null;
	}
}
}
