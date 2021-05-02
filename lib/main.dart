import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:kontostand/backEnd.dart';

void main() {
	runApp(MyApp());
}

class MyApp extends StatelessWidget {
	// This widget is the root of your application.
	@override
	Widget build(BuildContext context) {
		return ChangeNotifierProvider(
			create: (context) => KontoStand(),
			child: MaterialApp(
				title: 'Kontostand',
				theme: ThemeData(
					primarySwatch: Colors.blue,
				),
				home: Scaffold(
					appBar: AppBar(
						title: Text('Kontostand'),
						actions: [
							Builder(builder: (context){ //otherwise navigator wouldn't work
								return IconButton(
									onPressed: (){
										Navigator.push(
											context,
											MaterialPageRoute<void>(
												fullscreenDialog: true,
												builder: (context) => SettingsScreen()
											)
										);
									}, 
									icon: Icon(Icons.settings)
								);
							})

						],
					),
					body: Center(
						child:Column(
							mainAxisAlignment: MainAxisAlignment.center,
							crossAxisAlignment: CrossAxisAlignment.center,
							children: [
								Consumer<KontoStand>(
									builder: (context, kontoStand, child){
										return Text(
											'${kontoStand.startAmount} + ${kontoStand.occurences} × ${kontoStand.addAmount} =',
											style: TextStyle(
												fontSize: 20
											),
										);
									},
								),
								Consumer<KontoStand>(
									builder: (context, kontoStand, child){
										return Text(
											kontoStand.currentAmount,
											style: TextStyle(
												fontSize: 40
											),
										);
									},
								)
							],
						)
					),
				),
			)
		);
	}
}

class SettingsScreen extends StatefulWidget{
	@override
	_SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>{
	@override
	Widget build(BuildContext context){
		return Scaffold(
			appBar: AppBar(
				title:Text('Einstellungen'),
				backgroundColor: Colors.grey,
			),
			body:Consumer<KontoStand>(
				builder:(context,kontoStand,child){
					var titleStyle = TextStyle(
						fontWeight: FontWeight.bold,
						fontSize: 20
					);
					var numInputWidth = 60.0;

					var offDayController = TextEditingController();
					var offMonthController = TextEditingController();
					var offYearController = TextEditingController();
					var startAmountController = TextEditingController();

					void _saveInput(){
						kontoStand.dateOffset = {
							'years':int.parse('0' + offYearController.text),
							'months':int.parse('0' + offMonthController.text),
							'days':int.parse('0' + offDayController.text),
						};
					}
					var offsetMap = Map.from(kontoStand.dateOffset); //otherwise it couldn't save. This is copy.copy
					offDayController.text = offsetMap['days'].toString();
					offMonthController.text = offsetMap['months'].toString();
					offYearController.text = offsetMap['years'].toString();
					startAmountController.text = kontoStand.startAmount.replaceAll('.', '');

					offDayController.addListener(_saveInput);
					offMonthController.addListener(_saveInput);
					offYearController.addListener(_saveInput);

					return ListView(
						children: [
							Padding(
								padding: EdgeInsets.all(20),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											'Startdatum',
											style:titleStyle
										),
										TextButton(
											onPressed: () async{
												final DateTime picked = await showDatePicker(
													context: context,
													initialDate: kontoStand.startDate,
													firstDate: DateTime(2000),
													lastDate: DateTime(2100));
												if (picked != null){
													kontoStand.startDate = picked;
												}
													
											},
											child:Text('${kontoStand.startDate.toString().split(' ')[0]}')
										)
									],
								),
							),
							Padding(
								padding: EdgeInsets.all(20),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											'Datumsdifferenz',
											style:titleStyle	
										),
										Row(
											children: [
												Container(
													margin: EdgeInsets.only(right: 10),
													width: numInputWidth,
													child:TextField(												decoration: InputDecoration(
															labelText: 'Jahre',
														),
														keyboardType: TextInputType.number,
														inputFormatters: [FilteringTextInputFormatter.digitsOnly],
														controller: offYearController,
													),
												),
												Container(
													margin: EdgeInsets.only(right: 10),
													width: numInputWidth,
													child:TextField(												decoration: InputDecoration(
															labelText: 'Monate',
														),
														keyboardType: TextInputType.number,
														inputFormatters: [FilteringTextInputFormatter.digitsOnly],
														controller: offMonthController,
													),
												),
												Container(
													width: numInputWidth,
													child:TextField(												decoration: InputDecoration(
															labelText: 'Tage',
														),
														keyboardType: TextInputType.number,
														inputFormatters: [FilteringTextInputFormatter.digitsOnly],
														controller: offDayController,
													),
												)
											],
										)
									],
								),
							),
							Padding(
								padding: EdgeInsets.all(20),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											'Anfangsbetrag',
											style:titleStyle
										),
										Container(
											width: 80,
											child:TextField(												decoration: InputDecoration(
													labelText: 'Betrag',
												),
												keyboardType: TextInputType.number,
												inputFormatters: [FilteringTextInputFormatter.digitsOnly],
												controller: startAmountController,
											),
										)
									],
								),
							),
						],
					);
				}
			)

		);
	}
}
