&НаКлиенте
Перем ПоследнийJSONПредпросмотра;

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
    Параметры.Свойство("ПредметныйРаздел", ПредметныйРаздел);
    Параметры.Свойство("НастройкиШаблона", НастройкиШаблона);
    РазделЗаданПриОткрытии = ЗначениеЗаполнено(ПредметныйРаздел);
    Элементы.ПолеРаздел.Доступность = Не РазделЗаданПриОткрытии;
    Если РазделЗаданПриОткрытии Или ЗначениеЗаполнено(НастройкиШаблона) Тогда
        ОткрытьРедакторНаСервере();
    Иначе
        Элементы.КомандыРедактора.Видимость = Ложь;
        Элементы.ПанелиШаблона.Видимость = Ложь;
    КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьРедактор(Команда)
    ОткрытьРедакторНаСервере();
    ПоследнийJSONПредпросмотра = Неопределено;
КонецПроцедуры

&НаСервере
Процедура ОткрытьРедакторНаСервере()
    Если ЗначениеЗаполнено(НастройкиШаблона) Тогда
        Данные = НастройкиШаблона.ПолучитьОбъект();
        Если Данные = Неопределено Или Данные.ПометкаУдаления Тогда
            ВызватьИсключение "Настройки шаблона недоступны.";
        КонецЕсли;
        Если РазделЗаданПриОткрытии И Данные.ПредметныйРаздел <> ПредметныйРаздел Тогда
            ВызватьИсключение "Настройки относятся к другому предметному разделу.";
        КонецЕсли;
        ПредметныйРаздел = Данные.ПредметныйРаздел;
        НаименованиеШаблона = Данные.Наименование;
        ИсходноеНаименование = Данные.Наименование;
        ИсходныйJSON = Данные.НастройкиJSON;
        HTMLПредпросмотр = ДокументПредпросмотра(Данные.HTML);
    Иначе
        ИсходныйJSON = "{""width"":640,""rows"":[]}";
        НаименованиеШаблона = "";
        HTMLПредпросмотр = ДокументПредпросмотра("<p>Добавьте области в редакторе.</p>");
    КонецЕсли;
    Если Не ЗначениеЗаполнено(ПредметныйРаздел) Тогда
        ВызватьИсключение "Выберите предметный раздел.";
    КонецЕсли;
    ОткрытыйРаздел = ПредметныйРаздел;
    ОткрытыеНастройки = НастройкиШаблона;
    ДанныеBase64 = Base64Строка(ПолучитьДвоичныеДанныеИзСтроки(ИсходныйJSON, КодировкаТекста.UTF8));
    ДанныеBase64 = СтрЗаменить(СтрЗаменить(ДанныеBase64, Символы.ПС, ""), Символы.ВК, "");
    HTMLРедактор = СтрЗаменить(СтраницаРедактора(), "__INITIAL_STATE_BASE64__", ДанныеBase64);
    HTMLРедактор = СтрЗаменить(HTMLРедактор, "__NATIVE_FILES__", ?(ОбщегоНазначения.ЭтоВебКлиент(), "0", "1"));
    Элементы.КомандыРедактора.Видимость = Истина;
    Элементы.ПанелиШаблона.Видимость = Истина;
    Элементы.Настройки.Доступность = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
    ПодключитьОбработчикОжидания("ОбновитьПредпросмотр", 1, Ложь);
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
    ОтключитьОбработчикОжидания("ОбновитьПредпросмотр");
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьПредпросмотр() Экспорт
    Если Не Элементы.ПанелиШаблона.Видимость Тогда
        Возврат;
    КонецЕсли;
    Попытка
        ДокументРедактора = Элементы.Редактор.Документ;
        ЗапросФайла = ДокументРедактора.getElementById("file-request");
        JSONНастроек = ДокументРедактора.getElementById("state").value;
    Исключение
        // Поле HTML ещё загружается.
        Возврат;
    КонецПопытки;
    Если ЗапросФайла.value = "1" Тогда
        ЗапросФайла.value = "";
        Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
        Диалог.Фильтр = "Изображения и иконки (PNG, JPG, JPEG, GIF, WebP, ICO)|*.png;*.jpg;*.jpeg;*.gif;*.webp;*.ico";
        Диалог.Показать(Новый ОписаниеОповещения("ФайлИзображенияВыбран", ЭтотОбъект));
        Возврат;
    КонецЕсли;
    Если Не ПустаяСтрока(JSONНастроек) И JSONНастроек <> ПоследнийJSONПредпросмотра Тогда
        ПоследнийJSONПредпросмотра = JSONНастроек;
        ОбновитьПредпросмотрНаСервере(JSONНастроек);
    КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ФайлИзображенияВыбран(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
    Результат = Символы.ПС;
    Если ВыбранныеФайлы <> Неопределено И ВыбранныеФайлы.Количество() > 0 Тогда
        Попытка
            Файл = Новый Файл(ВыбранныеФайлы[0]);
            Если СтрРазделить(".png,.jpg,.jpeg,.gif,.webp,.ico", ",").Найти(НРег(Файл.Расширение)) = Неопределено
                Или Файл.Размер() = 0 Или Файл.Размер() > 2097152 Тогда
                ВызватьИсключение "Выберите PNG, JPG, JPEG, GIF, WebP или ICO до 2 МБ.";
            КонецЕсли;
            Данные = Base64Строка(Новый ДвоичныеДанные(Файл.ПолноеИмя));
            Результат = Файл.Имя + Символы.ПС + СтрЗаменить(СтрЗаменить(Данные, Символы.ПС, ""), Символы.ВК, "");
        Исключение
            Сообщить(ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
        КонецПопытки;
    КонецЕсли;
    Элементы.Редактор.Документ.getElementById("file-result").value = Результат;
КонецПроцедуры

&НаСервере
Процедура ОбновитьПредпросмотрНаСервере(JSONНастроек)
    Попытка
        HTML = Справочники.НастройкиШаблонов.СформироватьHTMLИзJSON(JSONНастроек, ОткрытыйРаздел);
    Исключение
        Причина = ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
        HTML = "<p>" + СообщенияИнтерфейсаПКМП.ЭкранироватьHTML(Причина) + "</p>";
    КонецПопытки;
    HTMLПредпросмотр = ДокументПредпросмотра(HTML);
КонецПроцедуры

&НаСервереБезКонтекста
Функция ДокументПредпросмотра(HTML)
    Возврат "<!doctype html><html lang=""ru""><meta charset=""utf-8""><body>" + HTML + "</body></html>";
КонецФункции

&НаКлиенте
Процедура ПредпросмотрПриНажатии(Элемент, ДанныеСобытия, СтандартнаяОбработка)
    СтандартнаяОбработка = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура ВставитьПараметр(Команда)
    Попытка
        Если Элементы.Редактор.Документ.getElementById("can-insert").value <> "1" Тогда
            Сообщить("Выберите область «Текст» или «Кнопка» и установите курсор в тексте.");
            Возврат;
        КонецЕсли;
    Исключение
        Сообщить("Дождитесь загрузки редактора.");
        Возврат;
    КонецПопытки;
    ОткрытьФорму("Обработка.ВыборПараметраШаблона.Форма",
        Новый Структура("ПредметныйРаздел", ОткрытыйРаздел), ЭтотОбъект, , , ,
        Новый ОписаниеОповещения("ПослеВыбораПараметра", ЭтотОбъект), РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
КонецПроцедуры

&НаКлиенте
Процедура ПослеВыбораПараметра(Результат, ДополнительныеПараметры) Экспорт
    Если Результат <> Неопределено Тогда
        Элементы.Редактор.Документ.getElementById("insert-parameter").value = "{" + Результат + "}";
    КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура Сохранить(Команда)
    Попытка
        JSONНастроек = Элементы.Редактор.Документ.getElementById("state").value;
        Результат = СохранитьНаСервере(JSONНастроек);
    Исключение
        Сообщить(ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
        Возврат;
    КонецПопытки;
    Закрыть(Результат);
КонецПроцедуры

&НаСервере
Функция СохранитьНаСервере(JSONНастроек)
    Возврат Справочники.НастройкиШаблонов.СохранитьШаблон(
        НаименованиеШаблона, ОткрытыйРаздел, JSONНастроек, ОткрытыеНастройки, ИсходныйJSON, ИсходноеНаименование);
КонецФункции


&НаСервереБезКонтекста
Функция СтраницаРедактора()
    Возврат "<!doctype html>
    |<html lang=""ru"">
    |<meta charset=""utf-8"">
    |<title>Конструктор HTML-шаблонов</title>
    |<style>
    |* { box-sizing: border-box; }
    |body { margin: 0; font: 14px Arial, sans-serif; color: #202b39; background: #f4f6fa; }
    |header { padding: 10px 14px; background: white; border-bottom: 1px solid #d5dce6; }
    |main { display: flex; align-items: flex-start; }
    |#preview { flex: 1; min-width: 0; padding: 14px; overflow-x: auto; }
    |#properties { flex: 0 0 345px; min-width: 0; padding: 14px; background: white; border-left: 1px solid #d5dce6; }
    |label { display: inline-block; margin: 0 9px 7px 0; }
    |input, button, textarea, select { font: inherit; }
    |input[type=number] { width: 65px; }
    |input[type=url], textarea { display: block; width: 100%; }
    |textarea { min-height: 95px; }
    |.text-field { display: block; width: 100%; max-width: 100%; min-width: 85px; min-height: 95px; padding: 6px; margin: 3px 0 8px; border: 1px solid #aab8cb; border-radius: 4px; background: white; resize: both; overflow: auto; white-space: pre-wrap; overflow-wrap: break-word; }
    |.file-name { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    |.link-field { display: block; margin-right: 0; }
    |.link-field textarea { min-height: 58px; resize: vertical; overflow-wrap: anywhere; }
    |.font-settings { border: 1px solid #aab8cb; border-radius: 5px; padding: 8px; }
    |.font-settings legend { padding: 0 4px; }
    |button { cursor: pointer; margin: 0 5px 5px 0; padding: 4px 8px; }
    |fieldset { border: 0; margin: 0 0 8px; min-width: 0; padding: 0; }
    |legend { color: #425671; padding: 0 0 4px; }
    |.toggle { background: #fff; border: 1px solid #aab8cb; border-radius: 4px; color: #202b39; }
    |.toggle[aria-pressed=""true""] { background: #e5edff; border-color: #1755a3; color: #133f78; }
    |.toggle img { display: block; width: 16px; height: 16px; }
    |.choice-group .toggle { vertical-align: top; min-height: 26px; }
    |.layout-row { display: flex; align-items: flex-start; background: white; min-height: 10px; margin-bottom: 8px; }
    |.layout-row.active { outline: 1px solid #1755a3; }
    |.layout-row.over-width { outline: 1px solid #ae3030; }
    |.card { flex: 0 0 auto; position: relative; overflow: hidden; cursor: pointer; outline: 1px dashed #aab8cb; outline-offset: -1px; }
    |.card.active { outline: 2px solid #1755a3; outline-offset: -2px; }
    |.region { width: 100%; height: 100%; overflow: auto; }
    |.row-note { color: #ae3030; }
    |.copy { white-space: pre-wrap; overflow-wrap: break-word; }
    |.copy { display: flex; flex-direction: column; }
    |.copy > div { flex: none; }
    |.vertical-middle > div { margin-top: auto; margin-bottom: auto; }
    |.vertical-bottom > div { margin-top: auto; }
    |#status { color: #ae3030; }
    |small { display: block; margin-bottom: 8px; color: #425671; }
    |@media (max-width: 720px) {
    |  #properties { flex-basis: 260px; }
    |}
    |@media (max-width: 500px) {
    |  main { display: block; }
    |  #properties { border-left: 0; border-top: 1px solid #d5dce6; }
    |}
    |</style>
    |<header>
    |  <label>Ширина документа, px <input id=""document-width"" type=""number"" min=""1"" max=""4000""></label>
    |  <button type=""button"" id=""add-row"">Добавить строку</button>
    |  Добавить область в выбранную строку
    |  <button type=""button"" data-add=""text"">Текст</button>
    |  <button type=""button"" data-add=""button"">Кнопка</button>
    |  <button type=""button"" data-add=""image"">Картинка</button>
    |  <button type=""button"" data-add=""icon"">Иконка</button>
    |  <span id=""status"" role=""status""></span>
    |</header>
    |<main>
    |  <section id=""preview"" aria-label=""Предпросмотр""></section>
    |  <aside id=""properties"" aria-label=""Настройки области""></aside>
    |</main>
    |<input type=""hidden"" id=""state"">
    |<input type=""hidden"" id=""can-insert"" value=""0"">
    |<input type=""hidden"" id=""insert-parameter"">
    |<input type=""hidden"" id=""native-file-mode"" value=""__NATIVE_FILES__"">
    |<input type=""hidden"" id=""file-request"">
    |<input type=""hidden"" id=""file-result"">
    |<script>
    |// Self-contained picker: works without the browser's native color dialog.
    |(function(){
    |'use strict';
    |var active=null,drag=null;
    |var colors=['#000000','#434343','#666666','#999999','#cccccc','#ffffff',
    | '#ff0000','#ff8000','#ffff00','#80ff00','#00b050','#00ffff',
    | '#0080ff','#0000ff','#8000ff','#ff00ff','#ff0080','#800000',
    | '#804000','#808000','#008000','#008080','#000080','#800080',
    | '#fecaca','#fed7aa','#fef08a','#bbf7d0','#bfdbfe','#e9d5ff'];
    |var style=document.createElement('style');style.textContent=
    |'.color-choice{display:flex;align-items:center;gap:10px;width:100%;text-align:left;padding:7px!important}.color-chip{width:32px;height:28px;border:1px solid #94a3b8;border-radius:5px;flex-shrink:0}.color-choice code{margin-left:auto;color:#64748b;font-size:12px}.popup-palette{position:fixed;z-index:10000;width:300px;max-height:calc(100vh - 16px);overflow:auto;padding:14px;background:white;border:1px solid #cbd5e1;border-radius:10px;box-shadow:0 12px 38px #0f172a40;color:#334155;font:13px Segoe UI,Arial,sans-serif}.palette-heading{display:flex;align-items:center;justify-content:space-between;margin-bottom:10px}.palette-heading button{padding:2px 7px;font-size:19px;border:0}.palette-sv{position:relative;width:100%;height:150px;cursor:crosshair;touch-action:none;background-image:linear-gradient(to top,#000,transparent),linear-gradient(to right,#fff,transparent);outline-offset:3px}.palette-point{position:absolute;width:12px;height:12px;border:2px solid white;border-radius:50%;box-shadow:0 0 0 1px #334155;transform:translate(-50%,-50%);pointer-events:none}.palette-hue{width:100%;height:22px;margin:13px 0;appearance:none;-webkit-appearance:none;border-radius:5px;background:linear-gradient(to right,#f00,#ff0,#0f0,#0ff,#00f,#f0f,#f00);cursor:pointer}.palette-hue::-webkit-slider-thumb{appearance:none;-webkit-appearance:none;width:10px;height:26px;border:2px solid white;background:transparent;box-shadow:0 0 2px #111;border-radius:3px}.palette-value{display:flex;align-items:center;gap:10px;margin-bottom:12px}.palette-value output{font:13px Consolas,monospace}.palette-swatches{display:grid;grid-template-columns:repeat(6,1fr);gap:7px;margin:9px 0 14px}.palette-swatches button{padding:0;width:100%;height:25px;border:1px solid #94a3b8;border-radius:4px}.palette-swatches button[aria-pressed=true]{outline:2px solid #4f46e5;outline-offset:2px}.palette-done{width:100%}';document.head.appendChild(style);
    |function hsv(hex){var rgb=hex.match(/[0-9a-f]{2}/gi).map(function(x){return parseInt(x,16)/255}),r=rgb[0],g=rgb[1],b=rgb[2],max=Math.max(r,g,b),min=Math.min(r,g,b),d=max-min,h=240;if(d){h=(max===r?(g-b)/d+(g<b?6:0):max===g?(b-r)/d+2:(r-g)/d+4)*60}return {h:h,s:max?d/max:0,v:max}}
    |function hex(c){var h=c.h/60,i=Math.floor(h)%6,f=h-Math.floor(h),p=c.v*(1-c.s),q=c.v*(1-f*c.s),t=c.v*(1-(1-f)*c.s);var rgb=[[c.v,t,p],[q,c.v,p],[p,c.v,t],[p,q,c.v],[t,p,c.v],[c.v,p,q]][i];return '#'+rgb.map(function(n){return Math.round(n*255).toString(16).padStart(2,'0')}).join('')}
    |function close(focus){if(!active)return;var a=active;active=null;drag=null;a.panel.remove();a.anchor.setAttribute('aria-expanded','false');if(focus)a.anchor.focus()}
    |window.closePopupColorPicker=function(){close(false)};
    |window.openPopupColorPicker=function(anchor,current,onChange){
    | if(active&&active.anchor===anchor){close(true);return}close(false);
    | var c=hsv(current),panel=document.createElement('div');panel.className='popup-palette';panel.setAttribute('role','dialog');panel.setAttribute('aria-label','Палитра цветов');
    | panel.innerHTML='<div class=""palette-heading""><strong>Выберите цвет</strong><button type=""button"" aria-label=""Закрыть палитру"">×</button></div><div class=""palette-sv"" tabindex=""0"" role=""slider"" aria-label=""Насыщенность и яркость: стрелки для изменения""><span class=""palette-point""></span></div><input class=""palette-hue"" type=""range"" min=""0"" max=""360"" step=""1"" aria-label=""Оттенок""><div class=""palette-value""><span class=""color-chip""></span><output></output></div><div>Готовые цвета</div><div class=""palette-swatches""></div><button type=""button"" class=""palette-done primary"">Готово</button>';
    | document.body.appendChild(panel);active={panel:panel,anchor:anchor};anchor.setAttribute('aria-expanded','true');
    | var sv=panel.querySelector('.palette-sv'),point=panel.querySelector('.palette-point'),hue=panel.querySelector('.palette-hue'),sample=panel.querySelector('.palette-value .color-chip'),value=panel.querySelector('output'),swatches=panel.querySelector('.palette-swatches');
    | function draw(emit){var color=hex(c);sv.style.backgroundColor='hsl('+c.h+',100%,50%)';point.style.left=c.s*100+'%';point.style.top=(1-c.v)*100+'%';hue.value=c.h;point.style.backgroundColor=color;sample.style.backgroundColor=color;value.textContent=color.toUpperCase();sv.setAttribute('aria-valuetext','Насыщенность '+Math.round(c.s*100)+'%, яркость '+Math.round(c.v*100)+'%');swatches.querySelectorAll('button').forEach(function(b){b.setAttribute('aria-pressed',String(b.dataset.color===color))});if(emit)onChange(color)}
    | colors.forEach(function(color){var b=document.createElement('button');b.type='button';b.style.backgroundColor=color;b.dataset.color=color;b.title=color.toUpperCase();b.setAttribute('aria-label','Цвет '+color.toUpperCase());b.onclick=function(){c=hsv(color);draw(true)};swatches.appendChild(b)});
    | function pick(e){var rect=sv.getBoundingClientRect();c.s=Math.max(0,Math.min(1,(e.clientX-rect.left)/rect.width));c.v=1-Math.max(0,Math.min(1,(e.clientY-rect.top)/rect.height));draw(true)}
    | function start(e){if(e.button!==0)return;e.preventDefault();sv.focus();drag=pick;pick(e)}
    | if(window.PointerEvent){sv.addEventListener('pointerdown',start)}else{sv.addEventListener('mousedown',start)}
    | sv.onkeydown=function(e){var delta=e.shiftKey?.1:.01;if(e.key==='ArrowRight')c.s=Math.min(1,c.s+delta);else if(e.key==='ArrowLeft')c.s=Math.max(0,c.s-delta);else if(e.key==='ArrowUp')c.v=Math.min(1,c.v+delta);else if(e.key==='ArrowDown')c.v=Math.max(0,c.v-delta);else return;e.preventDefault();draw(true)};
    | hue.oninput=function(){c.h=Number(hue.value);draw(true)};panel.querySelector('.palette-heading button').onclick=function(){close(true)};panel.querySelector('.palette-done').onclick=function(){close(true)};
    | draw(false);var rect=anchor.getBoundingClientRect();panel.style.left=Math.max(8,Math.min(rect.left,window.innerWidth-panel.offsetWidth-8))+'px';panel.style.top=Math.max(8,Math.min(rect.bottom+5,window.innerHeight-panel.offsetHeight-8))+'px';sv.focus();
    |};
    |var pointer=Boolean(window.PointerEvent),startEvent=pointer?'pointerdown':'mousedown';
    |document.addEventListener(pointer?'pointermove':'mousemove',function(e){if(drag)drag(e)});
    |document.addEventListener(pointer?'pointerup':'mouseup',function(e){if(drag)drag(e);drag=null});
    |document.addEventListener('pointercancel',function(){drag=null});
    |window.addEventListener('blur',function(){drag=null});
    |document.addEventListener(startEvent,function(e){if(active&&!active.panel.contains(e.target)&&!active.anchor.contains(e.target))close(false)});
    |document.addEventListener('keydown',function(e){if(active&&e.key==='Escape'){e.preventDefault();close(true)}});
    |window.addEventListener('resize',function(){close(false)});
    |})();
    |
    |</script>
    |<script>
    |(function () {
    |    ""use strict"";
    |    var labels = {text: ""Текст"", button: ""Кнопка"", image: ""Картинка"", icon: ""Иконка""};
    |    var fonts = [""Arial"", ""Calibri"", ""Georgia"", ""Tahoma"", ""Times New Roman"", ""Verdana""];
    |    var alignments = [[""left"", ""Слева""], [""center"", ""По центру""], [""right"", ""Справа""]];
    |    var verticalAlignments = [[""top"", ""Сверху""], [""middle"", ""По середине""], [""bottom"", ""Снизу""]];
    |    var borders = [[""none"", ""Нет""], [""solid"", ""Сплошная""], [""dashed"", ""Пунктир""], [""dotted"", ""Мелкий пунктир""]];
    |    var toolIcons = {""left"":""data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3QgeD0iMiIgeT0iMyIgd2lkdGg9IjYiIGhlaWdodD0iMSIgZmlsbD0iIzUwNTA1MCIvPgo8cmVjdCB4PSIyIiB5PSI2IiB3aWR0aD0iMTIiIGhlaWdodD0iMSIgZmlsbD0iIzUwNTA1MCIvPgo8cmVjdCB4PSIyIiB5PSI5IiB3aWR0aD0iOCIgaGVpZ2h0PSIxIiBmaWxsPSIjNTA1MDUwIi8+CjxyZWN0IHg9IjIiIHk9IjEyIiB3aWR0aD0iMTIiIGhlaWdodD0iMSIgZmlsbD0iIzUwNTA1MCIvPgo8L3N2Zz4K"",""center"":""data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3QgeD0iNSIgeT0iMyIgd2lkdGg9IjYiIGhlaWdodD0iMSIgZmlsbD0iIzUwNTA1MCIvPgo8cmVjdCB4PSIyIiB5PSI2IiB3aWR0aD0iMTIiIGhlaWdodD0iMSIgZmlsbD0iIzUwNTA1MCIvPgo8cmVjdCB4PSI0IiB5PSI5IiB3aWR0aD0iOCIgaGVpZ2h0PSIxIiBmaWxsPSIjNTA1MDUwIi8+CjxyZWN0IHg9IjIiIHk9IjEyIiB3aWR0aD0iMTIiIGhlaWdodD0iMSIgZmlsbD0iIzUwNTA1MCIvPgo8L3N2Zz4K"",""right"":""data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTE0IDNIOFY0SDE0VjNaIiBmaWxsPSIjNTA1MDUwIi8+CjxwYXRoIGQ9Ik0xNCA2SDJWN0gxNFY2WiIgZmlsbD0iIzUwNTA1MCIvPgo8cGF0aCBkPSJNMTQgOUg2VjEwSDE0VjlaIiBmaWxsPSIjNTA1MDUwIi8+CjxwYXRoIGQ9Ik0xNCAxMkgyVjEzSDE0VjEyWiIgZmlsbD0iIzUwNTA1MCIvPgo8L3N2Zz4K"",""top"":""data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTIgMkgxNFYzSDJWMloiIGZpbGw9IiM1MDUwNTAiLz4KPHBhdGggZD0iTTIgNUgxNFY2SDJWNVoiIGZpbGw9IiM1MDUwNTAiLz4KPC9zdmc+Cg=="",""middle"":""data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTIgNkgxNFY3SDJWNloiIGZpbGw9IiM1MDUwNTAiLz4KPHBhdGggZD0iTTIgOUgxNFYxMEgyVjlaIiBmaWxsPSIjNTA1MDUwIi8+Cjwvc3ZnPgo="",""bottom"":""data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTIgMTBIMTRWMTFIMlYxMFoiIGZpbGw9IiM1MDUwNTAiLz4KPHBhdGggZD0iTTIgMTNIMTRWMTRIMlYxM1oiIGZpbGw9IiM1MDUwNTAiLz4KPC9zdmc+Cg=="",""solid"":""data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3QgeD0iMi41IiB5PSIyLjUiIHdpZHRoPSIxMSIgaGVpZ2h0PSIxMSIgc3Ryb2tlPSIjNTA1MDUwIi8+Cjwvc3ZnPgo="",""dashed"":""data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3QgeD0iMi41IiB5PSIyLjUiIHdpZHRoPSIxMSIgaGVpZ2h0PSIxMSIgc3Ryb2tlPSIjNTA1MDUwIiBzdHJva2UtZGFzaGFycmF5PSIzIDIiLz4KPC9zdmc+Cg=="",""dotted"":""data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3QgeD0iMi41IiB5PSIyLjUiIHdpZHRoPSIxMSIgaGVpZ2h0PSIxMSIgc3Ryb2tlPSIjNTA1MDUwIiBzdHJva2UtZGFzaGFycmF5PSIxIDEiLz4KPC9zdmc+Cg==""};
    |    var imageTypes = {png: ""image/png"", jpg: ""image/jpeg"", jpeg: ""image/jpeg"", gif: ""image/gif"", webp: ""image/webp"", ico: ""image/x-icon""};
    |    var baseStyle = {font: ""Arial"", size: 16, color: ""#202b39"", bold: false, italic: false, underline: false};
    |    var stateField = document.getElementById(""state"");
    |    var insertField = document.getElementById(""insert-parameter"");
    |    var canInsert = document.getElementById(""can-insert"");
    |    var properties = document.getElementById(""properties"");
    |    var preview = document.getElementById(""preview"");
    |    var status = document.getElementById(""status"");
    |    var encoded = ""__INITIAL_STATE_BASE64__"";
    |    var layout = JSON.parse(decodeURIComponent(escape(atob(encoded))));
    |    var rows = layout.rows;
    |    if (!rows.length) rows.push([]);
    |    var activeRow = 0;
    |    var selected = rows[0][0];
    |    var textInput;
    |    var textFieldSize = {};
    |    var textHistory = new WeakMap();
    |    var from = 0;
    |    var to = 0;
    |    var sources = new WeakMap();
    |    var pendingUploads = 0;
    |    var nativeFile;
    |
    |    function create(tag, parent, content) {
    |        var element = document.createElement(tag);
    |        if (content !== undefined) element.textContent = content;
    |        parent.appendChild(element);
    |        return element;
    |    }
    |
    |    function action(parent, caption, handler) {
    |        var button = create(""button"", parent, caption);
    |        button.type = ""button"";
    |        button.onclick = handler;
    |        return button;
    |    }
    |
    |    function commit() {
    |        stateField.value = pendingUploads ? """" : JSON.stringify({
    |            width: layout.width,
    |            rows: rows.filter(function (row) { return row.length > 0; })
    |        });
    |        canInsert.value = textInput ? ""1"" : ""0"";
    |        updateDimensions();
    |        renderPreview();
    |    }
    |
    |    function addBlock(kind) {
    |        var row = rows[activeRow];
    |        var freeWidth = layout.width - rowWidth(row);
    |        var block = newBlock(kind, freeWidth > 0 ? freeWidth : layout.width);
    |        row.splice(selected ? row.indexOf(selected) + 1 : row.length, 0, block);
    |        select(activeRow, block);
    |    }
    |
    |    function newBlock(kind, availableWidth) {
    |        if (kind === ""icon"") return {kind: kind, size: Math.min(32, availableWidth), src: """", href: """"};
    |        var block = {kind: kind, width: Math.min(availableWidth, kind === ""button"" ? 180 : 320),
    |            height: kind === ""button"" ? 42 : 80, fullWidth: false, fullHeight: false,
    |            align: kind === ""button"" ? ""center"" : ""left"", verticalAlign: kind === ""image"" ? ""middle"" : ""top""};
    |        if (kind === ""text"") {
    |            block.runs = [];
    |            block.style = baseStyle;
    |            block.fill = ""#ffffff"";
    |            block.border = ""none"";
    |            return block;
    |        }
    |        block.radius = 0;
    |        block.padding = 8;
    |        block.border = ""none"";
    |        block.href = """";
    |        if (kind === ""button"") {
    |            block.text = ""Подробнее"";
    |            block.style = baseStyle;
    |            block.fill = ""#e5edff"";
    |        } else {
    |            block.src = """";
    |        }
    |        return block;
    |    }
    |
    |    function select(row, block) {
    |        activeRow = row;
    |        selected = block;
    |        status.textContent = """";
    |        renderProperties();
    |        commit();
    |    }
    |
    |    function blockWidth(block) {
    |        if (block.kind === ""icon"") return block.size;
    |        return block.width;
    |    }
    |
    |    function blockHeight(block) {
    |        return block.kind === ""icon"" ? block.size : block.height;
    |    }
    |
    |    function rowHeight(row) {
    |        return row.reduce(function (height, block) { return Math.max(height, blockHeight(block)); }, 0);
    |    }
    |
    |    function rowWidths(row) {
    |        var fixed = 0;
    |        var stretch = 0;
    |        row.forEach(function (block) {
    |            if (block.fullWidth) stretch++;
    |            else fixed += blockWidth(block);
    |        });
    |        var free = Math.max(stretch, layout.width - fixed);
    |        return row.map(function (block) {
    |            if (!block.fullWidth) return blockWidth(block);
    |            var width = Math.ceil(free / stretch);
    |            free -= width;
    |            stretch--;
    |            return width;
    |        });
    |    }
    |
    |    function isImage(block) {
    |        return block.kind === ""image"" || block.kind === ""icon"";
    |    }
    |
    |    function rowWidth(row) {
    |        return rowWidths(row).reduce(function (sum, width) { return sum + width; }, 0);
    |    }
    |
    |    function styleText(element, style) {
    |        element.style.fontFamily = style.font;
    |        element.style.fontSize = style.size + ""px"";
    |        element.style.color = style.color;
    |        element.style.fontWeight = style.bold ? ""bold"" : ""normal"";
    |        element.style.fontStyle = style.italic ? ""italic"" : ""normal"";
    |        element.style.textDecoration = style.underline ? ""underline"" : ""none"";
    |    }
    |
    |    function renderPreview() {
    |        preview.textContent = """";
    |        rows.forEach(function (row, rowIndex) {
    |            var widths = rowWidths(row);
    |            var width = widths.reduce(function (sum, item) { return sum + item; }, 0);
    |            var height = rowHeight(row);
    |            action(preview, ""Строка "" + (rowIndex + 1), function () { select(rowIndex, row[0]); })
    |                .setAttribute(""aria-pressed"", rowIndex === activeRow ? ""true"" : ""false"");
    |            if (width > layout.width) {
    |                create(""span"", preview, ""Ширина областей "" + width + "" px превышает ширину документа."").className = ""row-note"";
    |            }
    |            var line = create(""div"", preview);
    |            line.className = ""layout-row"" + (rowIndex === activeRow ? "" active"" : """") + (width > layout.width ? "" over-width"" : """");
    |            line.style.width = layout.width + ""px"";
    |            row.forEach(function (block, index) {
    |                renderBlock(line, block, rowIndex, index, widths[index], block.fullHeight ? height : blockHeight(block));
    |            });
    |        });
    |    }
    |
    |    function renderBlock(line, block, rowIndex, index, width, height) {
    |        var card = create(""div"", line);
    |        card.className = ""card"" + (block === selected ? "" active"" : """");
    |        card.title = (index + 1) + "". "" + labels[block.kind];
    |        card.style.width = width + ""px"";
    |        card.style.height = height + ""px"";
    |        card.onclick = function () { if (selected !== block) select(rowIndex, block); };
    |        var element = create(isImage(block) && block.src ? ""img"" : ""div"", card);
    |        element.className = ""region"";
    |        var css = element.style;
    |        if (block.kind === ""text"") {
    |            element.classList.add(""copy"");
    |            element.classList.add(""vertical-"" + (block.verticalAlign || ""top""));
    |            css.backgroundColor = block.fill;
    |            css.border = ""1px "" + (block.border || ""none"") + "" #777"";
    |            css.textAlign = block.align || ""left"";
    |            var text = create(""div"", element);
    |            block.runs.forEach(function (run) {
    |                styleText(create(""span"", text, run.text), run.style);
    |            });
    |            return;
    |        }
    |        css.display = ""block"";
    |        if (block.kind !== ""icon"") {
    |            css.border = ""1px "" + block.border + "" #777"";
    |            css.borderRadius = block.radius + ""px"";
    |            css.padding = block.padding + ""px"";
    |        }
    |        if (block.kind === ""button"") {
    |            css.display = ""flex"";
    |            create(""div"", element, block.text);
    |            element.classList.add(""copy"");
    |            element.classList.add(""vertical-"" + (block.verticalAlign || ""top""));
    |            css.textAlign = block.align;
    |            css.backgroundColor = block.fill;
    |            styleText(element, block.style);
    |        } else {
    |            css.objectFit = ""contain"";
    |            var vertical = block.verticalAlign || ""middle"";
    |            css.objectPosition = (block.align || ""center"") + "" "" + (vertical === ""middle"" ? ""center"" : vertical);
    |            if (element.tagName === ""IMG"" && /^(https?:\/\/|data:image\/(png|jpeg|gif|webp|x-icon);base64,)/i.test(block.src)) {
    |                element.alt = labels[block.kind];
    |                element.src = block.src;
    |            } else {
    |                element.textContent = block.kind === ""icon"" ? ""◇"" : ""Укажите источник картинки"";
    |            }
    |        }
    |    }
    |
    |    function option(parent, caption, type, value, handler) {
    |        var label = create(""label"", parent, caption + "" "");
    |        var input = create(type === ""url"" ? ""textarea"" : ""input"", label);
    |        if (type === ""url"") {
    |            label.className = ""link-field"";
    |            input.rows = 3;
    |            input.spellcheck = false;
    |        } else {
    |            input.type = type;
    |        }
    |        input.value = value;
    |        input.onchange = function () {
    |            handler(input.value);
    |            commit();
    |        };
    |        return input;
    |    }
    |
    |    function toggle(parent, caption, pressed, handler) {
    |        var button = action(parent, caption, function () {
    |            var next = button.getAttribute(""aria-pressed"") !== ""true"";
    |            button.setAttribute(""aria-pressed"", next);
    |            handler(next);
    |            commit();
    |        });
    |        button.className = ""toggle"";
    |        button.setAttribute(""aria-pressed"", pressed === true);
    |        return button;
    |    }
    |
    |    function choices(parent, caption, items, value, handler) {
    |        var group = create(""fieldset"", parent);
    |        group.className = ""choice-group"";
    |        create(""legend"", group, caption);
    |        var buttons = items.map(function (item) {
    |            var button = toggle(group, item[1], item[0] === value, function () {
    |                buttons.forEach(function (button, index) {
    |                    button.setAttribute(""aria-pressed"", items[index][0] === item[0]);
    |                });
    |                handler(item[0]);
    |            });
    |            if (toolIcons[item[0]]) {
    |                button.textContent = """";
    |                button.title = item[1];
    |                button.setAttribute(""aria-label"", item[1]);
    |                var image = create(""img"", button);
    |                image.alt = """";
    |                image.src = toolIcons[item[0]];
    |            }
    |            return button;
    |        });
    |    }
    |
    |    function colorOption(parent, caption, value, handler) {
    |        var button = action(parent, """", function () {
    |            window.openPopupColorPicker(button, value, function (color) {
    |                value = color;
    |                chip.style.backgroundColor = color;
    |                code.textContent = color.toUpperCase();
    |                handler(color);
    |                commit();
    |            });
    |        });
    |        button.className = ""color-choice"";
    |        button.setAttribute(""aria-label"", caption);
    |        button.setAttribute(""aria-haspopup"", ""dialog"");
    |        button.setAttribute(""aria-expanded"", ""false"");
    |        var chip = create(""span"", button);
    |        chip.className = ""color-chip"";
    |        chip.style.backgroundColor = value;
    |        create(""span"", button, caption);
    |        var code = create(""code"", button, value.toUpperCase());
    |    }
    |
    |    function number(parent, caption, value, min, max, handler) {
    |        var input = option(parent, caption, ""number"", value, function (raw) {
    |            var next = Math.min(max, Math.max(min, Math.round(Number(raw)) || min));
    |            input.value = next;
    |            handler(next);
    |        });
    |        input.min = min;
    |        input.max = max;
    |        return input;
    |    }
    |
    |    function textOf(block) {
    |        return block.kind === ""text"" ? block.runs.map(function (run) { return run.text; }).join("""") : block.text;
    |    }
    |
    |    function styleAt(block, index) {
    |        var runs = block.runs;
    |        var cursor = 0;
    |        for (var i = 0; i < runs.length; i++) {
    |            cursor += runs[i].text.length;
    |            if (cursor > index) return runs[i].style;
    |        }
    |        return runs.length ? runs[runs.length - 1].style : block.style;
    |    }
    |
    |    function withStyle(style, key, value) {
    |        var next = {};
    |        Object.keys(style).forEach(function (name) { next[name] = style[name]; });
    |        next[key] = value;
    |        return next;
    |    }
    |
    |    function sliceRuns(runs, start, end) {
    |        var cursor = 0;
    |        return runs.reduce(function (result, run) {
    |            var left = Math.max(0, start - cursor);
    |            var right = Math.min(run.text.length, end - cursor);
    |            if (left < right) result.push({text: run.text.slice(left, right), style: run.style});
    |            cursor += run.text.length;
    |            return result;
    |        }, []);
    |    }
    |
    |    function mergeRuns(runs) {
    |        return runs.reduce(function (result, run) {
    |            if (!run.text) return result;
    |            var previous = result[result.length - 1];
    |            if (previous && JSON.stringify(previous.style) === JSON.stringify(run.style)) previous.text += run.text;
    |            else result.push({text: run.text, style: run.style});
    |            return result;
    |        }, []);
    |    }
    |
    |    function replaceText(block, start, end, value) {
    |        if (block.kind === ""button"") {
    |            block.text = block.text.slice(0, start) + value + block.text.slice(end);
    |            return;
    |        }
    |        var runs = block.runs;
    |        var style = styleAt(block, start);
    |        block.runs = mergeRuns(sliceRuns(runs, 0, start).concat(
    |            [{text: value, style: style}], sliceRuns(runs, end, Infinity)));
    |    }
    |
    |    function updateFromInput(block) {
    |        var old = textOf(block);
    |        var rich = block.kind === ""text"";
    |        var next = rich ? textInput.textContent : textInput.value;
    |        var selection = inputSelection(block);
    |        if (next.length > 20000) {
    |            status.textContent = ""В области допускается до 20 000 символов."";
    |            refreshTextField(block);
    |            return;
    |        }
    |        if (next === old) return;
    |        if (rich) rememberEdit(block);
    |        var start = 0;
    |        var oldEnd = old.length;
    |        var nextEnd = next.length;
    |        var caret = selection ? selection[0] : next.length;
    |        // Use the edit position to keep the style of identical adjacent characters.
    |        while (start < oldEnd && start < caret && old.charAt(start) === next.charAt(start)) start++;
    |        while (oldEnd > start && nextEnd > caret && old.charAt(oldEnd - 1) === next.charAt(nextEnd - 1)) {
    |            oldEnd--;
    |            nextEnd--;
    |        }
    |        replaceText(block, start, oldEnd, next.slice(start, nextEnd));
    |        from = caret;
    |        to = selection ? selection[1] : caret;
    |        if (rich) refreshTextField(block);
    |        commit();
    |    }
    |
    |    function inputSelection(block) {
    |        if (block.kind === ""button"") return [textInput.selectionStart, textInput.selectionEnd];
    |        var selection = window.getSelection();
    |        if (!selection.rangeCount) return null;
    |        var range = selection.getRangeAt(0);
    |        if (!textInput.contains(range.startContainer) || !textInput.contains(range.endContainer)) return null;
    |        var prefix = document.createRange();
    |        prefix.selectNodeContents(textInput);
    |        prefix.setEnd(range.startContainer, range.startOffset);
    |        var start = prefix.toString().length;
    |        return [start, start + range.toString().length];
    |    }
    |
    |    function restoreTextSelection(block) {
    |        if (block.kind === ""button"") {
    |            textInput.setSelectionRange(from, to);
    |            return;
    |        }
    |        var range = document.createRange();
    |        range.selectNodeContents(textInput);
    |        range.collapse(false);
    |        var walker = document.createTreeWalker(textInput, NodeFilter.SHOW_TEXT);
    |        var offset = 0;
    |        var startSet = false;
    |        for (var node = walker.nextNode(); node; node = walker.nextNode()) {
    |            var end = offset + node.length;
    |            if (!startSet && from <= end) {
    |                range.setStart(node, from - offset);
    |                startSet = true;
    |            }
    |            if (to <= end) {
    |                range.setEnd(node, to - offset);
    |                break;
    |            }
    |            offset = end;
    |        }
    |        if (from === to && textInput.lastElementChild && textInput.lastElementChild.tagName === ""BR""
    |            && to === textInput.textContent.length) {
    |            range.setStartBefore(textInput.lastElementChild);
    |            range.collapse(true);
    |        }
    |        var selection = window.getSelection();
    |        selection.removeAllRanges();
    |        selection.addRange(range);
    |    }
    |
    |    function refreshTextField(block) {
    |        styleText(textInput, block.style);
    |        if (block.kind !== ""text"") return;
    |        textInput.style.textDecoration = ""none"";
    |        textInput.textContent = """";
    |        block.runs.forEach(function (run) {
    |            styleText(create(""span"", textInput, run.text), run.style);
    |        });
    |        if (textInput.textContent.slice(-1) === ""\n"") create(""br"", textInput);
    |        if (document.activeElement === textInput) restoreTextSelection(block);
    |    }
    |
    |    function historyFor(block) {
    |        var history = textHistory.get(block);
    |        if (!history) {
    |            history = {undo: [], redo: []};
    |            textHistory.set(block, history);
    |        }
    |        return history;
    |    }
    |
    |    function textSnapshot(block) {
    |        return {runs: block.runs, style: block.style, from: from, to: to};
    |    }
    |
    |    function rememberEdit(block) {
    |        var history = historyFor(block);
    |        history.undo.push(textSnapshot(block));
    |        if (history.undo.length > 40) history.undo.shift();
    |        history.redo.length = 0;
    |    }
    |
    |    function restoreEdit(block, redo) {
    |        var history = historyFor(block);
    |        var stack = redo ? history.redo : history.undo;
    |        if (!stack.length) return;
    |        var target = stack.pop();
    |        (redo ? history.undo : history.redo).push(textSnapshot(block));
    |        block.runs = target.runs;
    |        block.style = target.style;
    |        from = target.from;
    |        to = target.to;
    |        refreshTextField(block);
    |        commit();
    |    }
    |
    |    function insertText(block, value) {
    |        if (textOf(block).length - (to - from) + value.length > 20000) {
    |            status.textContent = ""В области допускается до 20 000 символов."";
    |            return;
    |        }
    |        if (block.kind === ""text"") rememberEdit(block);
    |        replaceText(block, from, to, value);
    |        from += value.length;
    |        to = from;
    |        if (block.kind === ""button"") textInput.value = block.text;
    |        textInput.focus();
    |        refreshTextField(block);
    |        restoreTextSelection(block);
    |        commit();
    |    }
    |
    |    function renderTypography(block) {
    |        var row = create(""fieldset"", properties);
    |        row.className = ""font-settings"";
    |        create(""legend"", row, ""Шрифт"");
    |        var style = block.kind === ""text"" ? styleAt(block, from) : block.style;
    |        function apply(key, value) {
    |            if (block.kind === ""button"") {
    |                block.style = withStyle(block.style, key, value);
    |                refreshTextField(block);
    |                return;
    |            }
    |            var start = from === to ? 0 : from;
    |            var end = from === to ? Infinity : to;
    |            rememberEdit(block);
    |            if (from === to) block.style = withStyle(block.style, key, value);
    |            var formatted = sliceRuns(block.runs, start, end).map(function (run) {
    |                return {text: run.text, style: withStyle(run.style, key, value)};
    |            });
    |            block.runs = mergeRuns(sliceRuns(block.runs, 0, start).concat(formatted, sliceRuns(block.runs, end, Infinity)));
    |            refreshTextField(block);
    |        }
    |        if (block.kind === ""text"") {
    |            create(""small"", row, ""Выделите фрагмент для форматирования. Без выделения форматируется весь текст."");
    |            var fontList = create(""select"", create(""label"", row, ""Вид шрифта ""));
    |            fonts.forEach(function (font) { create(""option"", fontList, font).value = font; });
    |            fontList.value = style.font;
    |            fontList.onchange = function () {
    |                apply(""font"", fontList.value);
    |                commit();
    |            };
    |        }
    |        number(row, ""Размер шрифта"", style.size, 8, 100, function (v) { apply(""size"", v); });
    |        toggle(row, ""Жирный"", style.bold, function (v) { apply(""bold"", v); });
    |        toggle(row, ""Курсив"", style.italic, function (v) { apply(""italic"", v); });
    |        toggle(row, ""Подчёркнутый"", style.underline, function (v) { apply(""underline"", v); });
    |        colorOption(row, ""Цвет текста"", style.color, function (v) { apply(""color"", v); });
    |        return row;
    |    }
    |
    |    function renderProperties() {
    |        window.closePopupColorPicker();
    |        if (textInput) textFieldSize = {width: textInput.style.width, height: textInput.style.height};
    |        properties.textContent = """";
    |        textInput = null;
    |        from = to = 0;
    |        var row = rows[activeRow];
    |        var block = selected;
    |        var heading = create(""div"", properties);
    |        create(""p"", heading, ""Строка "" + (activeRow + 1) + (block ? "" · "" + labels[block.kind] : "" · пустая""));
    |        if (!block) {
    |            if (rows.length > 1) action(heading, ""Удалить пустую строку"", function () {
    |                rows.splice(activeRow, 1);
    |                var next = Math.min(activeRow, rows.length - 1);
    |                select(next, rows[next][0]);
    |            });
    |            return;
    |        }
    |        var index = row.indexOf(block);
    |        action(heading, ""Удалить область"", function () {
    |            row.splice(index, 1);
    |            select(activeRow, row[Math.min(index, row.length - 1)]);
    |        });
    |        function moveWithinRow(delta) {
    |            row.splice(index, 1);
    |            row.splice(index + delta, 0, block);
    |            select(activeRow, block);
    |        }
    |        function moveToRow(delta) {
    |            row.splice(index, 1);
    |            var next = activeRow + delta;
    |            rows[next].push(block);
    |            select(next, block);
    |        }
    |        action(heading, ""Левее"", function () { moveWithinRow(-1); }).disabled = index === 0;
    |        action(heading, ""Правее"", function () { moveWithinRow(1); }).disabled = index === row.length - 1;
    |        action(heading, ""В строку выше"", function () { moveToRow(-1); }).disabled = activeRow === 0;
    |        action(heading, ""В строку ниже"", function () { moveToRow(1); }).disabled = activeRow === rows.length - 1;
    |        if (block.kind === ""icon"") {
    |            number(properties, ""Размер, px"", block.size, 1, 4000, function (v) { block.size = v; });
    |            renderImageSource(block);
    |            renderLink(block);
    |            return;
    |        }
    |        var dimensions = create(""div"", properties);
    |        var widthInput = number(dimensions, ""Ширина, px"", block.width, 1, 4000, function (v) { block.width = v; });
    |        widthInput.id = ""area-width"";
    |        toggle(dimensions, ""На всю ширину"", block.fullWidth, function (v) {
    |            block.fullWidth = v;
    |        });
    |        var heightInput = number(dimensions, ""Высота, px"", block.height, 1, 4000, function (v) { block.height = v; });
    |        heightInput.id = ""area-height"";
    |        toggle(dimensions, ""На всю высоту"", block.fullHeight, function (v) { block.fullHeight = v; });
    |        if (!isImage(block)) {
    |            var rich = block.kind === ""text"";
    |            var field = create(""div"", properties, ""Текст"");
    |            textInput = create(rich ? ""div"" : ""textarea"", field);
    |            textInput.className = ""text-field"";
    |            textInput.style.width = textFieldSize.width || """";
    |            textInput.style.height = textFieldSize.height || """";
    |            textInput.setAttribute(""aria-label"", ""Текст"");
    |            if (rich) {
    |                textInput.setAttribute(""contenteditable"", ""plaintext-only"");
    |                textInput.setAttribute(""role"", ""textbox"");
    |                textInput.setAttribute(""aria-multiline"", ""true"");
    |            } else {
    |                textInput.maxLength = 20000;
    |                textInput.value = block.text;
    |            }
    |            refreshTextField(block);
    |            var typography = renderTypography(block);
    |            function rebuildTypography() {
    |                window.closePopupColorPicker();
    |                typography.parentNode.removeChild(typography);
    |                typography = renderTypography(block);
    |                properties.insertBefore(typography, field.nextSibling);
    |            }
    |            function rememberSelection() {
    |                var selection = inputSelection(block);
    |                if (!selection) return;
    |                var start = selection[0];
    |                var end = selection[1];
    |                if (from === start && to === end) return;
    |                from = start;
    |                to = end;
    |                rebuildTypography();
    |            }
    |            textInput.oninput = function (event) { if (!event.isComposing) updateFromInput(block); };
    |            if (rich) {
    |                textInput.oncompositionend = function () { updateFromInput(block); };
    |                textInput.onkeydown = function (event) {
    |                    if (!(event.ctrlKey || event.metaKey) || event.altKey) return;
    |                    var key = event.key.toLowerCase();
    |                    if (key !== ""z"" && key !== ""y"") return;
    |                    event.preventDefault();
    |                    restoreEdit(block, key === ""y"" || event.shiftKey);
    |                    rebuildTypography();
    |                };
    |                textInput.onbeforeinput = function (event) {
    |                    if (event.inputType === ""historyUndo"" || event.inputType === ""historyRedo"") {
    |                        event.preventDefault();
    |                        restoreEdit(block, event.inputType === ""historyRedo"");
    |                        rebuildTypography();
    |                    } else if (event.inputType === ""insertParagraph"" || event.inputType === ""insertLineBreak"") {
    |                        event.preventDefault();
    |                        rememberSelection();
    |                        insertText(block, ""\n"");
    |                    }
    |                };
    |                textInput.onpaste = function (event) {
    |                    event.preventDefault();
    |                    rememberSelection();
    |                    insertText(block, event.clipboardData.getData(""text/plain"").replace(/\r\n?/g, ""\n""));
    |                };
    |                textInput.ondrop = function (event) { event.preventDefault(); };
    |            }
    |            textInput.onselect = textInput.onkeyup = textInput.onmouseup = rememberSelection;
    |            colorOption(properties, ""Заливка"", block.fill, function (v) { block.fill = v; });
    |        }
    |        choices(properties, ""Выравнивание"", alignments, block.align || ""left"", function (v) { block.align = v; });
    |        choices(properties, ""По вертикали"", verticalAlignments, block.verticalAlign || (isImage(block) ? ""middle"" : ""top""),
    |            function (v) { block.verticalAlign = v; });
    |        if (block.kind === ""text"") {
    |            choices(properties, ""Обводка"", borders, block.border || ""none"", function (v) { block.border = v; });
    |            return;
    |        }
    |        if (block.kind === ""image"") renderImageSource(block);
    |        renderLink(block);
    |        number(properties, ""Скругление, px"", block.radius, 0, 300, function (v) { block.radius = v; });
    |        number(properties, ""Отступы, px"", block.padding, 0, 200, function (v) { block.padding = v; });
    |        choices(properties, ""Обводка"", borders, block.border, function (v) { block.border = v; });
    |    }
    |
    |    function updateDimensions() {
    |        var width = document.getElementById(""area-width"");
    |        if (!width) return;
    |        var row = rows[activeRow];
    |        var height = document.getElementById(""area-height"");
    |        width.disabled = selected.fullWidth === true;
    |        width.value = width.disabled ? rowWidths(row)[row.indexOf(selected)] : selected.width;
    |        height.disabled = selected.fullHeight === true;
    |        height.value = height.disabled ? rowHeight(row) : selected.height;
    |    }
    |
    |    function renderLink(block) {
    |        option(properties, ""Ссылка при нажатии"", ""url"", block.href, function (v) { block.href = v; });
    |    }
    |
    |    function renderImageSource(block) {
    |        var source = sources.get(block);
    |        if (!source) {
    |            var local = /^data:/.test(block.src);
    |            source = {mode: local ? ""file"" : ""url"", file: local ? block.src : """", url: local ? """" : block.src,
    |                fileName: local ? (block.fileName || """") : """", pending: false};
    |            sources.set(block, source);
    |        }
    |        var group = create(""fieldset"", properties);
    |        create(""legend"", group, ""Источник"");
    |        [[""url"", ""По ссылке""], [""file"", ""Из файла""]].forEach(function (item) {
    |            var label = create(""label"", group);
    |            var radio = create(""input"", label);
    |            radio.type = ""radio"";
    |            radio.name = ""image-source"";
    |            radio.checked = source.mode === item[0];
    |            radio.disabled = source.pending;
    |            create(""span"", label, item[1]);
    |            radio.onchange = function () {
    |                source.mode = item[0];
    |                block.src = source[source.mode];
    |                if (source.mode === ""file"" && source.fileName) block.fileName = source.fileName;
    |                else delete block.fileName;
    |                status.textContent = """";
    |                renderFields();
    |                commit();
    |            };
    |        });
    |        var fields = create(""div"", group);
    |        function renderFields() {
    |            fields.textContent = """";
    |            if (source.mode === ""file"") {
    |                renderFileInput(fields, block, source);
    |                return;
    |            }
    |            option(fields, ""URL изображения"", ""url"", source.url, function (value) {
    |                source.url = value;
    |                block.src = value;
    |                status.textContent = """";
    |            });
    |        }
    |        renderFields();
    |    }
    |
    |    function renderFileInput(parent, block, source) {
    |        if (source.file) {
    |            var fileName = create(""small"", parent, source.fileName || ""Файл загружен"");
    |            fileName.className = ""file-name"";
    |            fileName.title = source.fileName;
    |        }
    |        if (document.getElementById(""native-file-mode"").value === ""1"") {
    |            var choose = action(parent, source.file ? ""Заменить файл"" : ""Загрузить файл"", function () {
    |                nativeFile = {block: block, source: source};
    |                startFileRead(source);
    |                document.getElementById(""file-request"").value = ""1"";
    |            });
    |            choose.disabled = !!nativeFile;
    |            return;
    |        }
    |        var file = create(""input"", create(""label"", parent, source.file ? ""Заменить файл "" : ""Загрузить файл ""));
    |        file.type = ""file"";
    |        file.accept = Object.keys(imageTypes).map(function (type) { return ""."" + type; }).join("","");
    |        file.disabled = source.pending;
    |        file.onchange = function () {
    |            var chosen = file.files[0];
    |            if (!chosen) return;
    |            var extension = /\.(png|jpe?g|gif|webp|ico)$/i.exec(chosen.name);
    |            if (!extension || chosen.size === 0 || chosen.size > 2097152) {
    |                status.textContent = ""Выберите PNG, JPG, JPEG, GIF, WebP или ICO до 2 МБ."";
    |                return;
    |            }
    |            var reader = new FileReader();
    |            startFileRead(source);
    |            reader.onloadend = function () {
    |                var data = typeof reader.result === ""string"" ? reader.result.split("","")[1] : """";
    |                finishFileRead(block, source, chosen.name, data);
    |            };
    |            reader.readAsDataURL(chosen);
    |        };
    |    }
    |
    |    function startFileRead(source) {
    |        source.pending = true;
    |        pendingUploads++;
    |        renderProperties();
    |        status.textContent = ""Загрузка изображения…"";
    |        commit();
    |    }
    |
    |    function finishFileRead(block, source, name, data) {
    |        source.pending = false;
    |        pendingUploads--;
    |        var extension = name.split(""."").pop().toLowerCase();
    |        if (data && imageTypes[extension]) {
    |            source.file = ""data:"" + imageTypes[extension] + "";base64,"" + data;
    |            source.fileName = name;
    |            block.src = source.file;
    |            block.fileName = name;
    |        }
    |        if (selected === block || document.getElementById(""native-file-mode"").value === ""1"") {
    |            renderProperties();
    |            status.textContent = data ? ""Файл загружен."" : (name ? ""Файл не прочитан."" : """");
    |        }
    |        commit();
    |    }
    |
    |    [].forEach.call(document.querySelectorAll(""[data-add]""), function (button) {
    |        button.onclick = function () { addBlock(button.getAttribute(""data-add"")); };
    |    });
    |    var documentWidth = document.getElementById(""document-width"");
    |    documentWidth.value = layout.width;
    |    documentWidth.onchange = function () {
    |        layout.width = Math.min(4000, Math.max(1, Math.round(Number(documentWidth.value)) || 1));
    |        documentWidth.value = layout.width;
    |        renderProperties();
    |        commit();
    |    };
    |    document.getElementById(""add-row"").onclick = function () {
    |        rows.splice(activeRow + 1, 0, []);
    |        select(activeRow + 1);
    |    };
    |    setInterval(function () {
    |        var fileResult = document.getElementById(""file-result"");
    |        if (nativeFile && fileResult.value) {
    |            var result = fileResult.value.split(""\n"");
    |            var target = nativeFile;
    |            fileResult.value = """";
    |            nativeFile = null;
    |            finishFileRead(target.block, target.source, result[0], result[1]);
    |        }
    |        var value = insertField.value;
    |        if (!value || !textInput) return;
    |        insertField.value = """";
    |        insertText(selected, value);
    |    }, 150);
    |    select(activeRow, selected);
    |}());
    |
    |</script>
    |</html>
    |";
КонецФункции
