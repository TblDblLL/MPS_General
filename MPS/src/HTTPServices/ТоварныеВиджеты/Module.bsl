Функция ПолучитьФайл(Запрос) Экспорт
    КодВиджета = Запрос.ПараметрыURL.Получить("code");
    ИмяФайла = Запрос.ПараметрыURL.Получить("file");
    Если СтрНайти("|widget.html|widget.css|widget.js|preview.html|embed.js|", "|" + ИмяФайла + "|") = 0 Тогда
        Возврат ОтветТекст(404, "Не найдено", "text/plain");
    КонецЕсли;
    Ссылка = Справочники.Виджеты.НайтиПоКоду(КодВиджета, Истина);
    Если Ссылка.Пустая() Тогда
        Возврат ОтветТекст(404, "Не найдено", "text/plain");
    КонецЕсли;
    Виджет = Ссылка.ПолучитьОбъект();
    Если Не Виджет.Опубликован Или Виджет.ПометкаУдаления Тогда
        Возврат ОтветТекст(404, "Не найдено", "text/plain");
    КонецЕсли;
    Попытка
        Комплект = Справочники.Виджеты.Сформировать(Виджет);
    Исключение
        ЗаписьЖурналаРегистрации("ТоварныеВиджеты", УровеньЖурналаРегистрации.Ошибка,,, ОписаниеОшибки());
        Возврат ОтветТекст(500, "Ошибка формирования виджета", "text/plain");
    КонецПопытки;
    Если ИмяФайла = "widget.css" Тогда
        Возврат ОтветТекст(200, Комплект.CSS, "text/css");
    ИначеЕсли ИмяФайла = "widget.js" Тогда
        Возврат ОтветТекст(200, Комплект.JS, "application/javascript");
    ИначеЕсли ИмяФайла = "widget.html" Тогда
        Возврат ОтветТекст(200, Комплект.HTML, "text/html");
    ИначеЕсли ИмяФайла = "preview.html" Тогда
        Возврат ОтветТекст(200, Комплект.Просмотр, "text/html");
    КонецЕсли;
    // Данные кодируются как JSON, а не вставляются в JavaScript вручную.
    Скрипт = "(function(){var script=document.currentScript;if(!script)return;var style=document.createElement('style');style.textContent="
        + СтрокаJSON(Комплект.CSS) + ";document.head.appendChild(style);var host=document.createElement('div');host.innerHTML="
        + СтрокаJSON(Комплект.HTML) + ";script.parentNode.insertBefore(host,script);if(window.ProductWidgets){window.ProductWidgets.init(host);}else{var runtime=document.createElement('script');runtime.src=new URL('widget.js',script.src).href;document.head.appendChild(runtime);}})();";
    Возврат ОтветТекст(200, Скрипт, "application/javascript");
КонецФункции

Функция СтрокаJSON(Текст)
    Запись = Новый ЗаписьJSON;
    Запись.УстановитьСтроку();
    ЗаписатьJSON(Запись, Текст);
    Возврат Запись.Закрыть();
КонецФункции

Функция ОтветТекст(Код, Тело, ТипСодержимого)
    Ответ = Новый HTTPСервисОтвет(Код);
    Ответ.Заголовки.Вставить("Content-Type", ТипСодержимого + "; charset=utf-8");
    Ответ.Заголовки.Вставить("X-Content-Type-Options", "nosniff");
    Ответ.Заголовки.Вставить("Cache-Control", ?(Код = 200, "public, max-age=60", "no-store"));
    Ответ.УстановитьТелоИзСтроки(Тело, КодировкаТекста.UTF8, ИспользованиеByteOrderMark.НеИспользовать);
    Возврат Ответ;
КонецФункции
