import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KontoStand extends ChangeNotifier{
	KontoStand(){
		_loadVariables();
	}

	int _startAmount;
	String get startAmount => '${_prettyPrint(_startAmount)}';
	set startAmount(String s){
		_startAmount = (double.parse(s)*100).round();
	}
	
	int _addAmount;
	String get addAmount => '${_prettyPrint(_addAmount)}';
	set addAmount(String s){
		_addAmount = (double.parse(s)*100).round();
	}
	
	String get currentAmount => '${_prettyPrint(140397)}';

	int get occurences => 7;

	bool _notify = true;
	set notify(bool n){
		_notify = n;
		if (n){
			notifyListeners();
		}
	}

	DateTime _startDate;
	DateTime get startDate => _startDate;
	set startDate(date){
		_startDate = date;
		_saveVariables();
	}

	String _dateOffset;
	Map get dateOffset => {
		'years':int.parse(_dateOffset.split('-')[0]),
		'months':int.parse(_dateOffset.split('-')[1]),
		'days':int.parse(_dateOffset.split('-')[2]),
	};
	set dateOffset(offsetMap){
		_dateOffset = '${offsetMap['years']}-${offsetMap['months']}-${offsetMap['days']}';
		_saveVariables();
	}

	String _prettyPrint(int cents){
		String _addSeparators(String number){
			var arr = number.toString().split("");
			for (var i = arr.length - 3; i >= 1; i -= 3){
				arr[i] = "." + arr[i];
			}
			return arr.join("");
		}

		if (cents == null || cents.isNaN){
			return '?';
		}
		var negative = (cents < 0) ? true:false;
		if (negative) cents *= -1;

		var arr = cents.toString().split('');
		while (arr.length < 3){
			arr.insert(0,"0");
		}
		arr.insert(arr.length - 2, ',');
		var withComma = arr.join('');
		var splitByComma = withComma.split(',');
		splitByComma[0] = _addSeparators(splitByComma[0]);
		return (negative ? "-" : "") + splitByComma.join(",");
	}

	void _loadVariables() async{
		final prefs = await SharedPreferences.getInstance();
		_startAmount = prefs.getInt('startAmount') ?? 0;
		_addAmount = prefs.getInt('addAmount') ?? 0;
		_startDate = DateTime.parse(prefs.getString('startDate') ?? DateTime.now().toString());
		_dateOffset = prefs.getString('dateOffset') ?? '0-1-0';

		notifyListeners();
	}

	void _saveVariables() async{
		final prefs = await SharedPreferences.getInstance();
		prefs.setInt('startAmount',_startAmount);
		prefs.setInt('addAmount',_addAmount);
		prefs.setString('startDate',_startDate.toString());
		prefs.setString('dateOffset',_dateOffset);

		if (_notify){
			notifyListeners();
		}
		
	}
}
