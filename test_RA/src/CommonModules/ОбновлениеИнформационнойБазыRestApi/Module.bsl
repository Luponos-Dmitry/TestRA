///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// СтандартныеПодсистемы.ОбновлениеВерсииИБ

////////////////////////////////////////////////////////////////////////////////
// Сведения о библиотеке (или конфигурации).
Процедура ПриДобавленииПодсистем(МодулиПодсистем) Экспорт
	
	МодулиПодсистем.Добавить("УчебнаяКонфигурация_REST_API");
	
КонецПроцедуры

// Заполняет основные сведения о библиотеке или основной конфигурации.
// Библиотека, имя которой имя совпадает с именем конфигурации в метаданных, определяется как основная конфигурация.
// 
// Параметры:
//  Описание - Структура:
//
//   * Имя                 - Строка - имя библиотеки, например, "СтандартныеПодсистемы".
//   * Версия              - Строка - версия в формате из 4-х цифр, например, "2.1.3.1".
//
//   * ИдентификаторИнтернетПоддержки - Строка - уникальное имя программы в сервисах Интернет-поддержки.
//   * ТребуемыеПодсистемы - Массив - имена других библиотек (Строка), от которых зависит данная библиотека.
//                                    Обработчики обновления таких библиотек должны быть вызваны ранее
//                                    обработчиков обновления данной библиотеки.
//                                    При циклических зависимостях или, напротив, отсутствии каких-либо зависимостей,
//                                    порядок вызова обработчиков обновления определяется порядком добавления модулей
//                                    в процедуре ПриДобавленииПодсистем общего модуля
//                                    ПодсистемыКонфигурацииПереопределяемый.
//   * РежимВыполненияОтложенныхОбработчиков - Строка - "Последовательно" - отложенные обработчики обновления выполняются
//                                    последовательно в интервале от номера версии информационной базы до номера
//                                    версии конфигурации включительно или "Параллельно" - отложенный обработчик после
//                                    обработки первой порции данных передает управление следующему обработчику, а после
//                                    выполнения последнего обработчика цикл повторяется заново.
//   * ЗаполнятьДанныеНовыхПодсистемПриПереходеСДругойПрограммы - Булево - если установить Истина, то при переходе с
//                                    другой программы будут автоматически выполнены обработчики начального заполнения
//                                    новых подсистем. При описании обработчика обновления можно при необходимости
//                                    отключить его выполнение, указав свойство НеВыполнятьПриПереходеСДругойПрограммы.
//
Процедура ПриДобавленииПодсистемы(Описание) Экспорт
	
	Описание.Имя    = "УчебнаяКонфигурация_REST_API";
	Описание.Версия = "1.0.0.1";
	Описание.ИдентификаторИнтернетПоддержки = "TRA";
	Описание.РежимВыполненияОтложенныхОбработчиков = "Параллельно";
	Описание.ПараллельноеОтложенноеОбновлениеСВерсии = "1.0.0.1";
	Описание.ЗаполнятьДанныеНовыхПодсистемПриПереходеСДругойПрограммы = Истина;
    Описание.ТребуемыеПодсистемы.Добавить("СтандартныеПодсистемы");
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики обновления информационной базы.

// Добавляет в список процедуры-обработчики обновления данных ИБ
// для всех поддерживаемых версий библиотеки или конфигурации.
// Вызывается перед началом обновления данных ИБ для построения плана обновления.
//
// Параметры:
//  Обработчики - см. ОбновлениеИнформационнойБазы.НоваяТаблицаОбработчиковОбновления
//
// Пример:
//  Для добавления своей процедуры-обработчика в список:
//  Обработчик = Обработчики.Добавить();
//  Обработчик.Версия              = "1.1.0.0";
//  Обработчик.Процедура           = "ОбновлениеИБ.ПерейтиНаВерсию_1_1_0_0";
//  Обработчик.РежимВыполнения     = "Оперативно";
//
Процедура ПриДобавленииОбработчиковОбновления(Обработчики) Экспорт
	
КонецПроцедуры

// См. ОбновлениеИнформационнойБазыПереопределяемый.ПередОбновлениемИнформационнойБазы.
Процедура ПередОбновлениемИнформационнойБазы() Экспорт
	
КонецПроцедуры

// Вызывается после завершения обновления данных ИБ.
// В зависимости от тех или иных условий можно отключить штатное открытие формы
// с описанием изменений в новой версии программы при первом входе в нее (после обновления),
// а также выполнить другие действия.
//
// Не рекомендуется выполнять в данной процедуре какую-либо обработку данных.
// Такие процедуры следует оформлять штатными обработчиками обновления, выполняемыми на каждую версию "*".
// 
// Параметры:
//   ПредыдущаяВерсия     - Строка - версия до обновления. "0.0.0.0" для "пустой" ИБ.
//   ТекущаяВерсия        - Строка - версия после обновления. Как правило, соответствует Метаданные.Версия.
//   ВыполненныеОбработчики - ДеревоЗначений:
//     * НачальноеЗаполнение - Булево - если Истина, то обработчик должен срабатывать при запуске на "пустой" базе.
//     * Версия              - Строка - например, "2.1.3.39". Номер версии конфигурации, при переходе
//                                      на которую должна быть выполнена процедура-обработчик обновления.
//                                      Если указана пустая строка, то это обработчик только для начального заполнения
//                                      (должно быть указано свойство НачальноеЗаполнение).
//     * Процедура           - Строка - полное имя процедуры-обработчика обновления/начального заполнения. 
//                                      Например, "ОбновлениеИнформационнойБазыУПП.ЗаполнитьНовыйРеквизит"
//                                      Обязательно должна быть экспортной.
//     * РежимВыполнения     - Строка - режим выполнения обработчика обновления. Допустимые значения:
//                                      Монопольно, Отложенно, Оперативно. Если значение не заполнено, обработчик
//                                      считается монопольным.
//     * ОбщиеДанные         - Булево - если Истина, то обработчик должен срабатывать до
//                                      выполнения любых обработчиков, использующих разделенные данные.
//                                      Допустимо указывать только для обработчиков с режимом выполнения Монопольно и Оперативно.
//                                      Если указать значение Истина для обработчика с режимом
//                                      выполнения Отложенно, будет выдано исключение.
//     * УправлениеОбработчиками - Булево - если Истина, то обработчик должен иметь параметр типа Структура, в котором
//                                          есть свойство РазделенныеОбработчики - таблица значений со структурой,
//                                          возвращаемой этой функцией.
//                                      При этом колонка Версия игнорируется. В случае необходимости выполнения
//                                      разделенного обработчика в данную таблицу необходимо добавить строку с
//                                      описанием процедуры обработчика.
//                                      Имеет смысл только для обязательных (Версия = *) обработчиков обновления 
//                                      с установленным флагом ОбщиеДанные.
//     * Комментарий         - Строка - описание действий, выполняемых обработчиком обновления.
//     * Идентификатор       - УникальныйИдентификатор - необходимо заполнять для обработчиков отложенного обновления,
//                                                 для остальных заполнение не требуется. Требуется для идентификации
//                                                 обработчика в случае его переименования.
//     
//     * БлокируемыеОбъекты  - Строка - необходимо заполнять для обработчиков отложенного обновления,
//                                      для остальных заполнение не требуется. Полные имена объектов через запятую, 
//                                      которые следует блокировать от изменения до завершения процедуры обработки данных.
//                                      Если заполнено, то также требуется заполнить и свойство ПроцедураПроверки.
//     * ПроцедураПроверки   - Строка - необходимо заполнять для обработчиков отложенного обновления,
//                                      для остальных заполнение не требуется. Имя функции, которая для переданного объекта 
//                                      определяет, завершена ли для него процедура обработки данных. 
//                                      Если переданный объект обработан, то следует вернуть значение Истина. 
//                                      Вызывается из процедуры ОбновлениеИнформационнойБазы.ПроверитьОбъектОбработан.
//                                      Параметры, передаваемые в функцию:
//                                         Параметры - см. ОбновлениеИнформационнойБазы.МетаданныеИОтборПоДанным.
//     * ПроцедураЗаполненияДанныхОбновления - Строка - указывается процедура, которая регистрирует данные,
//                                      подлежащие обновлению данным обработчиком.
//     * ЗапускатьТолькоВГлавномУзле  - Булево - только для обработчиков отложенного обновления с режимом выполнения Параллельно.
//                                      Указать Истина, если обработчик обновления должен выполняться только в главном
//                                      узле РИБ.
//     * ЗапускатьИВПодчиненномУзлеРИБСФильтрами - Булево - только для обработчиков отложенного обновления с режимом
//                                      выполнения Параллельно.
//                                      Указать Истина, если обработчик обновления должен также выполняться в
//                                      подчиненном узле РИБ с фильтрами.
//     * ЧитаемыеОбъекты              - Строка - объекты, которые обработчик обновления будет читать при обработке данных.
//     * ИзменяемыеОбъекты            - Строка - объекты, которые обработчик обновления будет изменять при обработке данных.
//     * ПриоритетыВыполнения         - ТаблицаЗначений - таблица приоритетов выполнения между отложенными обработчиками,
//                                      изменяющими или читающими одни и те же данные. Подробнее см. в комментарии
//                                      к функции ОбновлениеИнформационнойБазы.ПриоритетыВыполненияОбработчика.
//     * ВыполнятьВГруппеОбязательных - Булево - следует указывать, если обработчик требуется
//                                      выполнять в одной группе с обработчиками на версии "*".
//                                      При этом возможно менять порядок выполнения обработчика
//                                      относительно других путем изменения приоритета.
//     * Приоритет           - Число  - для внутреннего использования.
//     * МонопольныйРежим    - Неопределено
//                           - Булево - если указано Неопределено, то обработчик 
//                                      должен безусловно выполняться в монопольном режиме.
//                                      Для обработчиков перехода на конкретную версию (версия <> *):
//                                        Ложь   - обработчик не требует монопольного режима для выполнения.
//                                        Истина - обработчик требует монопольного режима для выполнения.
//                                      Для обязательных обработчиков обновления (Версия = "*"):
//                                        Ложь   - обработчик не требует монопольного режима.
//                                        Истина - обработчик может требовать монопольного режима для выполнения.
//                                                 В такие обработчики передается параметр типа структура
//                                                 со свойством МонопольныйРежим (типа Булево).
//                                                 При запуске обработчика в монопольном режиме передается
//                                                 значение Истина. В этом случае обработчик должен выполнить
//                                                 требуемые действия по обновлению. Изменение параметра
//                                                 в теле обработчика игнорируется.
//                                                 При запуске обработчика в немонопольном режиме передается
//                                                 значение Ложь. В этом случае обработчик не должен вносить никакие
//                                                 изменения в ИБ.
//                                                 Если в результате анализа выясняется, что обработчику требуется
//                                                 изменить данные ИБ, следует установить значение параметра в Истина
//                                                 и прекратить выполнение обработчика.
//                                                 В этом случае оперативное (немонопольное) обновление ИБ будет
//                                                 отменено и будет выдана ошибка с требованием выполнить обновление в
//                                                 монопольном режиме.
//   ВыводитьОписаниеОбновлений - Булево - если установить Ложь, то не будет открыта форма
//                                с описанием изменений в новой версии программы. По умолчанию Истина.
//   МонопольныйРежим           - Булево - признак того, что обновление выполнилось в монопольном режиме.
//
Процедура ПослеОбновленияИнформационнойБазы(Знач ПредыдущаяВерсия, Знач ТекущаяВерсия,
		Знач ВыполненныеОбработчики, ВыводитьОписаниеОбновлений, Знач МонопольныйРежим) Экспорт
		
КонецПроцедуры

// См. ОбновлениеИнформационнойБазыПереопределяемый.ПриПодготовкеМакетаОписанияОбновлений.
Процедура ПриПодготовкеМакетаОписанияОбновлений(Знач Макет) Экспорт
	
КонецПроцедуры

// Позволяет переопределить режим обновления данных информационной базы.
// Для использования в редких (нештатных) случаях перехода, не предусмотренных в
// стандартной процедуре определения режима обновления.
//
// Параметры:
//   РежимОбновленияДанных - Строка - в обработчике можно присвоить одно из значений:
//              "НачальноеЗаполнение"     - если это первый запуск пустой базы (области данных);
//              "ОбновлениеВерсии"        - если выполняется первый запуск после обновление конфигурации базы данных;
//              "ПереходСДругойПрограммы" - если выполняется первый запуск после обновление конфигурации базы данных, 
//                                          в которой изменилось имя основной конфигурации.
//
//   СтандартнаяОбработка  - Булево - если присвоить Ложь, то стандартная процедура
//                                    определения режима обновления не выполняется, 
//                                    а используется значение РежимОбновленияДанных.
//
Процедура ПриОпределенииРежимаОбновленияДанных(РежимОбновленияДанных, СтандартнаяОбработка) Экспорт
	
КонецПроцедуры

// Добавляет в список процедуры-обработчики перехода с другой программы (с другим именем конфигурации).
// Например, для перехода между разными, но родственными конфигурациями: базовая -> проф -> корп.
// Вызывается перед началом обновления данных ИБ.
//
// Параметры:
//  Обработчики - ТаблицаЗначений:
//    * ПредыдущееИмяКонфигурации - Строка - имя конфигурации, с которой выполняется переход;
//                                           или "*", если нужно выполнять при переходе с любой конфигурации.
//    * Процедура                 - Строка - полное имя процедуры-обработчика перехода с программы
//                                           ПредыдущееИмяКонфигурации.
//                                  Например, "ОбновлениеИнформационнойБазыУПП.ЗаполнитьУчетнуюПолитику"
//                                  Обязательно должна быть экспортной.
//
// Пример:
//  Обработчик = Обработчики.Добавить();
//  Обработчик.ПредыдущееИмяКонфигурации  = "УправлениеТорговлей";
//  Обработчик.Процедура                  = "ОбновлениеИнформационнойБазыУПП.ЗаполнитьУчетнуюПолитику";
//
Процедура ПриДобавленииОбработчиковПереходаСДругойПрограммы(Обработчики) Экспорт
	
КонецПроцедуры

// Вызывается после выполнения всех процедур-обработчиков перехода с другой программы (с другим именем конфигурации),
// и до начала выполнения обновления данных ИБ.
//
// Параметры:
//  ПредыдущееИмяКонфигурации    - Строка - имя конфигурации до перехода.
//  ПредыдущаяВерсияКонфигурации - Строка - имя предыдущей конфигурации (до перехода).
//  Параметры                    - Структура:
//    * ВыполнитьОбновлениеСВерсии   - Булево - по умолчанию Истина. Если установить Ложь, 
//        то будут выполнена только обязательные обработчики обновления (с версией "*").
//    * ВерсияКонфигурации           - Строка - номер версии после перехода. 
//        По умолчанию, равен значению версии конфигурации в свойствах метаданных.
//        Для того чтобы выполнить, например, все обработчики обновления с версии ПредыдущаяВерсияКонфигурации, 
//        следует установить значение параметра в ПредыдущаяВерсияКонфигурации.
//        Для того чтобы выполнить вообще все обработчики обновления, установить значение "0.0.0.1".
//    * ОчиститьСведенияОПредыдущейКонфигурации - Булево - по умолчанию Истина. 
//        Для случаев когда предыдущая конфигурация совпадает по имени с подсистемой текущей конфигурации, следует
//        указать Ложь.
//
Процедура ПриЗавершенииПереходаСДругойПрограммы(ПредыдущееИмяКонфигурации, ПредыдущаяВерсияКонфигурации, Параметры) Экспорт
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.ОбновлениеВерсииИБ

#КонецОбласти

#КонецОбласти
