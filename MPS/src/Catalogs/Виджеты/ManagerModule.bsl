#Область Формирование

// Принимает объект справочника, в том числе полученный из данных формы.
Функция Сформировать(Виджет) Экспорт
    ПроверитьНастройки(Виджет);
    КорневойИД = "pw-" + Строка(Новый УникальныйИдентификатор);
    Группы = Новый Соответствие;
    Количество = 0;
    Карточки = "";
    Для Каждого Товар Из Виджет.Товары Цикл
        Если Не Товар.Показывать Тогда
            Продолжить;
        КонецЕсли;
        ПроверитьТовар(Товар);
        ГруппаТовара = ?(ПустаяСтрока(Товар.Группа), "Без группы", Товар.Группа);
        Счетчик = Группы.Получить(ГруппаТовара);
        Группы.Вставить(ГруппаТовара, ?(Счетчик = Неопределено, 1, Счетчик + 1));
        Количество = Количество + 1;
        Карточки = Карточки + КарточкаТовара(Виджет, Товар, ГруппаТовара);
    КонецЦикла;
    Стиль = ПеременныеОформления(Виджет);
    HTML = "<section class=""pw"" id=""" + КорневойИД + """ data-widget-key=""" + Экранировать(Виджет.Код)
        + """ data-cart-after=""" + Экранировать(Виджет.ТекстПослеДобавления) + """ style=""" + Экранировать(Стиль) + """ aria-label=""Товары"">";
    Если Не ПустаяСтрока(Виджет.Заголовок) Тогда
        HTML = HTML + "<h2 class=""pw-heading"">" + Экранировать(Виджет.Заголовок) + "</h2>";
    КонецЕсли;
    Если Виджет.ПоказыватьГруппы И Группы.Количество() > 0 Тогда
        HTML = HTML + "<div class=""pw-tabs"" role=""group"" aria-label=""Группы товаров"">"
            + КнопкаГруппы("Все товары", Количество, Виджет.ПоказыватьСчетчики, Истина);
        Для Каждого ПараГруппы Из Группы Цикл
            HTML = HTML + КнопкаГруппы(ПараГруппы.Ключ, ПараГруппы.Значение, Виджет.ПоказыватьСчетчики);
        КонецЦикла;
        HTML = HTML + "</div>";
    КонецЕсли;
    Если Количество = 0 Тогда
        HTML = HTML + "<div class=""pw-empty"">Нет товаров для отображения</div>";
    КонецЕсли;
    HTML = HTML + "<div class=""pw-slider"">";
    Если Виджет.ПоказыватьСтрелки Тогда
        HTML = HTML + "<button type=""button"" class=""pw-arrow"" data-direction=""prev"" aria-label=""Предыдущие товары"">&#8249;</button>";
    КонецЕсли;
    HTML = HTML + "<div class=""pw-track"" tabindex=""0"" aria-label=""Список товаров"">" + Карточки + "</div>";
    Если Виджет.ПоказыватьСтрелки Тогда
        HTML = HTML + "<button type=""button"" class=""pw-arrow"" data-direction=""next"" aria-label=""Следующие товары"">&#8250;</button>";
    КонецЕсли;
    HTML = HTML + "</div><p class=""pw-status"" role=""status"" aria-live=""polite""></p></section>";
    CSS = СтилиВиджета();
    JS = СкриптВиджета();
    Просмотр = "<!doctype html><html lang=""ru""><head><meta charset=""utf-8""><meta name=""viewport"" content=""width=device-width,initial-scale=1""><title>"
        + Экранировать(Виджет.Заголовок) + "</title><style>body{margin:0;padding:16px;background:#f3f5f7}" + CSS
        + "</style></head><body>" + HTML + "<script>" + JS + "</script></body></html>";
    Возврат Новый Структура("HTML,CSS,JS,Просмотр", HTML, CSS, JS, Просмотр);
КонецФункции

Функция КарточкаТовара(Виджет, Товар, ГруппаТовара)
    Идентификатор = Товар.ИдентификаторСайта;
    Если ПустаяСтрока(Идентификатор) И ЗначениеЗаполнено(Товар.Номенклатура) Тогда
        Идентификатор = Строка(Товар.Номенклатура.УникальныйИдентификатор());
    КонецЕсли;
    Если ПустаяСтрока(Идентификатор) Тогда
        Идентификатор = "row-" + ЧислоCSS(Товар.НомерСтроки);
    КонецЕсли;
    Ссылка = БезопасныйURL(Товар.СсылкаНаСайт);
    Картинка = БезопасныйURL(Товар.URLИзображения);
    HTML = "<article class=""pw-card"" data-product-id=""" + Экранировать(Идентификатор)
        + """ data-name=""" + Экранировать(Товар.Название) + """ data-price=""" + ЧислоCSS(Товар.Цена)
        + """ data-url=""" + Экранировать(Ссылка) + """ data-group=""" + Экранировать(ГруппаТовара) + """>";
    HTML = HTML + "<div class=""pw-labels"">";
    Если Виджет.ПоказыватьСкидку И Товар.СтараяЦена > Товар.Цена Тогда
        Скидка = Окр((Товар.СтараяЦена - Товар.Цена) / Товар.СтараяЦена * 100, 0);
        HTML = HTML + "<span class=""pw-label"">−" + ЧислоCSS(Скидка) + "%</span>";
    КонецЕсли;
    Если Виджет.ПоказыватьНовинку И Товар.Новинка Тогда
        HTML = HTML + "<span class=""pw-label pw-label-new"">" + Экранировать(Виджет.ТекстНовинки) + "</span>";
    КонецЕсли;
    HTML = HTML + "</div>";
    Если Виджет.ПоказыватьИзбранное Тогда
        HTML = HTML + "<button type=""button"" class=""pw-favorite"" data-action=""favorite"" aria-label=""Добавить в избранное"" aria-pressed=""false"" title=""Действие пока не подключено к сайту"" disabled>♡</button>";
    КонецЕсли;
    НачалоСсылки = ?(ПустаяСтрока(Ссылка), "<div", "<a href=""" + Экранировать(Ссылка) + """");
    КонецСсылки = ?(ПустаяСтрока(Ссылка), "</div>", "</a>");
    HTML = HTML + НачалоСсылки + " class=""pw-picture"">";
    Если Не ПустаяСтрока(Картинка) Тогда
        HTML = HTML + "<img src=""" + Экранировать(Картинка) + """ alt=""" + Экранировать(Товар.Название) + """ loading=""lazy"">";
    Иначе
        HTML = HTML + "<span class=""pw-no-image"">Нет изображения</span>";
    КонецЕсли;
    HTML = HTML + КонецСсылки + "<div class=""pw-body"">";
    Если Виджет.ПоказыватьНазвание Тогда
        HTML = HTML + НачалоСсылки + " class=""pw-name"">" + Экранировать(Товар.Название) + КонецСсылки;
    КонецЕсли;
    Если Виджет.ПоказыватьПроизводителя И Не ПустаяСтрока(Товар.Производитель) Тогда
        HTML = HTML + "<div class=""pw-vendor"">" + Экранировать(Товар.Производитель) + "</div>";
    КонецЕсли;
    Если Виджет.ПоказыватьРейтинг И Товар.Рейтинг > 0 Тогда
        HTML = HTML + "<div class=""pw-rating"" role=""img"" aria-label=""Рейтинг " + ЧислоCSS(Товар.Рейтинг) + " из 5"" style=""--pw-rating:" + ЧислоCSS(Товар.Рейтинг * 20)
            + "%"" title=""" + ЧислоCSS(Товар.Рейтинг) + " из 5""><span aria-hidden=""true"">★★★★★</span><span class=""pw-rating-fill"" aria-hidden=""true"">★★★★★</span></div>";
    КонецЕсли;
    Если Виджет.ПоказыватьЦены Тогда
        HTML = HTML + "<div class=""pw-prices"">";
        Если Виджет.ПоказыватьСтаруюЦену И Товар.СтараяЦена > Товар.Цена Тогда
            HTML = HTML + "<del class=""pw-old-price"">" + ЦенаТекст(Товар.СтараяЦена, Виджет.Валюта) + "</del>";
        КонецЕсли;
        HTML = HTML + "<span class=""pw-price"">" + ЦенаТекст(Товар.Цена, Виджет.Валюта) + "</span></div>";
    КонецЕсли;
    Если Виджет.ПоказыватьКорзину Тогда
        HTML = HTML + "<button type=""button"" class=""pw-cart"" data-action=""cart"" title=""Действие пока не подключено к сайту"" disabled>" + Экранировать(Виджет.ТекстКорзины) + "</button>";
    КонецЕсли;
    Возврат HTML + "</div></article>";
КонецФункции

Функция КнопкаГруппы(Название, Количество, ПоказыватьСчетчик, ВсеТовары = Ложь)
    HTML = "<button type=""button"" class=""pw-tab"" data-group=""" + Экранировать(Название)
        + """ data-all=""" + ?(ВсеТовары, "true", "false") + """ aria-pressed=""" + ?(ВсеТовары, "true", "false") + """>" + Экранировать(Название);
    Если ПоказыватьСчетчик Тогда
        HTML = HTML + "<span class=""pw-count"">" + ЧислоCSS(Количество) + "</span>";
    КонецЕсли;
    Возврат HTML + "</button>";
КонецФункции

Функция Экранировать(Значение) Экспорт
    Текст = Строка(Значение);
    Текст = СтрЗаменить(Текст, "&", "&amp;");
    Текст = СтрЗаменить(Текст, "<", "&lt;");
    Текст = СтрЗаменить(Текст, ">", "&gt;");
    Текст = СтрЗаменить(Текст, """", "&quot;");
    Возврат СтрЗаменить(Текст, "'", "&#39;");
КонецФункции

Функция БезопасныйURL(Значение) Экспорт
    Адрес = СокрЛП(Значение);
    Если ПустаяСтрока(Адрес) Тогда
        Возврат "";
    КонецЕсли;
    Нижний = НРег(Адрес);
    Если Не (Лев(Нижний, 8) = "https://" Или Лев(Нижний, 7) = "http://"
        Или (Лев(Адрес, 1) = "/" И Лев(Адрес, 2) <> "//") Или Лев(Адрес, 2) = "./" Или Лев(Адрес, 3) = "../") Тогда
        ВызватьИсключение "Допустимы HTTP(S) и относительные ссылки /, ./, ../: " + Адрес;
    КонецЕсли;
    Для Позиция = 1 По СтрДлина(Адрес) Цикл
        Если КодСимвола(Адрес, Позиция) <= 32 Или Сред(Адрес, Позиция, 1) = "\" Тогда
            ВызватьИсключение "Недопустимый символ в URL: " + Адрес;
        КонецЕсли;
    КонецЦикла;
    Возврат Адрес;
КонецФункции

Функция ЧислоCSS(Значение)
    Возврат Формат(Значение, "ЧГ=0;ЧРД=.;ЧН=0");
КонецФункции

Функция ЦенаТекст(Цена, Валюта)
    Возврат Экранировать(Формат(Цена, "ЧДЦ=2;ЧРД=,;ЧРГ= ;ЧГ=3,0;ЧН=0,00") + " " + Валюта);
КонецФункции

Процедура ПроверитьТовар(Товар)
    Если ПустаяСтрока(Товар.Название) Тогда
        ВызватьИсключение "Заполните название товара, строка " + Строка(Товар.НомерСтроки);
    КонецЕсли;
    Если Товар.Цена < 0 Или Товар.СтараяЦена < 0 Или Товар.Рейтинг < 0 Или Товар.Рейтинг > 5 Тогда
        ВызватьИсключение "Цена должна быть неотрицательной, рейтинг — от 0 до 5. Строка " + Строка(Товар.НомерСтроки);
    КонецЕсли;
КонецПроцедуры


Процедура НачальныеНастройки(Виджет) Экспорт
    Виджет.Опубликован = Ложь;
    Виджет.Заголовок = "Рекомендуем посмотреть";
    Виджет.Валюта = "₽";
    Виджет.ПоказыватьГруппы = Истина;
    Виджет.ПоказыватьСчетчики = Истина;
    Виджет.ПоказыватьСтрелки = Истина;
    Виджет.КолонокКомпьютер = 4;
    Виджет.КолонокПланшет = 3;
    Виджет.КолонокТелефон = 2;
    Виджет.Расстояние = 16;
    Виджет.ОтступВиджета = 16;
    Виджет.ОтступКарточки = 12;
    Виджет.Скругление = 10;
    Виджет.ВысотаИзображения = 200;
    Виджет.ВысотаИзображенияТелефон = 140;
    Виджет.ГарнитураШрифта = "Arial, sans-serif";
    Виджет.РазмерШрифта = 16;
    Виджет.РазмерШрифтаТелефон = 14;
    Виджет.РазмерЗаголовка = 28;
    Виджет.СтрокНазвания = 2;
    Виджет.Выравнивание = "left";
    Виджет.ЦветФона = "#ffffff";
    Виджет.ЦветКарточки = "#ffffff";
    Виджет.ЦветТекста = "#202832";
    Виджет.ЦветВторостепенный = "#727b87";
    Виджет.ЦветГраницы = "#e1e5ea";
    Виджет.ЦветАкцента = "#215ce5";
    Виджет.ЦветТекстаКнопки = "#ffffff";
    Виджет.ЦветНовинки = "#168364";
    Виджет.ПоказыватьНазвание = Истина;
    Виджет.ПоказыватьПроизводителя = Истина;
    Виджет.ПоказыватьРейтинг = Истина;
    Виджет.ПоказыватьЦены = Истина;
    Виджет.ПоказыватьСтаруюЦену = Истина;
    Виджет.ПоказыватьСкидку = Истина;
    Виджет.ПоказыватьНовинку = Истина;
    Виджет.ТекстНовинки = "Новинка";
    Виджет.ПоказыватьКорзину = Истина;
    Виджет.ПоказыватьИзбранное = Истина;
    Виджет.ТекстКорзины = "В корзину";
    Виджет.ТекстПослеДобавления = "Добавлено";
КонецПроцедуры

Процедура ПроверитьНастройки(Виджет) Экспорт
    Если Виджет.КолонокКомпьютер < 1 Или Виджет.КолонокКомпьютер > 8 Тогда
        ВызватьИсключение "Карточек на компьютере: допустимо от 1 до 8";
    КонецЕсли;
    Если Виджет.КолонокПланшет < 1 Или Виджет.КолонокПланшет > 6 Тогда
        ВызватьИсключение "Карточек на планшете: допустимо от 1 до 6";
    КонецЕсли;
    Если Виджет.КолонокТелефон < 1 Или Виджет.КолонокТелефон > 3 Тогда
        ВызватьИсключение "Карточек на телефоне: допустимо от 1 до 3";
    КонецЕсли;
    Если Виджет.Расстояние < 0 Или Виджет.Расстояние > 64 Тогда
        ВызватьИсключение "Расстояние между карточками, px: допустимо от 0 до 64";
    КонецЕсли;
    Если Виджет.ОтступВиджета < 0 Или Виджет.ОтступВиджета > 100 Тогда
        ВызватьИсключение "Отступ виджета, px: допустимо от 0 до 100";
    КонецЕсли;
    Если Виджет.ОтступКарточки < 0 Или Виджет.ОтступКарточки > 50 Тогда
        ВызватьИсключение "Отступ карточки, px: допустимо от 0 до 50";
    КонецЕсли;
    Если Виджет.Скругление < 0 Или Виджет.Скругление > 50 Тогда
        ВызватьИсключение "Скругление, px: допустимо от 0 до 50";
    КонецЕсли;
    Если Виджет.ВысотаИзображения < 40 Или Виджет.ВысотаИзображения > 600 Тогда
        ВызватьИсключение "Высота изображения, px: допустимо от 40 до 600";
    КонецЕсли;
    Если Виджет.ВысотаИзображенияТелефон < 40 Или Виджет.ВысотаИзображенияТелефон > 400 Тогда
        ВызватьИсключение "Высота изображения на телефоне, px: допустимо от 40 до 400";
    КонецЕсли;
    Если Виджет.РазмерШрифта < 10 Или Виджет.РазмерШрифта > 32 Тогда
        ВызватьИсключение "Размер шрифта, px: допустимо от 10 до 32";
    КонецЕсли;
    Если Виджет.РазмерШрифтаТелефон < 10 Или Виджет.РазмерШрифтаТелефон > 26 Тогда
        ВызватьИсключение "Размер шрифта на телефоне, px: допустимо от 10 до 26";
    КонецЕсли;
    Если Виджет.РазмерЗаголовка < 14 Или Виджет.РазмерЗаголовка > 64 Тогда
        ВызватьИсключение "Размер заголовка, px: допустимо от 14 до 64";
    КонецЕсли;
    Если Виджет.СтрокНазвания < 1 Или Виджет.СтрокНазвания > 6 Тогда
        ВызватьИсключение "Строк в названии: допустимо от 1 до 6";
    КонецЕсли;
    ПроверитьЦвет(Виджет.ЦветФона);
    ПроверитьЦвет(Виджет.ЦветКарточки);
    ПроверитьЦвет(Виджет.ЦветТекста);
    ПроверитьЦвет(Виджет.ЦветВторостепенный);
    ПроверитьЦвет(Виджет.ЦветГраницы);
    ПроверитьЦвет(Виджет.ЦветАкцента);
    ПроверитьЦвет(Виджет.ЦветТекстаКнопки);
    ПроверитьЦвет(Виджет.ЦветНовинки);
    Если Виджет.Выравнивание <> "left" И Виджет.Выравнивание <> "center" И Виджет.Выравнивание <> "right" Тогда
        ВызватьИсключение "Выравнивание: left, center или right";
    КонецЕсли;
КонецПроцедуры

Процедура ПроверитьЦвет(Цвет)
    Если СтрДлина(Цвет) <> 7 Или Лев(Цвет, 1) <> "#" Тогда
        ВызватьИсключение "Укажите цвет в формате #RRGGBB: " + Цвет;
    КонецЕсли;
    Для Позиция = 2 По 7 Цикл
        Если СтрНайти("0123456789abcdef", НРег(Сред(Цвет, Позиция, 1))) = 0 Тогда
            ВызватьИсключение "Недопустимый цвет: " + Цвет;
        КонецЕсли;
    КонецЦикла;
КонецПроцедуры

Функция ПеременныеОформления(Виджет)
    ПроверитьГарнитуруШрифта(Виджет.ГарнитураШрифта);
    Стиль = "--pw-font-family:" + Виджет.ГарнитураШрифта + ";";
    Стиль = Стиль + "--pw-columns:" + ЧислоCSS(Виджет.КолонокКомпьютер) + ";";
    Стиль = Стиль + "--pw-tablet-columns:" + ЧислоCSS(Виджет.КолонокПланшет) + ";";
    Стиль = Стиль + "--pw-mobile-columns:" + ЧислоCSS(Виджет.КолонокТелефон) + ";";
    Стиль = Стиль + "--pw-gap:" + ЧислоCSS(Виджет.Расстояние) + "px;";
    Стиль = Стиль + "--pw-padding:" + ЧислоCSS(Виджет.ОтступВиджета) + "px;";
    Стиль = Стиль + "--pw-card-padding:" + ЧислоCSS(Виджет.ОтступКарточки) + "px;";
    Стиль = Стиль + "--pw-radius:" + ЧислоCSS(Виджет.Скругление) + "px;";
    Стиль = Стиль + "--pw-image-height:" + ЧислоCSS(Виджет.ВысотаИзображения) + "px;";
    Стиль = Стиль + "--pw-mobile-image-height:" + ЧислоCSS(Виджет.ВысотаИзображенияТелефон) + "px;";
    Стиль = Стиль + "--pw-font-size:" + ЧислоCSS(Виджет.РазмерШрифта) + "px;";
    Стиль = Стиль + "--pw-mobile-font-size:" + ЧислоCSS(Виджет.РазмерШрифтаТелефон) + "px;";
    Стиль = Стиль + "--pw-heading-size:" + ЧислоCSS(Виджет.РазмерЗаголовка) + "px;";
    Стиль = Стиль + "--pw-name-lines:" + ЧислоCSS(Виджет.СтрокНазвания) + ";";
    Стиль = Стиль + "--pw-bg:" + Виджет.ЦветФона + ";";
    Стиль = Стиль + "--pw-card-bg:" + Виджет.ЦветКарточки + ";";
    Стиль = Стиль + "--pw-text:" + Виджет.ЦветТекста + ";";
    Стиль = Стиль + "--pw-muted:" + Виджет.ЦветВторостепенный + ";";
    Стиль = Стиль + "--pw-border:" + Виджет.ЦветГраницы + ";";
    Стиль = Стиль + "--pw-accent:" + Виджет.ЦветАкцента + ";";
    Стиль = Стиль + "--pw-button-text:" + Виджет.ЦветТекстаКнопки + ";";
    Стиль = Стиль + "--pw-new-color:" + Виджет.ЦветНовинки + ";";
    Стиль = Стиль + "--pw-align:" + Виджет.Выравнивание + ";";
    Стиль = Стиль + "--pw-price-align:" + ?(Виджет.Выравнивание = "left", "flex-start", ?(Виджет.Выравнивание = "right", "flex-end", "center")) + ";";
    Возврат Стиль;
КонецФункции


#КонецОбласти


Функция СтилиВиджета() Экспорт
    Возврат ".pw, .pw * { box-sizing: border-box; }" + Символы.ПС +
        ".pw { color: var(--pw-text); background: var(--pw-bg); padding: var(--pw-padding); font: var(--pw-font-size)/1.45 var(--pw-font-family); min-width: 0; }" + Символы.ПС +
        ".pw [hidden] { display: none !important; }" + Символы.ПС +
        ".pw a { color: inherit; text-decoration: none; }" + Символы.ПС +
        ".pw button { font: inherit; cursor: pointer; }" + Символы.ПС +
        ".pw button:disabled { cursor: default; opacity: .45; }" + Символы.ПС +
        ".pw button:focus-visible, .pw a:focus-visible, .pw-track:focus-visible { outline: 2px solid var(--pw-accent); outline-offset: 3px; }" + Символы.ПС +
        ".pw-heading { font-size: var(--pw-heading-size); margin: 0 0 20px; line-height: 1.2; text-align: var(--pw-align); }" + Символы.ПС +
        ".pw-tabs { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 16px; }" + Символы.ПС +
        ".pw-tab { border: 1px solid var(--pw-border); border-radius: var(--pw-radius); padding: 8px 14px; color: var(--pw-text); background: var(--pw-card-bg); }" + Символы.ПС +
        ".pw-tab[aria-pressed=""true""] { color: var(--pw-button-text); border-color: var(--pw-accent); background: var(--pw-accent); }" + Символы.ПС +
        ".pw-count { margin-left: .6em; opacity: .75; }" + Символы.ПС +
        ".pw-slider { display: flex; align-items: center; gap: 8px; min-width: 0; }" + Символы.ПС +
        ".pw-track { display: flex; flex: 1; gap: var(--pw-gap); overflow-x: auto; scroll-snap-type: x mandatory; overscroll-behavior-x: contain; padding: 4px 1px 12px; min-width: 0; scrollbar-width: thin; }" + Символы.ПС +
        ".pw-arrow { border: 1px solid var(--pw-border); background: var(--pw-card-bg); color: var(--pw-text); border-radius: 50%; width: 36px; height: 36px; flex: 0 0 36px; font-size: 24px !important; }" + Символы.ПС +
        ".pw-card { position: relative; flex: 0 0 calc((100% - (var(--pw-columns) - 1) * var(--pw-gap)) / var(--pw-columns)); min-width: 0; scroll-snap-align: start; display: flex; flex-direction: column; background: var(--pw-card-bg); border: 1px solid var(--pw-border); border-radius: var(--pw-radius); padding: var(--pw-card-padding); overflow: hidden; }" + Символы.ПС +
        ".pw-picture { display: flex; align-items: center; justify-content: center; height: var(--pw-image-height); margin-bottom: 12px; background: var(--pw-card-bg); }" + Символы.ПС +
        ".pw-picture img { display: block; width: 100%; height: 100%; object-fit: contain; }" + Символы.ПС +
        ".pw-no-image { color: var(--pw-muted); font-size: 12px; }" + Символы.ПС +
        ".pw-labels { position: absolute; top: 12px; left: 12px; display: flex; gap: 4px; padding-right: 34px; flex-wrap: wrap; }" + Символы.ПС +
        ".pw-label { font-size: 12px; padding: 3px 7px; border-radius: 5px; background: var(--pw-accent); color: var(--pw-button-text); }" + Символы.ПС +
        ".pw-label-new { background: var(--pw-new-color); color: #fff; }" + Символы.ПС +
        ".pw-favorite { position: absolute; right: 10px; top: 8px; width: 32px; height: 32px; border: 0; background: var(--pw-card-bg); color: var(--pw-accent); font-size: 26px !important; border-radius: 50%; line-height: 1; }" + Символы.ПС +
        ".pw-body { display: flex; flex-direction: column; gap: 8px; flex: 1; min-width: 0; text-align: var(--pw-align); }" + Символы.ПС +
        ".pw-name { display: -webkit-box; -webkit-line-clamp: var(--pw-name-lines); -webkit-box-orient: vertical; overflow: hidden; overflow-wrap: anywhere; min-height: calc(var(--pw-name-lines) * 1.45em); font-weight: 600; }" + Символы.ПС +
        ".pw-vendor { color: var(--pw-muted); font-size: .85em; overflow-wrap: anywhere; }" + Символы.ПС +
        ".pw-rating { align-self: flex-start; position: relative; color: #d5d9df; font: 20px/1 Arial,sans-serif; white-space: nowrap; }" + Символы.ПС +
        ".pw-rating-fill { position: absolute; inset: 0 auto 0 0; width: var(--pw-rating); overflow: hidden; color: #e6a100; }" + Символы.ПС +
        ".pw-prices { display: flex; align-items: baseline; flex-wrap: wrap; justify-content: var(--pw-price-align); gap: 8px; margin-top: auto; padding-top: 6px; }" + Символы.ПС +
        ".pw-price { font-size: 1.2em; font-weight: 700; white-space: nowrap; }" + Символы.ПС +
        ".pw-old-price { color: var(--pw-muted); font-size: .85em; white-space: nowrap; }" + Символы.ПС +
        ".pw-cart { background: var(--pw-accent); color: var(--pw-button-text); padding: 10px 12px; min-height: 42px; border: 0; border-radius: var(--pw-radius); margin-top: 4px; }" + Символы.ПС +
        ".pw-status { min-height: 1.5em; margin: 8px 0 0; font-size: 13px; }" + Символы.ПС +
        ".pw-empty { padding: 24px; color: var(--pw-muted); }" + Символы.ПС +
        "@media (max-width: 900px) { .pw-card { flex-basis: calc((100% - (var(--pw-tablet-columns) - 1) * var(--pw-gap)) / var(--pw-tablet-columns)); } }" + Символы.ПС +
        "@media (max-width: 600px) {" + Символы.ПС +
        "  .pw { font-size: var(--pw-mobile-font-size); padding: 8px; }" + Символы.ПС +
        "  .pw-heading { font-size: calc(var(--pw-heading-size) * .8); }" + Символы.ПС +
        "  .pw-card { flex-basis: calc((100% - (var(--pw-mobile-columns) - 1) * var(--pw-gap)) / var(--pw-mobile-columns)); padding: 8px; }" + Символы.ПС +
        "  .pw-picture { height: var(--pw-mobile-image-height); }" + Символы.ПС +
        "  .pw-arrow { display: none; }" + Символы.ПС +
        "}" + Символы.ПС +
        "@media (hover: hover) { .pw-cart:not(:disabled):hover, .pw-tab:hover { filter: brightness(.94); } }" + Символы.ПС +
        "";
КонецФункции

Функция СкриптВиджета() Экспорт
    Возврат "(function () {" + Символы.ПС +
        "  'use strict';" + Символы.ПС +
        "  if (window.ProductWidgets) { window.ProductWidgets.init(document); return; }" + Символы.ПС +
        "  var states = new WeakMap(), sequence = 0;" + Символы.ПС +
        "  function init(scope) {" + Символы.ПС +
        "    var roots = Array.from(scope.querySelectorAll('.pw[data-widget-key]'));" + Символы.ПС +
        "    if (scope.matches && scope.matches('.pw[data-widget-key]')) roots.unshift(scope);" + Символы.ПС +
        "    roots.forEach(function (root) {" + Символы.ПС +
        "      if (states.has(root)) return;" + Символы.ПС +
        "      var state = { adapters: {}, revision: 0 }; states.set(root, state);" + Символы.ПС +
        "      var track = root.querySelector('.pw-track'), tabs = Array.from(root.querySelectorAll('.pw-tab'));" + Символы.ПС +
        "      var cards = Array.from(root.querySelectorAll('.pw-card'));" + Символы.ПС +
        "      track.id = 'pw-track-' + (++sequence);" + Символы.ПС +
        "      root.querySelectorAll('.pw-arrow').forEach(function (button) {" + Символы.ПС +
        "        button.setAttribute('aria-controls', track.id);" + Символы.ПС +
        "        button.addEventListener('click', function () {" + Символы.ПС +
        "          track.scrollBy({ left: (button.dataset.direction === 'next' ? 1 : -1) * track.clientWidth," + Символы.ПС +
        "            behavior: matchMedia('(prefers-reduced-motion: reduce)').matches ? 'auto' : 'smooth' });" + Символы.ПС +
        "        });" + Символы.ПС +
        "      });" + Символы.ПС +
        "      var previous = root.querySelector('[data-direction=""prev""]'), next = root.querySelector('[data-direction=""next""]');" + Символы.ПС +
        "      function navigation() {" + Символы.ПС +
        "        if (previous) previous.disabled = track.scrollLeft <= 1;" + Символы.ПС +
        "        if (next) next.disabled = track.scrollLeft + track.clientWidth >= track.scrollWidth - 2;" + Символы.ПС +
        "      }" + Символы.ПС +
        "      track.addEventListener('scroll', navigation, { passive: true });" + Символы.ПС +
        "      if (window.ResizeObserver) new ResizeObserver(navigation).observe(track);" + Символы.ПС +
        "      else window.addEventListener('resize', navigation);" + Символы.ПС +
        "      tabs.forEach(function (tab) {" + Символы.ПС +
        "        tab.setAttribute('aria-controls', track.id);" + Символы.ПС +
        "        tab.addEventListener('click', function () {" + Символы.ПС +
        "          tabs.forEach(function (item) { item.setAttribute('aria-pressed', String(item === tab)); });" + Символы.ПС +
        "          cards.forEach(function (card) { card.hidden = tab.dataset.all !== 'true' && card.dataset.group !== tab.dataset.group; });" + Символы.ПС +
        "          track.scrollLeft = 0; navigation();" + Символы.ПС +
        "        });" + Символы.ПС +
        "      });" + Символы.ПС +
        "      root.addEventListener('click', async function (event) {" + Символы.ПС +
        "        var button = event.target.closest('button[data-action]');" + Символы.ПС +
        "        if (!button || !root.contains(button) || button.disabled) return;" + Символы.ПС +
        "        var card = button.closest('.pw-card'), action = button.dataset.action;" + Символы.ПС +
        "        var handler = action === 'cart' ? state.adapters.addToCart : state.adapters.setFavorite;" + Символы.ПС +
        "        if (typeof handler !== 'function') return;" + Символы.ПС +
        "        var product = productOf(card), desired = button.getAttribute('aria-pressed') !== 'true';" + Символы.ПС +
        "        button.disabled = true; button.setAttribute('aria-busy', 'true');" + Символы.ПС +
        "        var status = root.querySelector('.pw-status'); status.textContent = '';" + Символы.ПС +
        "        try {" + Символы.ПС +
        "          var result = await handler(product, desired);" + Символы.ПС +
        "          if (result === false) throw new Error('Действие отклонено сайтом');" + Символы.ПС +
        "          if (action === 'cart') {" + Символы.ПС +
        "            button.textContent = root.dataset.cartAfter;" + Символы.ПС +
        "            status.textContent = 'Товар добавлен в корзину';" + Символы.ПС +
        "          } else {" + Символы.ПС +
        "            button.setAttribute('aria-pressed', String(desired));" + Символы.ПС +
        "            button.textContent = desired ? '♥' : '♡';" + Символы.ПС +
        "            button.setAttribute('aria-label', desired ? 'Убрать из избранного' : 'Добавить в избранное');" + Символы.ПС +
        "            status.textContent = desired ? 'Товар добавлен в избранное' : 'Товар удалён из избранного';" + Символы.ПС +
        "          }" + Символы.ПС +
        "        } catch (error) {" + Символы.ПС +
        "          status.textContent = 'Не удалось выполнить действие. Попробуйте ещё раз.';" + Символы.ПС +
        "          root.dispatchEvent(new CustomEvent('productwidget:error', { bubbles: true, detail: { action: action, product: product, error: error } }));" + Символы.ПС +
        "        } finally {" + Символы.ПС +
        "          button.disabled = typeof (action === 'cart' ? state.adapters.addToCart : state.adapters.setFavorite) !== 'function';" + Символы.ПС +
        "          button.removeAttribute('aria-busy');" + Символы.ПС +
        "        }" + Символы.ПС +
        "      });" + Символы.ПС +
        "      navigation();" + Символы.ПС +
        "      root.dispatchEvent(new CustomEvent('productwidget:ready', { bubbles: true }));" + Символы.ПС +
        "    });" + Символы.ПС +
        "  }" + Символы.ПС +
        "  function productOf(card) {" + Символы.ПС +
        "    return { id: card.dataset.productId, name: card.dataset.name, url: card.dataset.url," + Символы.ПС +
        "      price: Number(card.dataset.price), group: card.dataset.group };" + Символы.ПС +
        "  }" + Символы.ПС +
        "  async function configure(target, adapters) {" + Символы.ПС +
        "    var root = typeof target === 'string' ? document.querySelector(target) : target;" + Символы.ПС +
        "    if (!root) throw new Error('Виджет не найден');" + Символы.ПС +
        "    init(root);" + Символы.ПС +
        "    var state = states.get(root); state.adapters = adapters || {};" + Символы.ПС +
        "    var revision = ++state.revision;" + Символы.ПС +
        "    var jobs = Array.from(root.querySelectorAll('[data-action]')).map(async function (button) {" + Символы.ПС +
        "      var action = button.dataset.action;" + Символы.ПС +
        "      var enabled = typeof (action === 'cart' ? state.adapters.addToCart : state.adapters.setFavorite) === 'function';" + Символы.ПС +
        "      button.disabled = !enabled; button.title = enabled ? '' : 'Действие пока не подключено к сайту';" + Символы.ПС +
        "      if (action === 'favorite' && typeof state.adapters.isFavorite === 'function') {" + Символы.ПС +
        "        try {" + Символы.ПС +
        "          button.disabled = true;" + Символы.ПС +
        "          var selected = Boolean(await state.adapters.isFavorite(productOf(button.closest('.pw-card'))));" + Символы.ПС +
        "          if (revision !== state.revision) return;" + Символы.ПС +
        "          button.setAttribute('aria-pressed', String(selected)); button.textContent = selected ? '♥' : '♡';" + Символы.ПС +
        "          button.setAttribute('aria-label', selected ? 'Убрать из избранного' : 'Добавить в избранное');" + Символы.ПС +
        "        } catch (error) {" + Символы.ПС +
        "          enabled = false;" + Символы.ПС +
        "          root.querySelector('.pw-status').textContent = 'Не удалось получить состояние избранного';" + Символы.ПС +
        "          root.dispatchEvent(new CustomEvent('productwidget:error', { bubbles: true, detail: { action: 'isFavorite', error: error } }));" + Символы.ПС +
        "        } finally { if (revision === state.revision) button.disabled = !enabled; }" + Символы.ПС +
        "      }" + Символы.ПС +
        "    });" + Символы.ПС +
        "    await Promise.all(jobs);" + Символы.ПС +
        "  }" + Символы.ПС +
        "  window.ProductWidgets = { init: init, configure: configure };" + Символы.ПС +
        "  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', function () { init(document); });" + Символы.ПС +
        "  else init(document);" + Символы.ПС +
        "})();" + Символы.ПС +
        "";
КонецФункции



Процедура ПроверитьГарнитуруШрифта(ГарнитураШрифта)
    Для Каждого НедопустимыйСимвол Из СтрРазделить(";|{|}|<|>|\|" + Символы.ПС + "|" + Символы.ВК, "|") Цикл
        Если СтрНайти(ГарнитураШрифта, НедопустимыйСимвол) > 0 Тогда
            ВызватьИсключение "Недопустимый символ в гарнитуре шрифта.";
        КонецЕсли;
    КонецЦикла;
КонецПроцедуры
