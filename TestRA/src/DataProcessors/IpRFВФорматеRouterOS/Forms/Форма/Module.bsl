
&НаСервере
Процедура ПолучитьТаблицуНаСервере()
	ОбъектОбработка = РеквизитФормыВЗначение("Объект"); 
	ОбъектОбработка.ВернутьIPАдресаВФорматеRouterOS(); 
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьТаблицу(Команда)
	ПолучитьТаблицуНаСервере();
КонецПроцедуры

&НаСервере
Процедура ВыгрузитьВФорматеRouterOSНаСервере()
	
	Сообщение = TestRAМодули.ВыгрузитьДаныеРегистра_ipRFДляRouterOS(); 
	
КонецПроцедуры

&НаКлиенте
Процедура ВыгрузитьВФорматеRouterOS(Команда)
	ВыгрузитьВФорматеRouterOSНаСервере();
КонецПроцедуры
