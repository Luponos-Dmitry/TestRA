
Процедура ОбработкаПроведения(Отказ, Режим)
	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!

	// регистр ОстаткиТоваров Приход
	//Движения.ОстаткиТоваров.Записывать = Истина;
	//Для Каждого ТекСтрокаПереченьТоваров Из ПереченьТоваров Цикл
	//	Движение = Движения.ОстаткиТоваров.Добавить();
	//	Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
	//	Движение.Период = Дата;
	//	Движение.Товар = ТекСтрокаПереченьТоваров.Товар;
	//	Движение.Организация = Организация;
	//	Движение.Остаток = ТекСтрокаПереченьТоваров.Количество;
	//КонецЦикла; 
	//
	ПроведениеДокументовСервер.ПровестиДокумент(Отказ, Ссылка);
	
	// регистр ОборотыТоваров 
	Движения.ОборотыТоваров.Записывать = Истина;
	Для Каждого ТекСтрокаПереченьТоваров Из ПереченьТоваров Цикл
		Движение = Движения.ОборотыТоваров.Добавить();
		Движение.Период = Дата;
		Движение.Товар = ТекСтрокаПереченьТоваров.Товар;
		Движение.Организация = Организация;
		Движение.Количество = ТекСтрокаПереченьТоваров.Количество;
	КонецЦикла;
	
	TestRa_РаботаСФайлами.ПровестиДокументы(Ссылка);

		
	
КонецПроцедуры
 
  
