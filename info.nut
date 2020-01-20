class DelugeAI extends AIInfo {
	function GetAuthor()      { return "crazystacy"; }
	function GetName()        { return "delugeai"; }
	function GetDescription() { return "flood the map"; }
	function GetVersion()     { return 1; }
	function GetDate()        { return "2020-01-18"; }
	function CreateInstance() { return "DelugeAI"; }
	function GetShortName()	  { return "WATR"; }
	function GetAPIVersion()  { return "1.0"; }
	
	function GetSettings() {
	}
}

RegisterAI(DelugeAI());
