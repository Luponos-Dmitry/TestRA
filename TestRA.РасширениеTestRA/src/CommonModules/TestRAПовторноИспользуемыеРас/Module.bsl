//Функция ПолучитьДанныеНаСервере(ПараметрыСоеднинения) Экспорт
//	
//КонецФуя  

Функция СобратьHTTPСоединение(СсылкаСоединение) Экспорт

	Возврат Новый HTTPСоединение(СсылкаСоединение.Сервер, СсылкаСоединение.Порт, СсылкаСоединение.Логин, 
								СсылкаСоединение.Пароль, ,СсылкаСоединение.Таймаут, Новый ЗащищенноеСоединениеOpenSSL());
	
КонецФункции 

Функция СобратьHTTPЗапрос(СсылкаСоединение) Экспорт
	
	Возврат Новый HTTPЗапрос(СсылкаСоединение.АдресAPI+СсылкаСоединение.Суффикс);
		
КонецФункции



	

//Новый HTTPСоединение(
//Новый HTTPЗапрос(СсылкаСоединение.АдресAPI+СсылкаСоединение.Суффикс)