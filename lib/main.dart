import 'package:flutter/foundation.dart';
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
		return Consumer<KontoStand>(
			builder:(context, kontoStand, child){
				return WillPopScope(
					onWillPop: () async{
						kontoStand.notify = true;
						return true;
					},
					child:Scaffold(
						appBar: AppBar(
							title:Text('Einstellungen'),
							backgroundColor: Colors.grey,
						),
						body:Builder(
							builder:(context){
								var titleStyle = TextStyle(
									fontWeight: FontWeight.bold,
									fontSize: 20
								);
								var numInputWidth = 60.0;

								var offDayController = TextEditingController();
								var offMonthController = TextEditingController();
								var offYearController = TextEditingController();
								var startAmountController = TextEditingController();
								var addAmountController = TextEditingController();

								void _saveInput(){
									var newOffset = {
										'years':int.parse('0' + offYearController.text),
										'months':int.parse('0' + offMonthController.text),
										'days':int.parse('0' + offDayController.text),
									};

									if (!mapEquals(newOffset, kontoStand.dateOffset)){
										kontoStand.notify = false;
										kontoStand.dateOffset = newOffset;
									}
								}

								void _saveAmountInput(){
									kontoStand.notify = false;
									kontoStand.startAmount = '0' + startAmountController.text.replaceAll(',', '.');
									kontoStand.addAmount = '0' + addAmountController.text.replaceAll(',', '.');
								}

								var offsetMap = Map.from(kontoStand.dateOffset); //otherwise it couldn't save. This is copy.copy
								offDayController.text = offsetMap['days'].toString();
								offMonthController.text = offsetMap['months'].toString();
								offYearController.text = offsetMap['years'].toString();
								startAmountController.text = kontoStand.startAmount.replaceAll('.', '');
								addAmountController.text = kontoStand.addAmount.replaceAll('.', '');

								offDayController.addListener(_saveInput);
								offMonthController.addListener(_saveInput);
								offYearController.addListener(_saveInput);
								startAmountController.addListener(_saveAmountInput);
								addAmountController.addListener(_saveAmountInput);

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
																kontoStand.notify = true;
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
																child:TextField(
																	decoration: InputDecoration(
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
																child:TextField(
																	decoration: InputDecoration(
																		labelText: 'Monate',
																	),
																	keyboardType: TextInputType.number,
																	inputFormatters: [FilteringTextInputFormatter.digitsOnly],
																	controller: offMonthController,
																),
															),
															Container(
																width: numInputWidth,
																child:TextField(
																	decoration: InputDecoration(
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
														'Startkapital',
														style:titleStyle
													),
													Container(
														width: 60,
														child:TextField(
															decoration: InputDecoration(
																labelText: 'Betrag',
															),
															keyboardType: TextInputType.number,
															inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9,]'))],
															controller: startAmountController,
														),
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
														'Sparbetrag',
														style:titleStyle
													),
													Container(
														width: 60,
														child:TextField(
															decoration: InputDecoration(
																labelText: 'Betrag',
															),
															keyboardType: TextInputType.number,
															inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9,]'))],
															controller: addAmountController,
														),
													)
												],
											),
										),
									],
								);
							}
						)
					)
				);
			}
		);
	}
}
