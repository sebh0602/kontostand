import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cron/cron.dart';

class KontoStand extends ChangeNotifier{
	KontoStand(){
		_loadVariables();
		final cron = Cron();
		cron.schedule(Schedule.parse('0 0 * * *'), () {
			notifyListeners();
		});
	}

	int _startAmount = 0;
	String get startAmount => '${_prettyPrint(_startAmount)}';
	set startAmount(String s){
		_startAmount = (double.parse(s)*100).round();
		_saveVariables();
	}
	
	int _addAmount = 0;
	String get addAmount => '${_prettyPrint(_addAmount)}';
	set addAmount(String s){
		_addAmount = (double.parse(s)*100).round();
		_saveVariables();
	}
	
	String get currentAmount {
		return '${_prettyPrint(_startAmount + occurences*_addAmount)}';
	}

	bool _notify = true;
	set notify(bool n){
		_notify = n;
		if (n){
			notifyListeners();
		}
	}

	DateTime _startDate = DateTime.now();
	DateTime get startDate => _startDate;
	set startDate(date){
		_startDate = _utcShift(date);
		_saveVariables();
	}

	String _dateOffset = '0-0-0';
	Map get dateOffset => {
		'years':int.parse(_dateOffset.split('-')[0]),
		'months':int.parse(_dateOffset.split('-')[1]),
		'days':int.parse(_dateOffset.split('-')[2]),
	};
	set dateOffset(offsetMap){
		_dateOffset = '${offsetMap['years']}-${offsetMap['months']}-${offsetMap['days']}';
		_saveVariables();
	}

	int get occurences {
		var oc = 0;
		var laterDate = _incrementDate(_startDate);
		if (_dateOffset != '0-0-0'){
			while (laterDate.isBefore(_utcShift(DateTime.now()))){
				oc += 1;
				laterDate = _incrementDate(laterDate);
			}
		}

		return oc;
	}

	DateTime _incrementDate(DateTime oldDate){
		var newDate = oldDate.add(Duration(days:dateOffset['days']));
		if (dateOffset['months'] + dateOffset['years'] > 0){
			var dateArr = newDate.toString().split('-');
			var years = int.parse(dateArr[0]);
			years += dateOffset['years'];
			var months = int.parse(dateArr[1]);
			months += dateOffset['months'];
			years += (months - 1) ~/ 12;
			months = ((months - 1) % 12) + 1;
			dateArr[0] = _padLeadingZeros(years.toString(), 4);
			dateArr[1] = _padLeadingZeros(months.toString(), 2);
			newDate = DateTime.parse(dateArr.join('-'));
		}
		return newDate;
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

	String _padLeadingZeros(String number, int len){
		var arr = number.split('');
		while (arr.length < len){
			arr.insert(0,"0");
		}
		return arr.join('');
	}

	void _loadVariables() async{
		final prefs = await SharedPreferences.getInstance();
		_startAmount = prefs.getInt('startAmount') ?? 0;
		_addAmount = prefs.getInt('addAmount') ?? 0;
		_startDate = _utcShift(
			DateTime.parse(
				prefs.getString('startDate') ?? DateTime.now().toString().split(' ')[0]
			)
		);
		_dateOffset = prefs.getString('dateOffset') ?? '0-1-0';

		notifyListeners();
	}

	void _saveVariables() async{
		final prefs = await SharedPreferences.getInstance();
		prefs.setInt('startAmount',_startAmount);
		prefs.setInt('addAmount',_addAmount);
		prefs.setString('startDate',_startDate.toString().split(' ')[0]);
		prefs.setString('dateOffset',_dateOffset);

		if (_notify){
			notifyListeners();
		}
		
	}

	DateTime _utcShift(DateTime localTime){ //this returns a utc datetime with the same h:m:s as your local time
		return localTime.add(localTime.timeZoneOffset).toUtc();
	}
}
